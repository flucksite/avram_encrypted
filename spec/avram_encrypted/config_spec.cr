require "../spec_helper"

describe AvramEncrypted do
  describe ".settings" do
    it "requires at least one encryption key" do
      expect_raises(
        Habitat::InvalidSettingFormatError,
        "At least one encryption key is needed"
      ) do
        AvramEncrypted.settings.keys = {} of String => String
      end
    end

    it "requires that the key version is present in the keys" do
      expect_raises(
        Habitat::InvalidSettingFormatError,
        "The key version 'missing' does not exist"
      ) do
        AvramEncrypted.configure do |settings|
          settings.keys = {"1" => "abc123"}
          settings.key_version = "missing"
        end
      end
    end
  end
end
