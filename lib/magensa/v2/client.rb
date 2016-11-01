require 'savon'

module Magensa
  module V2

    NAMESPACE = "http://tempuri.org/"
    NAMESPACE2 = "http://schemas.datacontract.org/2004/07/Decrypt.Core"

    class Client
      attr_accessor :options

      def initialize(options = {})
        self.options = options
      end

      def production?
        options[:production] == true || options[:production] == nil
      end

      def client

        ssl_info = {
          ssl_cert_file: ssl_cert[:file],
          ssl_cert_key_file: ssl_cert[:key_file],
          ssl_ca_cert_file: ssl_cert[:ca_file],
          ssl_version: :TLSv1_2,
          ssl_verify_mode: :peer,
          adapter: :net_http
        }

        client_options = {
          raise_errors: false,
          log_level: options[:log_level] || (production? ? :error : :debug),
          log: true,
          namespace_identifier: :tem,
          endpoint: endpoint,
          namespace: NAMESPACE,
          env_namespace: :soapenv,
          read_timeout: 15,
          open_timeout: 15,
          convert_request_keys_to: :none,
          namespaces: {"xmlns:dec" => NAMESPACE2}
        }

        client_options[:logger] = options[:logger] if options[:logger]
        @client = Savon.client(client_options.merge(ssl_info))
      end


      def transmit(action, body, soap_action = nil)
        client.call(action, message: body, soap_action: soap_action)
      end

      private
        def endpoint
          ENV['MAGENSA2_ENDPOINT'] ||
            (production? ? "https://decrypt.magensa.net/Decrypt.svc" : URI.escape("https://decrypt-pilot.magensa.net/Decrypt.svc"))
        end

        def ssl_cert
          {
            ca_file: ENV["MAGENSA2_CA_FILE"],
            key_file: ENV["MAGENSA2_KEY_FILE"],
            file: ENV["MAGENSA2_CERT_FILE"]
          }
        end
    end
  end
end
