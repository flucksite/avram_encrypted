require "lucky"
require "avram"

module AvramEncrypted
  alias StringEncrypted = Encrypted(String)

  class Encrypted(T)
    include Lucky::AllowedInTags

    def self.adapter
      Lucky
    end

    def initialize(@encrypted : T)
    end

    def initialize(encrypted : Slice(UInt8))
      @encrypted = String.new(encrypted)
    end

    def to_s : String
      @encrypted.to_s
    end

    def value : T
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
        decrypted = encryptor.verify_and_decrypt(payload)

        Encrypted(T).new(decrypted.as(T))
      end

      def parse(value : Encrypted(T))
        SuccessfulCast(Encrypted(T)).new(value)
      end

      def parse(value)
        SuccessfulCast(Encrypted(T)).new(Encrypted(T).new(value))
      end

      def to_db(value : T) : String
        encrypt_with_version(value.to_s)
      end

      def to_db(value : Encrypted(T)) : String
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
end
