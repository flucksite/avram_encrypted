require "../spec_helper"

describe AvramEncrypted::Operation do
  before_each do
    set_up_default_test_keys
  end

  describe ".encrypted macro" do
    it "defines an attribute" do
      op = TestOperation.new(1.79)
      op.height.value.should eq(1.79)
    end

    it "sets the encrypted value before saving" do
      op = TestOperation.new(1.79)
      op.encrypted_height.value.should eq("")
      op.run_before_save
      op.encrypted_height.value.should start_with("v2:")
      op.encrypted_height.value.size.should eq(111)
      AvramEncrypted::Cipher.decrypt(op.encrypted_height.value, Float64).should eq(1.79)
    end
  end
end

private struct TestOperation
  include AvramEncrypted::Operation

  macro attribute(type_declaration)
    {%
      var = type_declaration.var
      type = type_declaration.type
    %}
    getter {{var}} : Attribute({{type}})
    getter encrypted_{{var.id}} : Attribute(String)

    def initialize({{type_declaration}})
      @{{var}} = Attribute({{type}}).new({{var}})
      @encrypted_{{var}} = Attribute(String).new("")
    end
  end

  macro before_save(&block)
    def run_before_save
      {{block.body}}
    end
  end

  struct Attribute(T)
    property value : T

    def initialize(@value : T)
    end
  end

  encrypted height : Float64
end
