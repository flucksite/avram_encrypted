require "json"
require "lucky/support/message_encryptor"

module AvramEncrypted::Cipher
  extend self

  # Encrypts a string value.
  def encrypt(
    value : String,
    keys : Hash(String, String) = AvramEncrypted.settings.keys,
    key_version : String = AvramEncrypted.settings.key_version,
  ) : String
    String.build do |io|
      encryptor = ::Lucky::MessageEncryptor.new(keys[key_version])
      io << key_version << ":" << encryptor.encrypt_and_sign(value)
    end
  end

  # Encrypts any value that responds to `.to_json`.
  def encrypt(value, **named_args) : String
    encrypt(value.to_json, **named_args)
  end

  # Decrypts an encrypted string.
  def decrypt(
    encrypted : String,
    keys : Hash(String, String) = AvramEncrypted.settings.keys,
  ) : String
    key, payload = AvramEncrypted::EncryptedValue.new(encrypted, keys).parse
    encryptor = ::Lucky::MessageEncryptor.new(key)
    String.new(encryptor.verify_and_decrypt(payload))
  end

  # Decrypts an encrypted string and casts it to the desired type leveraging
  # Crystal's `JSON::PullParser`.
  def decrypt(
    encrypted : String,
    type : Class,
    keys : Hash(String, String) = AvramEncrypted.settings.keys,
  )
    type.from_json(decrypt(encrypted, keys: keys))
  end

  # Decrypts and re-encrypts an encrypted string it using the given or most
  # recent key version.
  def recrypt(
    encrypted : String,
    keys : Hash(String, String) = AvramEncrypted.settings.keys,
    key_version : String = AvramEncrypted.settings.key_version,
  ) : String
    encrypt(decrypt(encrypted, keys: keys), keys, key_version)
  end
end
