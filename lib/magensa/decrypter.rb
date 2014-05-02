module Magensa
  DECRYPT_ACTION = "DecryptRSV201"

  TRACK2_INDEX = 3
  MP_INDEX = 6
  MPSTATUS_INDEX = 5
  DEVICESN_INDEX = 7
  KSN_INDEX = 9

  class Decrypter
    attr_accessor :options

    def initialize(username, password, options = {})
      @hostID = username
      @hostPwd = password
      self.options = options
    end

    def mock?
      options[:mock] == true
    end

    def decrypt(encrypted_data)

      encrypted_data = encrypted_data[:track] ? self.class.parse(encrypted_data[:track]) : self.class.validate_data(encrypted_data)
      
      if mock?
        response = mock_response
      else
        response = client.transmit(DECRYPT_ACTION, request_body(encrypted_data)).to_hash
      end
      response_hash(response, encrypted_data)
    end

    def mock_response
      {
        decrypt_rsv201_response: {
          decrypt_rsv201_result: {
            track2: "FAKETRACK2",
            pan: "FAKEPAN"
          }
        }
      }
    end

    def client
      @client ||= Client.new({
        logger: options[:logger],
        production: options[:production] || false,
        mock: options[:mock] || false,
        log_level: options[:log_level]
      })
    end

    def self.validate_data(encrypted_hash)
      data = encrypted_hash
      data[:first_name] = data[:name].split("/").last
      data[:last_name] = data[:name].split("/").first
      if data[:expiration]
        data[:month] = data[:expiration].slice(2,2)
        data[:year] = data[:expiration].slice(0,2)
      end
      data
    end

    def self.parse(encrypted_string)
      parse_array = encrypted_string.split('|')
      data = {
        track2:    parse_array[TRACK2_INDEX],
        mpstatus:  parse_array[MPSTATUS_INDEX],
        mp:        parse_array[MP_INDEX],
        device_sn: parse_array[DEVICESN_INDEX],
        ksn:       parse_array[KSN_INDEX]
      }

      self.add_unencrypted(data, encrypted_string)
    end

    private

      # parse encrypted_string for the unencrypted fields and adds to data
      def self.add_unencrypted(data, encrypted_string)
        split = encrypted_string.slice(2, encrypted_string.length-2).split("^")
        if split[0]
          data[:brand_identifier] = split[0]
          data[:last_four_digits] = split[0].slice(-4, 4)
        end

        if split[1]
          data[:first_name] = split[1].split("/").last
          data[:last_name] = split[1].split("/").first
        end

        if split[2]
          data[:month] = split[2].slice(2,2)
          data[:year] = split[2].slice(0,2)
        end
        data
      end

      def track2_pan(track2)
        track2.match(/^;(\d+)=/)[1]
      rescue
        nil
      end

      def response_hash(response, encrypted_data)
        response = response.to_hash[:decrypt_rsv201_response][:decrypt_rsv201_result]
        output = {}
        output[:number] = response[:pan] || track2_pan(response[:track2])
        output[:track2] = response[:track2]
        output[:month] = encrypted_data[:month]
        output[:year] = encrypted_data[:year]
        output[:first_name] = encrypted_data[:first_name]
        output[:last_name] = encrypted_data[:last_name]
        output
      end

      def request_body(encrypted_data)
        {
          "DecryptRSV201_Input" => {
            "EncTrack2" => encrypted_data[:track2],
            "EncTrack1" => encrypted_data[:track1],
            "EncTrack3" => encrypted_data[:track3],
            "EncMP" => encrypted_data[:mp],
            "KSN" => encrypted_data[:ksn],
            "DeviceSN" => encrypted_data[:device_sn],
            "MPStatus" => encrypted_data[:mpstatus],
            "CustTranID" => options[:ref_id],
            "HostID" => @hostID,
            "HostPwd" => @hostPwd,
            "OutputFormatCode" => "103",
            "CardType" => "1",
            "EncryptionBlockType" => "1",
            "RegisteredBy" => "BypassLane",
            "FutureInput" => "",
            :order! => ["EncTrack1", "EncTrack2", "EncTrack3", "EncMP", "KSN", "DeviceSN", "MPStatus", "CustTranID", "HostID", "HostPwd", "OutputFormatCode", "CardType", "EncryptionBlockType", "RegisteredBy", "FutureInput"]
          }
        }
      end
  end
end