require "../spec_helper"

describe AvramEncrypted::Encrypted do
  before_each do
    AvramEncrypted.configure do |settings|
      settings.keys = {
        "v1" => "EnjmNNd/Wg",
        "v2" => "WFRN364zJA",
        "v3" => "yacNMiqag1",
      }
      settings.key_version = "v2"
    end
  end

  describe "#to_s" do
    it "returns the encrypted value" do
      encryptor = AvramEncrypted::Encrypted(String).new("thedata")
      encryptor.to_s.should be("thedata")
    end
  end

  describe "#value" do
    it "returns the encrypted value" do
      encryptor = AvramEncrypted::Encrypted(String).new("thedata")
      encryptor.value.should be("thedata")
    end
  end

  describe "#blank?" do
    it "tests the blankness of the encrypted value" do
      encryptor = AvramEncrypted::Encrypted(String).new("thedata")
      encryptor.blank?.should be_falsey
      encryptor = AvramEncrypted::Encrypted(String).new("")
      encryptor.blank?.should be_truthy
    end
  end

  describe AvramEncrypted::Encrypted::Lucky do
    describe ".to_db" do
      encryptor = AvramEncrypted::Encrypted(String).new("thedata")
      encrypted_data = AvramEncrypted::Encrypted(String)::Lucky.to_db(encryptor)
      encrypted_data.should eq("xxx")
    end
  end
end
