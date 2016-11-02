require 'spec_helper'

describe Magensa::V2::Client do
  before do
    ENV['MAGENSA2_CA_FILE']='/etc/magensa/magensa-ca.cert'
    ENV['MAGENSA2_KEY_FILE']='/etc/magensa/magensa.key'
    ENV['MAGENSA2_CERT_FILE']='/etc/magensa/magensa.cert'
    ENV['MAGENSA_ENDPOINT'] = nil
    ENV["MAGENSA2_USER"] ='maguser'
    ENV["MAGENSA2_PASS"] ='magpass'
  end

  describe "initializing" do
    it "should store options" do
      client = Magensa::V2::Client.new({my_fave: "this"})
      client.options[:my_fave].should eql("this")
    end
  end

  describe "options" do

    let(:proper_params){
      {
        raise_errors: false,
        log_level: :herro,
        log: true,
        namespace_identifier: :tem,
        endpoint: "https://decrypt.magensa.net/Decrypt.svc",
        namespace: "http://tempuri.org/",
        env_namespace: :soapenv,
        read_timeout: 15,
        open_timeout: 15,
        convert_request_keys_to: :none,
        namespaces: {"xmlns:dec"=>"http://schemas.datacontract.org/2004/07/Decrypt.Core"},
        ssl_cert_file: '/etc/magensa/magensa.cert',
        ssl_cert_key_file: '/etc/magensa/magensa.key',
        ssl_ca_cert_file: '/etc/magensa/magensa-ca.cert',
        ssl_verify_mode: :peer,
        ssl_version: :TLSv1_2,
        adapter: :net_http

      }
    }
    it "should set logger to log_level if provided" do
      magensa = Magensa::V2::Client.new(production: true, mock: true, log_level: :herro)
      Savon.should_receive(:client).with(proper_params).and_return(double(:client, call: true))
      magensa.transmit("action", {})
    end

  end

  describe "making requests" do
    it "should format the request properly" do
      stub_request(:post, "https://decrypt.magensa.net/Decrypt.svc").to_return(body: fixture('decrypt_response.xml'))
      client = Magensa::V2::Client.new({log_level: :debug})
      resp = client.transmit("DecryptCardSwipe", {"tem:request" => {
                                            "dec:EncryptedCardSwipe" => {"dec:DeviceSN" => "12345"},
                                            "dec:Authentication"=>{
                                              "dec:Password" => 'password',
                                              "dec:Username" => 'username'
                                            }
                                          }
      })

      expect(resp.to_hash.key?(:decrypt_card_swipe_response)).to be_true
    end

  end
end