require "../spec_helper"

describe AvramEncrypted::EncryptedInt32 do
  before_each do
    set_up_default_test_keys
  end

  describe "#to_s" do
    it "returns the encrypted value" do
      encryptor = AvramEncrypted::EncryptedInt32.new(123)
      encryptor.to_s.should eq("123")
    end
  end

  describe "#value" do
    it "returns the encrypted value" do
      encryptor = AvramEncrypted::EncryptedInt32.new("123".to_slice)
      encryptor.value.should eq(123)
    end
  end

  describe AvramEncrypted::EncryptedInt32::Lucky do
    describe ".to_db" do
      it "encrypts the data" do
        encryptor = AvramEncrypted::EncryptedInt32.new(456)
        encrypted_data = AvramEncrypted::EncryptedInt32::Lucky.to_db(encryptor)
        encrypted_data.should start_with("v2:")
        encrypted_data.size.should eq(111)
      end

      it "accepts the raw value" do
        encrypted_data = AvramEncrypted::EncryptedInt32::Lucky.to_db(789)
        encrypted_data.should start_with("v2:")
        encrypted_data.size.should eq(111)
      end
    end

    describe ".from_db!" do
      it "decrypts the data" do
        encrypted_data = AvramEncrypted::EncryptedInt32::Lucky.to_db(123)
        AvramEncrypted::EncryptedInt32::Lucky.from_db!(encrypted_data).value
          .should eq(123)
      end
    end
  end
end
