module Magensa
  NAMESPACE = "http://www.magensa.net/"

  class Client
    attr_accessor :options

    def initialize(options = {})
      self.options = options
    end

    def production?
      options[:production] == true || options[:production] == nil
    end

    def mock?
      options[:mock] == true
    end

    def client
      return @client if @client

      ssl_info = {}
      if production?
        ssl_info = {
          ssl_cert_file: ssl_cert[:file],
          ssl_cert_key_file: ssl_cert[:key_file],
          ssl_ca_cert_file: ssl_cert[:ca_file],
          ssl_verify_mode: :peer
        }
      else
        ssl_info = {
          ssl_verify_mode: :none
        }
      end

      @client = Savon.client({
        raise_errors: false,
        logger: options[:logger],
        log_level: :debug,
        log: true,
        element_form_default: :unqualified,

        namespace_identifier: nil,
        endpoint: url,
        namespace: NAMESPACE,
        env_namespace: :soap,

        read_timeout: 360,
        open_timeout: 360
      }.merge(ssl_info))
    end
  end

  def transmit(action, body)
    if mock?
      response = client.call(action, soap_action: 'http://www.magensa.net/#{action}', message: body)
      response.to_hash[:decrypt_rsv201_response][:decrypt_rsv201_result]
    else
    end
  end

  private
    def url
      production? ? "https://Ns.magensa.net/WSmagensa/service.asmx?op=DecryptRSV201" : "https://ws.magensa.net/WSmagensatest/service.asmx?op=DecryptRSV201"
    end

    def ssl_cert
        {
          ca_file: ENV["MAGENSA_CA_FILE"],
          key_file: ENV["MAGENSA_KEY_FILE"],
          file: ENV["MAGENSA_CERT_FILE"]
        }
      end
end