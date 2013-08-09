module CspProvisioner
  java_import java.net.URLEncoder
  java_import java.util.Arrays
  
  class API
    def initialize()
      @cloud_number = Config::CSP_CLOUD_NUMBER
      @secret_token = Config::CSP_SECRET_TOKEN
      @global_salt  = Config::CSP_GLOBAL_SALT
      
      @registrar_endpoint     = Config::RESPECT_NETWORK_REGISTRAR_XDI_ENDPOINT
      @registrar_cloud_number = Config::RESPECT_NETWORK_CLOUD_NUMBER

      @registry_endpoint  = Config::NEUSTAR_HOSTING_ENVIRONMENT_XDI_ENDPOINT
      @cloud_base_uri     = Config::NEUSTAR_HOSTING_ENVIRONMENT_CLOUDS_BASE
      
      @registrar_client = XDI::XDIHttpClient.new(@registrar_endpoint)
      @registry_client  = XDI::XDIHttpClient.new(@registry_endpoint)
    end
    
    def build_message_from_options(options = {})
      envelope = XDI::MessageEnvelope.new()

      message  = envelope.getMessage(@cloud_number, true)
      
      message.setToAddress(peer_root_xri(options[:recipient]))
      message.getContextNode().setDeepLiteral(XDI::XDIAuthenticationConstants::XRI_S_SECRET_TOKEN, @secret_token)
      message.setLinkContractXri(XDI::XDI3Segment.create(options[:link_contract]))
      
      case options[:operation]
      when :get
        message.createGetOperation(options[:arguments])
      when :set
        message.createSetOperation(options[:arguments])
      end

      envelope
    end
    
    def peer_root_xri(name_or_number)
      segment = name_or_number.is_a?(XDI::XDI3Segment) ? name_or_number : XDI::XDI3Segment.create(name_or_number)
      XDI::XDI3Segment.create(XDI::XdiPeerRoot.createPeerRootArcXri(segment))
    end
    
    def is_cloud_name_available?(cloud_name)
      cloud_name_peer_root  = peer_root_xri(cloud_name)
      registrar_peer_root   = peer_root_xri(@registrar_cloud_number)
      
      message = build_message_from_options({
        :recipient      => @registrar_cloud_number,
        :link_contract  => "+registrar$do",
        :operation      => :get,
        :arguments      => cloud_name_peer_root
      })
      
      message_result = @registrar_client.send(message, nil)  

      if message_result.getGraph().isEmpty()
        true
      else
        relation = message_result.getGraph().getDeepRelation(cloud_name_peer_root, XDI::XDIDictionaryConstants::XRI_S_REF)
        
        cloud_number_peer_root = relation.getTargetContextNodeXri()
        cloud_number = XDI::XdiPeerRoot.getXriOfPeerRootArcXri(cloud_number_peer_root.getFirstSubSegment())
        
        puts "Cloud Name #{cloud_name} is already registered with Cloud Number #{cloud_number}"
        
        false
      end
    end

    def register_cloud_name(cloud_name)
      cloud_name_peer_root  = peer_root_xri(cloud_name)
      registrar_peer_root   = peer_root_xri(@registrar_cloud_number)
      target_statement      = XDI::StatementUtil.fromRelationComponents(
                                cloud_name_peer_root, 
                                XDI::XDIDictionaryConstants::XRI_S_REF, 
                                XDI::XDIConstants::XRI_S_VARIABLE
                              )

      message = build_message_from_options({
        :recipient      => @registrar_cloud_number,
        :link_contract  => "+registrar$do",
        :operation      => :set,
        :arguments      => target_statement
      })
      
      message_result = @registrar_client.send(message, nil)  
      
      relation = message_result.getGraph().getDeepRelation(cloud_name_peer_root, XDI::XDIDictionaryConstants::XRI_S_REF)
      #raise "Cloud Number not registered" if relation.blank?
      
      cloud_number_peer_root = relation.getTargetContextNodeXri()
      cloud_number = XDI::XdiPeerRoot.getXriOfPeerRootArcXri(cloud_number_peer_root.getFirstSubSegment())
      
      puts "Cloud Name #{cloud_name} registered with Cloud Number #{cloud_number}"
      {:cloud_name => cloud_name, :cloud_number => cloud_number.to_s}
    end

    def register_cloud(cloud_name, cloud_number, secret_token)
      cloud_name_peer_root    = peer_root_xri(cloud_name)
      cloud_number_peer_root  = peer_root_xri(cloud_number)
      digest_secret_token = XDI::DigestSecretTokenAuthenticator.localSaltAndDigestSecretToken(secret_token, @global_salt)
      cloud_xdi_endpoint  = @cloud_base_uri + URLEncoder.encode(cloud_number, "UTF-8")

      target_statements = [
        XDI::StatementUtil.fromRelationComponents(cloud_name_peer_root, XDI::XDIDictionaryConstants::XRI_S_REF, cloud_number_peer_root),
        XDI::StatementUtil.fromLiteralComponents(XDI::XDI3Segment.create("" + cloud_number_peer_root.to_s + XDI::XDIAuthenticationConstants::XRI_S_DIGEST_SECRET_TOKEN.to_s), digest_secret_token),
        XDI::StatementUtil.fromLiteralComponents(XDI::XDI3Segment.create("" + cloud_number_peer_root.to_s + "$xdi<$uri>&"), cloud_xdi_endpoint)
      ].to_java(XDI::XDI3Statement)

      message = build_message_from_options({
        :recipient      => @cloud_number,
        :link_contract  => "$do",
        :operation      => :set,
        :arguments      => Arrays.asList(target_statements).iterator()
      })

      @registry_client.send(message, nil)

      puts "Cloud #{cloud_name} registered with Cloud Number #{cloud_number} and Digest Secret Token #{secret_token} and Cloud XDI endpoint #{cloud_xdi_endpoint}"
      
      {:cloud_name => cloud_name, :cloud_number => cloud_number, :endpoint => cloud_xdi_endpoint}
    end

    def register_cloud_xdi_url(cloud_number, endpoint)
      cloud_number_peer_root = peer_root_xri(cloud_number)

      target_statement = XDI::StatementUtil.fromLiteralComponents(XDI::XDI3Segment.create("" + cloud_number_peer_root.to_s + "$xdi<$uri>&"), endpoint)
      
      message = build_message_from_options({
        :recipient      => @registrar_cloud_number,
        :link_contract  => "+registrar$do",
        :operation      => :set,
        :arguments      => target_statement
      })

      @registrar_client.send(message, nil)

      puts "Cloud XDI URL registered with Cloud Number #{cloud_number} and Cloud XDI endpoint #{endpoint}"
    end
  end
end
  