require 'spec_helper'

describe Magensa::V2::Decrypter do
  describe "initializing" do
    it "should set options" do
      decrypter = Magensa::V2::Decrypter.new("username", "password", "cust-code", {my_fave: "this"})
      decrypter.options[:my_fave].should eql("this")
    end

    it "should know its mock state" do
      decrypter = Magensa::V2::Decrypter.new("username", "password", "cust-code")

      decrypter.mock?.should be(false)
      decrypter.options[:mock] = false
      decrypter.mock?.should be(false)
      decrypter.options[:mock] = true
      decrypter.mock?.should be(true)
    end
  end

  describe "setting up the client" do
    it "should create a new Client with default values" do
      decrypter = Magensa::V2::Decrypter.new("username", "password", "cust-code")
      Magensa::V2::Client.should_receive(:new).with({logger: nil, production: false, mock: false, log_level: nil})
      decrypter.client
    end

    it "should pass production true to the client if options production is true" do
      decrypter = Magensa::V2::Decrypter.new("username", "password", "cust-code", {production: true})
      Magensa::V2::Client.should_receive(:new).with({logger: nil, production: true, mock: false, log_level: nil})
      decrypter.client
    end
  end

  describe "decrypting" do
    before do
      @decrypter = Magensa::V2::Decrypter.new("username", "password", "cust-code", {mock: false})
      @valid_params = {
        device_sn: "B25B262042214AA",
        ksn: "9011880B25B2620001EB",
        mp: "C0D82B45BCC642BE085E1C0D82B45BCC642BE085E1C0D82B45BCC642BE085E1",
        mpstatus: "99903000",
        track2: "9BA71B8989BA71B898",
        expiration:"2005",
        name:"JOHAPPY/ SLAPPY"
      }

    end

    it "should accept a hash with tracks" do
      decrypter = Magensa::V2::Decrypter.new("username", "password", "cust-code", {mock: true})
      response = decrypter.decrypt(@valid_params)

      good_response_hash = {
        number: "4111111111111111",
        track2: ";4111111111111111=20051010000000157?",
        track1: "%B4111111111111111^STERLING/JOANNE^99121011445?",
        month: "05",
        year: "20",
        first_name: "JOANNE",
        last_name: "STERLING"
      }
      response.should eql(good_response_hash)
    end

    it "should return a track2 pan if the pan is nil" do
      decrypter = Magensa::V2::Decrypter.new("username", "password", "cust-code", {mock: true})
      response = decrypter.decrypt(@valid_params)
      response[:number].should eql("4111111111111111")
    end

    it "should parse the response properly" do
      stub_request(:post, /Decrypt.svc/).to_return(body: fixture('decrypt_response.xml'))
      response = @decrypter.decrypt(@valid_params)

      expect(response[:number]).to eql('9999991234567891')
    end

    describe "with invalid data" do
      it "should notify the caller" do
        stub_request(:post, /Decrypt.svc/).to_return(body: fixture('invalid_decrypt_response.xml'))
        decrypter = Magensa::V2::Decrypter.new("username", "password", {mock: false})
        response = decrypter.decrypt({name: ""})
        expect(response[:number]).to be_nil
      end
    end

    describe "failure" do
      it "should return an error message" do
        stub_request(:post, /Decrypt.svc/).to_return(body: fixture('failed_response.xml'))
        decrypter = Magensa::V2::Decrypter.new("username", "password", {mock: false})
        response = decrypter.decrypt({name: ""})

        expect(response[:error]).to_not be_nil
      end
    end
  end
end