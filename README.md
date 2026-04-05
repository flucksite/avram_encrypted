# AvramEncrypted

[![CI](https://codeberg.org/fluck/avram_encrypted/actions/workflows/ci.yml/badge.svg)](https://codeberg.org/fluck/avram_encrypted/actions?workflow=ci.yml)
[![Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fcodeberg.org%2Fapi%2Fv1%2Frepos%2Ffluck%2Favram_encrypted%2Ftags&query=%24%5B0%5D.name&label=version)](https://codeberg.org/fluck/avram_encrypted/tags)

Encrypted columns for [Avram](https://github.com/luckyframework/avram)
supporting multiple types and automatic key rotation. Stores sensitive data
encrypted in the database leveraging Lucky's built-in `MessageEncryptor`
(AES-256-CBC). Key rotation is supported out of the box, so old data remains
readable while new saves use your current encryption key.

> [!Note]
> The original repository is hosted at
> [https://codeberg.org/fluck/avram_encrypted](https://codeberg.org/fluck/avram_encrypted).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     avram_encrypted:
       codeberg: fluck/avram_encrypted
   ```

2. Run `shards install`

## Configuration

1. Include the shard in your `shards.cr` file:

   ```crystal
   # src/shards.cr

   # ...
   require "avram_encrypted"
   ```

2. Configure the keys:

   ```crystal
   # config/avram_encrypted.cr

   AvramEncrypted.configure do |settings|
     settings.keys = {
       "v1" => "EnjmNNd/WgF9b9cm3ObR+9cYPHQ7G7lIiUL/pShKWP0=",
     }
     settings.key_version = "v1"
   end
   ```

   > [!TIP]
   > Use the `lucky gen.secret_key` command to generate a new key.

3. Add the database column with the `encrypted_` prefix:

   ```crystal
   alter table_for(User) do
     add encrypted_secret_value : String
   end
   ```

   > [!NOTE]
   > If you want to do batch key rotation, you'll also need to add an index to
   > the database column so that values encrypted with an older key can be
   > looked up efficiently: `add encrypted_secret_value : String, index: true`.

## Usage

1. Include the `AvramEncrypted::Model` mixin and define the encrypted column in
   your model:

   ```crystal
   # src/models/user.cr

   class User < BaseModel
     include AvramEncrypted::Model

     table do
       encrypted secret_value : String
     end
   end
   ```

2. Define the encrypted column in your operations where you want to update it:

   ```crystal
   # src/operations/save_user.cr

   class SaveUser < User::SaveOperation
     encrypted secret_value : String
   end
   ```

> [!WARNING]
> Encrypted columns cannot be queried or filtered on. Since the encrypted value
> is an opaque string, queries like the following will not work as expected:
>
> ```crystal
> # This will NOT find the user by their secret value:
> UserQuery.new.encrypted_secret_value("v2:...")
> ```
>
> If you need to search or filter on a value, consider storing a separate
> non-sensitive identifier or a hashed version of the value in a plain column.

### Supported types

Every standard column type in Avram is supported out of the box, so you can
encrypt whichever type you want, as long as it implements `#to_json` and
`.from_json`.

It's also possible to encrypt complete objects. Since the encrypted data can't
be queried, it's actually a more efficient way to store encrypted data than
creating individual columns.

This works by creating a struct and including `JSON::Serializable`:

```crystal
class User < BaseModel
  include AvramEncrypted::Model

  table do
    # ...
    encrypted secret_data : SecretData
  end

  struct SecretData
    include JSON::Serializable

    getter ip_address : String
    getter otp_secret : String

    def initialize(@ip_address : String, @otp_secret : String)
    end
  end
end
```

Then those details can be accessed as expected:

```crystal
user = UserQuery.find(1)
user.secret_data.ip_address
# => 123.45.67.89
```

> [!NOTE]
> This shard leverages Crystal's JSON pull-parser to stringify values before
> encrypting them, and the other way around. That's why any class or struct
> that implements `#to_json` and `.from_json` (through `JSON::Serializable`)
> will work.

### Encrypting, decrypting, and "recrypting" manually

The underlying methods to `encrypt`, `decrypt`, or `recrypt` are also directly
accessible. These may come in handy if you need to build custom behaviour or
rotate encryption keys.

To encrypt a value:

```crystal
encrypted_string = AvramEncrypted::Cipher.encrypt("ssst!")
# => "v1:X7yHkoP..."

# or an integer
encrypted_int = AvramEncrypted::Cipher.encrypt(123)

# or a custom object
struct SecretData
  include JSON::Serializable

  getter otp_secret : String

  def initialize(@otp_secret)
  end
end

encrypted_object = AvramEncrypted::Cipher.encrypt(SecretData.new("xxx"))
```

To decrypt a value:

```crystal
decrypted_string = AvramEncrypted::Cipher.decrypt(encrypted_string)
# => "ssst!"

decrypted_int = AvramEncrypted::Cipher.decrypt(encrypted_int, Int32)
# => 123

decrypted_object = AvramEncrypted::Cipher.decrypt(encrypted_object, SecretData)
# => SecretData(...)
```

After adding a new encryption key, you'll need to re-encrypt all existing data.
That's where the `recrypt` method comes in:

```crystal
user = UserQuery.find(1)
user.encrypted_otp_secret
# => "v1:X4yTkoR..."

AvramEncrypted::Cipher.recrypt(user.encrypted_otp_secret)
# => "v2:Y2yGkoY..."
```

> [!NOTE]
> When re-encrypting, you never need to pass the type. This method will never
> parse the value to the original type. It will just re-encrypt the serialized
> value directly.

So a re-encryption operation may look like this:

```crystal
class RecryptUserOtpSecret < User::SaveOperation
  before_save do
    encrypted_otp_secret.value = AvramEncrypted::Cipher.recrypt(encrypted_otp_secret.value)
  end
end

```

### Error handling

Decryption can fail if the encrypted data is corrupted, tampered with, or if
the encryption key is no longer available. The following exceptions may be
raised:

- `AvramEncrypted::InvalidEncryptedFormatError`: the stored value doesn't
  match the expected `version:data` format.
- `AvramEncrypted::InvalidKeyVersionError`: the key version in the encrypted
  value doesn't match any configured key.
- `OpenSSL::Error`: the data couldn't be verified or decrypted (e.g.
  corruption or wrong key).

You can handle these in your application:

```crystal
begin
  user.secret_value
rescue ex : AvramEncrypted::InvalidKeyVersionError
  Log.error(exception: ex) { "Missing encryption key for user #{user.id}" }
rescue ex : OpenSSL::Error
  Log.error(exception: ex) { "Decryption failed for user #{user.id}" }
end
```

## Maintenance

### Key versioning

Encryption keys are configured as `Hash(String, String)` pairs, where the hash
key is the version and the hash value is the encryption key. How the keys are
versioned is entirely up to you.

You could keep it simple and use `"0"`, `"1"`, `"2"`, etc. Or you could make
the keys more self-documenting and use timestamps: `"202405"`, `"202511"`, etc.
Whatever works best for you.

### Rotating keys

At some point you'll want to rotate the encryption keys. The `key_version` is
the one that will always be used to save values. So you can add a new key,
update the `key_version` pointer and **avram_encrypted** will take care of the
rest:

```crystal
# config/avram_encrypted.cr

AvramEncrypted.configure do |settings|
  settings.keys = {
    "v1" => "EnjmNNd/WgF9b9cm3ObR+9cYPHQ7G7lIiUL/pShKWP0=",
    "v2" => "WFRN364zJAqxuc/j5KTlEzSRNXIrulL6Hx4bV6T9UuA=",
  }
  settings.key_version = "v2"
end
```

To re-encrypt all existing records in bulk, query for rows still using the old
key version and update them:

```crystal
UserQuery.new.encrypted_otp_secret.like("v1:%").each do |user|
  RecryptUserOtpSecret.update!(user)
end
```

> [!TIP]
> Add a database index on the encrypted column if you plan to do bulk
> re-encryption, so the `LIKE` query can find old records efficiently.

## Contributing

We use [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/)
for our commit messages, so please adhere to that pattern.

1. Fork it (<https://codeberg.org/fluck/avram_encrypted/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'feat: new feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Acknowledgements

This shard pulls inspiration from the following project:

- [microgit-com/lucky_encrypted](https://github.com/microgit-com/lucky_encrypted)

## Contributors

- [Wout](https://codeberg.org/w0u7) - creator and maintainer
