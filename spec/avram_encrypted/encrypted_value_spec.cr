require "../spec_helper"

describe AvramEncrypted::EncryptedValue do
  before_each do
    AvramEncrypted.configure do |settings|
      settings.keys = {"v1" => "abc123"}
      settings.key_version = "v1"
    end
  end

  describe "#parse" do
    it "parses the encryption key and data" do
      key, data = AvramEncrypted::EncryptedValue.new("v1:thedata").parse

      key.should eq("abc123")
      data.should eq("thedata")
    end

    it "fails to parse values with and invalid format" do
      expect_raises(
        AvramEncrypted::InvalidEncryptedFormatError,
        "Invalid encrypted format: expected '[version]:[data]' but got 'blobbymcblobsky'"
      ) do
        AvramEncrypted::EncryptedValue.new("blobbymcblobsky").parse
      end
    end

    it "fails to parse values with a non-existant key version" do
      expect_raises(
        AvramEncrypted::InvalidKeyVersionError,
        "Unknown key version: 'one'"
      ) do
        AvramEncrypted::EncryptedValue.new("one:thedata").parse
      end
    end
  end
end
