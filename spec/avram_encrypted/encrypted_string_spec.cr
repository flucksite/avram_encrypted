require "../spec_helper"

describe AvramEncrypted::EncryptedString do
  before_each do
    set_up_default_test_keys
  end

  describe "#to_s" do
    it "returns the encrypted value" do
      encryptor = AvramEncrypted::EncryptedString.new("thedata")
      encryptor.to_s.should be("thedata")
    end
  end

  describe "#value" do
    it "returns the encrypted value" do
      encryptor = AvramEncrypted::EncryptedString.new("thedata")
      encryptor.value.should be("thedata")
    end
  end

  describe "#blank?" do
    it "tests the blankness of the encrypted value" do
      encryptor = AvramEncrypted::EncryptedString.new("thedata")
      encryptor.blank?.should be_falsey
      encryptor = AvramEncrypted::EncryptedString.new("")
      encryptor.blank?.should be_truthy
    end
  end

  describe AvramEncrypted::EncryptedString::Lucky do
    describe ".to_db" do
      set_up_default_test_keys
      encryptor = AvramEncrypted::EncryptedString.new("thedata")
      encrypted_data = AvramEncrypted::EncryptedString::Lucky.to_db(encryptor)
      encrypted_data.should start_with("v2:")
      encrypted_data.size.should eq(111)
      AvramEncrypted::EncryptedString::Lucky.from_db!(encrypted_data).value
        .should eq("thedata")
    end
  end
end
