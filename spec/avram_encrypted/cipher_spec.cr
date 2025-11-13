require "../spec_helper"

describe AvramEncrypted::Cipher do
  before_each do
    set_up_default_test_keys
  end

  describe ".encrypt" do
    it "encrypts a string value" do
      encrypted_value = AvramEncrypted::Cipher.encrypt("ssst!")
      encrypted_value.should start_with("v2:")
      encrypted_value.size.should eq(111)
    end

    it "encrypts an integer value" do
      encrypted_value = AvramEncrypted::Cipher.encrypt(123)
      encrypted_value.should start_with("v2:")
      encrypted_value.size.should eq(111)
    end

    it "encrypts a serializable value" do
      value = TestSecretData.new("Pepe", 32)
      encrypted_value = AvramEncrypted::Cipher.encrypt(value)
      encrypted_value.should start_with("v2:")
      encrypted_value.size.should eq(135)
    end
  end

  describe ".decrypt" do
    it "decrypts to a string value" do
      value = "ssst!"
      encrypted_value = AvramEncrypted::Cipher.encrypt(value)
      AvramEncrypted::Cipher.decrypt(encrypted_value).should eq(value)
    end

    it "decrypts to an integer value" do
      value = 213
      encrypted_value = AvramEncrypted::Cipher.encrypt(value)
      AvramEncrypted::Cipher.decrypt(encrypted_value, value.class).should eq(value)
    end

    it "decrypts to a serializable value" do
      value = TestSecretData.new("Pepe", 32)
      encrypted_value = AvramEncrypted::Cipher.encrypt(value)
      decrypted_value = AvramEncrypted::Cipher.decrypt(encrypted_value, value.class)
      decrypted_value.should eq(value)
      decrypted_value.name.should eq("Pepe")
      decrypted_value.age.should eq(32)
    end
  end

  describe ".recrypt" do
    it "re-encrypts a string value" do
      value = "ssst!"
      encrypted_value = AvramEncrypted::Cipher.encrypt(value, key_version: "v1")
      encrypted_value.should start_with("v1:")
      recrypted_value = AvramEncrypted::Cipher.recrypt(encrypted_value)
      recrypted_value.should start_with("v2:")
      decrypted_value = AvramEncrypted::Cipher.decrypt(recrypted_value)
      decrypted_value.should eq(value)
    end

    it "re-encrypts a string value to a given key version" do
      value = "ssst!"
      encrypted_value = AvramEncrypted::Cipher.encrypt(value)
      recrypted_value = AvramEncrypted::Cipher.recrypt(encrypted_value, key_version: "v3")
      recrypted_value.should start_with("v3:")
      decrypted_value = AvramEncrypted::Cipher.decrypt(recrypted_value)
      decrypted_value.should eq(value)
    end

    it "re-encrypts a serializable value" do
      value = TestSecretData.new("Pepe", 32)
      encrypted_value = AvramEncrypted::Cipher.encrypt(value, key_version: "v1")
      encrypted_value.should start_with("v1:")
      recrypted_value = AvramEncrypted::Cipher.recrypt(encrypted_value)
      recrypted_value.should start_with("v2:")
      decrypted_value = AvramEncrypted::Cipher.decrypt(recrypted_value, value.class)
      decrypted_value.should eq(value)
      decrypted_value.name.should eq("Pepe")
      decrypted_value.age.should eq(32)
    end
  end
end

private struct TestSecretData
  include JSON::Serializable

  getter name : String
  getter age : Int32

  def initialize(@name : String, @age : Int32)
  end
end
