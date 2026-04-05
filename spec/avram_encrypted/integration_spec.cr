require "../spec_helper"
require "json"

class EncryptedUser < BaseModel
  include AvramEncrypted::Model

  skip_schema_enforcer

  struct SecretData
    include JSON::Serializable

    getter ip_address : String
    getter otp_secret : String

    def initialize(@ip_address : String, @otp_secret : String)
    end
  end

  table do
    encrypted name : String                           # ameba:disable Lint/UselessAssign
    encrypted secret_data : EncryptedUser::SecretData # ameba:disable Lint/UselessAssign
  end
end

class SaveEncryptedUser < EncryptedUser::SaveOperation
  encrypted name : String # ameba:disable Lint/UselessAssign
end

describe "Integration with Avram models" do
  before_each do
    set_up_default_test_keys
  end

  describe "model" do
    it "decrypts a string column" do
      encrypted_name = AvramEncrypted::Cipher.encrypt("Alice")
      user = EncryptedUser.new(
        id: 1_i64,
        created_at: Time.utc,
        updated_at: Time.utc,
        encrypted_name: encrypted_name,
        encrypted_secret_data: "",
      )

      user.name.should eq("Alice")
    end

    it "decrypts a serializable column" do
      data = EncryptedUser::SecretData.new("10.0.0.1", "JBSWY3DPEHPK3PXP")
      encrypted_data = AvramEncrypted::Cipher.encrypt(data)
      user = EncryptedUser.new(
        id: 1_i64,
        created_at: Time.utc,
        updated_at: Time.utc,
        encrypted_name: "",
        encrypted_secret_data: encrypted_data,
      )

      user.secret_data.try(&.ip_address).should eq("10.0.0.1")
      user.secret_data.try(&.otp_secret).should eq("JBSWY3DPEHPK3PXP")
    end

    it "caches decrypted values" do
      encrypted_name = AvramEncrypted::Cipher.encrypt("Alice")
      user = EncryptedUser.new(
        id: 1_i64,
        created_at: Time.utc,
        updated_at: Time.utc,
        encrypted_name: encrypted_name,
        encrypted_secret_data: "",
      )

      user.name.should eq("Alice")
      user.name.should eq("Alice") # second call uses cache
    end

    it "returns nil when encrypted column is empty" do
      user = EncryptedUser.new(
        id: 1_i64,
        created_at: Time.utc,
        updated_at: Time.utc,
        encrypted_name: "",
        encrypted_secret_data: "",
      )

      user.name.should be_nil
      user.secret_data.should be_nil
    end
  end

  describe "operation" do
    it "creates a SaveOperation with encrypted attributes" do
      op = SaveEncryptedUser.new
      op.responds_to?(:name).should be_true
      op.responds_to?(:encrypted_name).should be_true
    end
  end
end
