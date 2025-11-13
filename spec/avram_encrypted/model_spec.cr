require "../spec_helper"
require "json"

describe AvramEncrypted::Model do
  before_each do
    set_up_default_test_keys
  end

  describe ".encrypted macro" do
    it "creates a getter" do
      data = TestModel::SecretData.new(32)
      model = TestModel.new(name: "Nina", data: data)
      model.name.should eq("Nina")
    end

    it "creates an encrypted column" do
      data = TestModel::SecretData.new(32)
      model = TestModel.new(name: "Nina", data: data)
      model.encrypted_name.should be_nil
    end

    it "decrypts the encrypted value" do
      data = TestModel::SecretData.new(32)
      model = TestModel.new(name: "Nina", data: data)
      model.encrypted_name = AvramEncrypted::Cipher.encrypt("Dot")
      model.encrypted_data = AvramEncrypted::Cipher.encrypt(TestModel::SecretData.new(54))
      model.name.should eq("Dot")
      model.data.age.should eq(54)
    end
  end
end

private struct TestModel
  include AvramEncrypted::Model

  setter encrypted_name : String
  setter encrypted_data : String

  def initialize(@name : String, @data : SecretData)
  end

  macro column(type_declaration)
    getter {{type_declaration}}
  end

  struct SecretData
    include JSON::Serializable

    getter age : Int32

    def initialize(@age : Int32)
    end
  end

  encrypted name : String
  encrypted data : SecretData
end
