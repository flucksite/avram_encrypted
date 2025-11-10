require "lucky"
require "avram"

module AvramEncrypted::Encryptable
  macro included
    {% target_type = @type.stringify.gsub(/^AvramEncrypted::Encrypted/, "").id %}
    {% is_string = target_type.id == String.id %}
    {% is_internal = @type.stringify.starts_with?("AvramEncrypted::Encrypted") %}

    {% unless is_internal %}
      include ::JSON::Serializable
    {% end %}
    include ::Lucky::AllowedInTags

    def self.adapter
      Lucky
    end

    def initialize(encrypted : Slice(UInt8))
      initialize(String.new(encrypted))
    end

    {% if is_internal %}
      getter value : {{target_type}}

      def initialize(@value : {{target_type}})
      end

      def initialize(value : String)
        {% if is_string %}
          @value = value
        {% else %}
          @value = {{target_type}}.from_json(value)
        {% end %}
      end

      def to_s : String
        @value{% unless is_string %}.to_json{% end %}
      end
    {% else %}
      def initialize(value : String)
        initialize(JSON::PullParser.new(value))
      end

      def to_s : String
        to_json
      end

      def value : {{@type}}
        self
      end
    {% end %}

    {% if is_string %}
      def blank? : Bool
        to_s.blank?
      end
    {% end %}

    module Lucky
      alias ColumnType = String
      include ::Avram::Type

      def from_db!(value : String)
        {{@type}}.new(decrypt_with_version(value))
      end

      def parse(value : {{@type}})
        SuccessfulCast({{@type}}).new(value)
      end

      def parse(value)
        SuccessfulCast({{@type}}).new({{@type}}.new(value))
      end

      {% if is_internal %}
        def to_db(value : {{target_type}}) : String
          to_db({{@type}}.new(value))
        end
      {% end %}

      def to_db(value : {{@type}}) : String
        encrypt_with_version(value.to_s)
      end

      private def encrypt_with_version(plaintext : String) : String
        encryptor = ::Lucky::MessageEncryptor.new(AvramEncrypted.current_key)
        encrypted_data = encryptor.encrypt_and_sign(plaintext)

        "#{AvramEncrypted.settings.key_version}:#{encrypted_data}"
      end

      private def decrypt_with_version(value : String)
        key, payload = AvramEncrypted::EncryptedValue.new(value).parse
        encryptor = ::Lucky::MessageEncryptor.new(key)
        encryptor.verify_and_decrypt(payload)
      end

      class Criteria(T, V) < String::Lucky::Criteria(T, V)
        @upper = false
        @lower = false
      end
    end
  end
end
