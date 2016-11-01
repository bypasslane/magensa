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

    it "should set logger to log_level if provided" do
      magensa = Magensa::Client.new(production: true, mock: true, log_level: :herro)
      Savon.should_receive(:client).with({
        raise_errors: false,
        log_level: :herro,
        log: true,
        element_form_default: :unqualified,
        namespace_identifier: nil,
        endpoint: "https://Ns.magensa.net/WSmagensa/service.asmx?op=DecryptRSV201",
        namespace: "http://www.magensa.net/",
        env_namespace: :soap,
        read_timeout: 15,
        open_timeout: 15,
        ssl_cert_file: nil,
        ssl_cert_key_file: nil,
        ssl_ca_cert_file: nil,
        ssl_verify_mode: :peer
      }).and_return(nil)
      magensa.client
    end

    it "should set logger to error if production" do
      magensa = Magensa::Client.new(production: true, mock: true)
      Savon.should_receive(:client).with({
        raise_errors: false,
        log_level: :error,
        log: true,
        element_form_default: :unqualified,
        namespace_identifier: nil,
        endpoint: "https://Ns.magensa.net/WSmagensa/service.asmx?op=DecryptRSV201",
        namespace: "http://www.magensa.net/",
        env_namespace: :soap,
        read_timeout: 15,
        open_timeout: 15,
        ssl_cert_file: nil,
        ssl_cert_key_file: nil,
        ssl_ca_cert_file: nil,
        ssl_verify_mode: :peer
      }).and_return(nil)
      magensa.client
    end

    it "should set the endpoint if passed in" do
      ENV['MAGENSA_ENDPOINT'] = 'http://magensarules.com'
      magensa = Magensa::Client.new(production: true, mock: true, log_level: :herro)
      Savon.should_receive(:client).with({
        raise_errors: false,
        log_level: :herro,
        log: true,
        element_form_default: :unqualified,
        namespace_identifier: nil,
        endpoint: "http://magensarules.com",
        namespace: "http://www.magensa.net/",
        env_namespace: :soap,
        read_timeout: 15,
        open_timeout: 15,
        ssl_cert_file: nil,
        ssl_cert_key_file: nil,
        ssl_ca_cert_file: nil,
        ssl_verify_mode: :peer
      }).and_return(nil)
      magensa.client
    end
  end
end