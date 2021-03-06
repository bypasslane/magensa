require 'simplecov'
SimpleCov.start

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'magensa'
require 'magensa/client'
require 'webmock/rspec'

VALID_ENCRYPTION_STRING = "%B5454540005005454^LastName/FirstName^1312000000000000000000000000000?;5454540005005454=13120000000000000000?|0600|1112163EF471656ECDB7BAB8C43FDF3AF196032C88D02DFB3B0BF29440D1B2DE2D1954E424272717AA87DC4E78FEC07C9560F441785C2226D401B87C44E583BDA64B0184F2671EFE|THISISTRACK2||MPSTATUS|MPDATA|DEVICE_SN|05985FFB3222C539|KSN|5E81||1000"

RSpec.configure do |config|

  def fixture_path
    File.expand_path("../fixtures", __FILE__)
  end

  def fixture(file)
    File.read(fixture_path + '/' + file)
  end
end
