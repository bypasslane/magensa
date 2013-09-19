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
    it "should return a well formatted hash" do
      client = Magensa::Decrypter.new("username", "password", {mock: true})
    end
  end
end