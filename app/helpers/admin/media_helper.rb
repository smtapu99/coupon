module Admin
  module MediaHelper

    def protocolize url, protocol = 'http'
      if url.start_with?('http')
        url
      else
        (protocol.gsub('://', '')) + ':' + (url.start_with?('//') ? url : '//'+ url)
      end
    end
  end
end
