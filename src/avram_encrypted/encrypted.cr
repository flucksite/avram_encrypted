require "lucky"
require "avram"

module AvramEncrypted
  {% for type in [String] %}
    class Encrypted{{type}}
      include Lucky::AllowedInTags

      def self.adapter
        Lucky
      end

      def initialize(@encrypted : {{type}})
      end

      def initialize(encrypted : Slice(UInt8))
        @encrypted = String.new(encrypted)
      end

      def to_s : String
        @encrypted.to_s
      end

      def value : {{type}}
        @encrypted
      end

      def blank?
        to_s.blank?
      end

      module Lucky
        alias ColumnType = String
        include ::Avram::Type

        def from_db!(value : String)
          key, payload = EncryptedValue.new(value).parse
          encryptor = ::Lucky::MessageEncryptor.new(key)
          Encrypted{{type}}.new(encryptor.verify_and_decrypt(payload))
        end

        def parse(value : Encrypted{{type}})
          SuccessfulCast(Encrypted{{type}}).new(value)
        end

        def parse(value)
          SuccessfulCast(Encrypted{{type}}).new(Encrypted{{type}}.new(value))
        end

        def to_db(value : {{type}}) : String
          encrypt_with_version(value.to_s)
        end

        def to_db(value : Encrypted{{type}}) : String
          encrypt_with_version(value.to_s)
        end

        private def encrypt_with_version(plaintext : String) : String
          encryptor = ::Lucky::MessageEncryptor.new(AvramEncrypted.current_key)
          encrypted_data = encryptor.encrypt_and_sign(plaintext)

          "#{AvramEncrypted.settings.key_version}:#{encrypted_data}"
        end

        class Criteria(T, V) < String::Lucky::Criteria(T, V)
          @upper = false
          @lower = false
        end
      end
    end
  {% end %}
end
