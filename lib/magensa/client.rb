require 'savon'

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

    def client

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

      client_options = {
        raise_errors: false,
        log_level: options[:log_level] || (production? ? :error : :debug),
        log: true,
        element_form_default: :unqualified,
        namespace_identifier: nil,
        endpoint: endpoint,
        namespace: NAMESPACE,
        env_namespace: :soap,
        read_timeout: 15,
        open_timeout: 15
      }

      client_options[:logger] = options[:logger] if options[:logger]

      @client = Savon.client(client_options.merge(ssl_info))
    end


    def transmit(action, body)
      soap_action = "http://www.magensa.net/#{action}"
      response = client.call(action, soap_action: soap_action, message: body)
    end

    private
      def endpoint
        ENV['MAGENSA_ENDPOINT'] ||
          (production? ? "https://Ns.magensa.net/WSmagensa/service.asmx?op=DecryptRSV201" : "https://ws.magensa.net/WSmagensatest/service.asmx?op=DecryptRSV201")
      end

      def ssl_cert
        {
          ca_file: ENV["MAGENSA_CA_FILE"],
          key_file: ENV["MAGENSA_KEY_FILE"],
          file: ENV["MAGENSA_CERT_FILE"]
        }
      end
  end
end
