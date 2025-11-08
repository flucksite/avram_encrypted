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

  describe ".current_key" do
    it "returns the current encryption key" do
      AvramEncrypted.configure do |settings|
        settings.keys = {
          "20230415" => "abc123",
          "20251108" => "def456",
        }
        settings.key_version = "20251108"
      end

      AvramEncrypted.current_key.should eq("def456")
      AvramEncrypted.temp_config(key_version: "20230415") do
        AvramEncrypted.current_key.should eq("abc123")
      end
    end
  end
end
