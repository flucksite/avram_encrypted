require "json"

module AvramEncrypted::Model
  macro setup_encrypted_getter(type_declaration)
    {%
      var = type_declaration.var
      type = type_declaration.type

      unless type.resolve.has_method?(:to_json)
        raise <<-ERROR
          #{type} does not implement #to_json which is a requirement.
          You can include the JSON::Serializable module to fix this.

          Example:
            struct #{type}
              include JSON::Serializable
            end
          ERROR
      end
    %}

    def {{type_declaration}}
      return @{{var.id}} if encrypted_{{var.id}}.nil?

      AvramEncrypted::Cipher.decrypt(encrypted_{{var.id}}.to_s{% if type.id != String.id %}, type: {{type}}{% end %})
    end
  end

  macro encrypted(type_declaration)
    column encrypted_{{type_declaration.var}} : String? = nil

    {{@type}}.setup_encrypted_getter({{type_declaration}})
  end
end
