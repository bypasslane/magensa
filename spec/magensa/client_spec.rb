require 'spec_helper'

describe Magensa::Client do
  describe "initializing" do
    it "should store options" do
      client = Magensa::Client.new({my_fave: "this"})
      client.options[:my_fave].should eql("this")
    end
  end

  describe "options" do

    it "should know its production state" do
      client = Magensa::Client.new

      client.production?.should be(true)
      client.options[:production] = false
      client.production?.should be(false)
      client.options[:production] = true
      client.production?.should be(true)
    end

    it "should receive a default production state" do
      client = Magensa::Client.new(production: true)
      client.production?.should be(true)
    end

    it "should set ssl options if production" do
      magensa = Magensa::Client.new(production: true, mock: true)
      magensa.should_receive(:ssl_cert).exactly(3).times.and_return({:key_file => "/var/www/bypass/production/shared/magensa.key", :file => "/var/www/bypass/production/shared/magensa.cert"})
      magensa.client
    end
  end
end