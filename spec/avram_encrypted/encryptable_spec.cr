require "../spec_helper"

describe AvramEncrypted::Encryptable do
  before_each do
    set_up_default_test_keys
  end

  describe ".to_db" do
    it "encrypts the data" do
      encryptor = TestSecretData.new("ssst!")
      encrypted_data = TestSecretData::Lucky.to_db(encryptor)
      encrypted_data.should start_with("v2:")
      encrypted_data.size.should eq(135)
    end
  end

  describe ".from_db!" do
    it "decrypts the data" do
      encryptor = TestSecretData.new("ssst!")
      encrypted_data = TestSecretData::Lucky.to_db(encryptor)
      TestSecretData::Lucky.from_db!(encrypted_data).value.should eq(encryptor)
    end
  end
end

private struct TestSecretData
  include AvramEncrypted::Encryptable

  getter very_secret : String

  def initialize(@very_secret : String)
  end
end
