require "../spec_helper"

describe AvramEncrypted::EncryptedString do
  before_each do
    set_up_default_test_keys
  end

  describe "#to_s" do
    it "returns the encrypted value" do
      encryptor = AvramEncrypted::EncryptedString.new("thedata")
      encryptor.to_s.should eq("thedata")
    end
  end

  describe "#value" do
    it "returns the encrypted value" do
      encryptor = AvramEncrypted::EncryptedString.new("thedata".to_slice)
      encryptor.value.should eq("thedata")
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
      it "encrypts the data" do
        encryptor = AvramEncrypted::EncryptedString.new("thedata")
        encrypted_data = AvramEncrypted::EncryptedString::Lucky.to_db(encryptor)
        encrypted_data.should start_with("v2:")
        encrypted_data.size.should eq(111)
      end

      it "accepts the raw value" do
        encrypted_data = AvramEncrypted::EncryptedString::Lucky.to_db("thedata")
        encrypted_data.should start_with("v2:")
        encrypted_data.size.should eq(111)
      end
    end

    describe ".from_db!" do
      it "decrypts the data" do
        encrypted_data = AvramEncrypted::EncryptedString::Lucky.to_db("thedata")
        AvramEncrypted::EncryptedString::Lucky.from_db!(encrypted_data).value
          .should eq("thedata")
      end
    end
  end
end
