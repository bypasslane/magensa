require 'spec_helper'

describe "decrypting" do
  context "passing in production" do
    it "has a value of true in client.production?" do
      decrypter = Magensa::Decrypter.new("username", "password", {ref_id: "sdfgfsd", production: true})
      decrypter.send(:client).production?.should be(true)
    end
  end
end