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
      client = Magensa::Client.new()

      client.production?.should be(true)
      client.options[:production] = false
      client.production?.should be(false)
      client.options[:production] = true
      client.production?.should be(true)
    end
  end
end