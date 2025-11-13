module AvramEncrypted::Operation
  macro encrypted(type_declaration)
    {% name = type_declaration.var %}
    attribute {{type_declaration}}

    before_save do
      encrypted_{{name}}.value = AvramEncrypted::Cipher.encrypt({{name}}.value)
    end
  end
end
