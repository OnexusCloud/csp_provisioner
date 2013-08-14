module CspProvisioner
  def self.root
    File.expand_path '../..', __FILE__
  end
  
  Dir[CspProvisioner.root + '/lib/jars/*.jar'].each { |file| require file }
  
  require 'java'
    
  java_import java.net.URLEncoder
  java_import java.util.Arrays
  
  module XDI
    java_import 'xdi2.core.Relation'

    java_import 'xdi2.core.constants.XDIAuthenticationConstants'
    java_import 'xdi2.core.constants.XDIConstants'
    java_import 'xdi2.core.constants.XDIDictionaryConstants'

    java_import 'xdi2.core.features.nodetypes.XdiPeerRoot'

    java_import 'xdi2.core.util.StatementUtil'

    java_import 'xdi2.core.xri3.XDI3Segment'
    java_import 'xdi2.core.xri3.XDI3Statement'

    java_import 'xdi2.client.XDIClient'
    java_import 'xdi2.client.http.XDIHttpClient'

    java_import 'xdi2.messaging.Message'
    java_import 'xdi2.messaging.MessageEnvelope'
    java_import 'xdi2.messaging.MessageResult'
    java_import 'xdi2.messaging.target.interceptor.impl.authentication.secrettoken.DigestSecretTokenAuthenticator'
 end

end

require 'csp_provisioner/config'
require 'csp_provisioner/api'