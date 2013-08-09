module CspProvisioner
  module Config
    CSP_CLOUD_NUMBER = XDI::XDI3Segment.create("[@]!:uuid:f34559e4-6b2b-d962-f345-59e46b2bd962")
    CSP_SECRET_TOKEN = "ofniruoynwo"
    CSP_GLOBAL_SALT = "8b46d9b1-efff-4f7b-8cc2-2d41c8ac8d32"
    
    RESPECT_NETWORK_REGISTRAR_XDI_ENDPOINT = "http://mycloud.neustar.biz:12230/"
    RESPECT_NETWORK_CLOUD_NUMBER = XDI::XDI3Segment.create("[@]!:uuid:299089fd-9d81-3c59-2990-89fd9d813c59")
    
    NEUSTAR_HOSTING_ENVIRONMENT_XDI_ENDPOINT = "http://clouds.ownyourinfo.com:14440/ownyourinfo-registry"
    NEUSTAR_HOSTING_ENVIRONMENT_CLOUDS_BASE = "http://clouds.ownyourinfo.com:14440/ownyourinfo-users/"
  end
end