module Magensa
  module V2
    DECRYPT_ACTION = 'DecryptCardSwipe'.freeze
    SOAP_ACTION    = 'http://tempuri.org/IDecrypt/DecryptCardSwipe'.freeze

    class Decrypter
      attr_accessor :options

      def initialize(username, password, customer_code, options = {})
        @username      = username
        @password      = password
        @customer_code = customer_code
        self.options = options
      end

      # @param [Hash] encrypted_data - card details
      # @return [Hash] The decrypt results in a hash
      def decrypt(encrypted_data)
        encrypted_data = decode_data(encrypted_data)

        if mock?
          return mock_response
        else
          response = client.transmit(DECRYPT_ACTION, request_body(encrypted_data), SOAP_ACTION)
        end
        response_hash(response, encrypted_data)
      end

      private

        def client
          V2::Client.new({
            logger: options[:logger],
            production: options[:production] || false,
            mock: options[:mock] || false,
            log_level: options[:log_level]
          })
        end


        def decode_data(encrypted_hash)
          data = encrypted_hash
          data[:first_name] = data[:name].split("/").last
          data[:last_name] = data[:name].split("/").first
          data[:month], data[:year] = split_date(data[:expiration])
          data
        end

        def mock?
          options[:mock] == true
        end

        def mock_response
          output = {}
          output[:number] = '4111111111111111'
          output[:track1] = "%B4111111111111111^STERLING/JOANNE^99121011445?"
          output[:track2] = ';4111111111111111=20051010000000157?'
          output[:month] = '05'
          output[:year] = '20'
          output[:first_name] = 'JOANNE'
          output[:last_name] = 'STERLING'
          output
        end


        # @returns month, year
        def split_date(split)
          if split
            return split.slice(2,2), split.slice(0,2)
          end
          return nil, nil
        end

        def track2_pan(track2)
          track2.match(/^;(\d+)=/)[1]
        rescue
          nil
        end

        def response_hash(response, encrypted_data)
          output = {}

          if response.success?
            response = response.to_hash[:decrypt_card_swipe_response][:decrypt_card_swipe_result][:decrypted_card_swipe]
            output[:number] = track2_pan(response[:track2])
            output[:track1] = response[:track1]
            output[:track2] = response[:track2]
            output[:month] = encrypted_data[:month]
            output[:year] = encrypted_data[:year]
            output[:first_name] = encrypted_data[:first_name]
            output[:last_name] = encrypted_data[:last_name]
            output
          else

            output[:error] = response.to_hash[:fault][:faultstring]
          end

          output
        end

        def request_body(encrypted_data)
          {
            "tem:request" => {
              "dec:Authentication" => {
                  "dec:CustomerCode" => @customer_code,
                  "dec:Password" => @password,
                "dec:Username" => @username


              },
              "dec:EncryptedCardSwipe" => {
                "dec:DeviceSN" => encrypted_data[:device_sn],
                "dec:KSN" => encrypted_data[:ksn],
                "dec:MagnePrint" => encrypted_data[:mp],
                "dec:MagnePrintStatus" => encrypted_data[:mpstatus],
                "dec:Track1" => encrypted_data[:track1] || "",
                "dec:Track2" => encrypted_data[:track2],
                "dec:Track3" => encrypted_data[:track3] || ""
              }
            }
          }
        end
    end
  end
end