require 'spec_helper'

describe Magensa::Decrypter do
  describe "initializing" do
    it "should set options" do
      decrypter = Magensa::Decrypter.new("username", "password", {my_fave: "this"})
      decrypter.options[:my_fave].should eql("this")
    end

    it "should know its mock state" do
      decrypter = Magensa::Decrypter.new("username", "password")

      decrypter.mock?.should be(false)
      decrypter.options[:mock] = false
      decrypter.mock?.should be(false)
      decrypter.options[:mock] = true
      decrypter.mock?.should be(true)
    end
  end

  describe "setting up the client" do
    it "should create a new Client with default values" do
      decrypter = Magensa::Decrypter.new("username", "password")
      Magensa::Client.should_receive(:new).with({logger: nil, production: true, mock: false})
      decrypter.client
    end
  end

  describe "decrypting" do
    before(:all) do
      @decrypter = Magensa::Decrypter.new("username", "password", {mock: true})
      @valid_params = {
        name: "Steve Jones",
        track: VALID_ENCRYPTION_STRING,
        expiration: "0120"
      }
    end

    it "should accept a string track" do
      response = @decrypter.decrypt(@valid_params)
      good_response_hash = {
        number: "FAKEPAN",
        month: "12",
        year: "13",
        first_name: "FirstName",
        last_name: "LastName"
      }
      response.should eql(good_response_hash)
    end

    it "should accept a hash with tracks" do
      response = @decrypter.decrypt({
          name: "Jones/Steve",
          track1: "QWERTY",
          expiration: "2001",
          track2: VALID_ENCRYPTION_STRING,
          track3: "QWERTY",
          mp: "12325432",
          mpstatus: "2345234",
          ksn: "123345",
          device_sn: "1234446"
        })
      good_response_hash = {
        number: "FAKEPAN",
        month: "01",
        year: "20",
        first_name: "Steve",
        last_name: "Jones"
      }
      response.should eql(good_response_hash)
    end

    it "should return a well formatted hash" do
      
      response = @decrypter.decrypt(@valid_params)
      good_response_hash = {
        number: "FAKEPAN",
        month: "12",
        year: "13",
        first_name: "FirstName",
        last_name: "LastName"
      }
      response.should eql(good_response_hash)
    end

    it "should return a track2 pan if the pan is nil" do
      

      @decrypter.should_receive(:mock_response).and_return({
        decrypt_rsv201_response: {
          decrypt_rsv201_result: {
            track2: ";123456789101112=asdgsfdg",
            pan: nil
          }
        }
      })

      response = @decrypter.decrypt(@valid_params)
      response[:number].should eql("123456789101112")
    end
  end
end