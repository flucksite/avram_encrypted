# AvramEncrypted

Encrypted columns for Avram supporting multiple types and automatic key rotation.

Store sensitive data encrypted in your database leveraging Lucky's built-in
`MessageEncryptor` (AES-256-CBC). Values are automatically encrypted before
saving and decrypted when reading, so you can use them like regular columns.

Key rotation is supported out of the box, so old data remains readable while
new saves use your current encryption key.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     avram_encrypted:
       codeberg: fluck/avram_encrypted
   ```

2. Run `shards install`

## Usage

1. Include the shard in your `shards.cr` file:

   ```crystal
   require "avram_encrypted"
   ```

2. Configure the keys:

   ```crystal
   AvramEncrypted.configure do |settings|
     settings.keys = {
       "v1" => "EnjmNNd/WgF9b9cm3ObR+9cYPHQ7G7lIiUL/pShKWP0=",
     }
     settings.key_version = "v1"
   end
   ```

3. Define the encrypted column:

   ```crystal
   class User < BaseModel
     table do
       column secret_value : AvramEncrypted::EncryptedString
     end
   end
   ```

## Configuration

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

> [!NOTE]
> A bulk key rotation mechanism is in the making. You'll be able to run
> batched rotation jobs focussed on specific columns in the background.

### Encrypting built-in types

By default, this shard comes with the following encrypted base types:

- `AvramEncrypted::EncryptedString`
- `AvramEncrypted::EncryptedInt32`

Using the `AvramEncrypted::Types` annotation, you can register any other
built-in type that responds to `#to_json` and `.from_json`:

```crystal
# config/avram_encrypted.cr

@[AvramEncrypted::Types(String, Int32, Bool, UInt16)]
module AvramEncrypted
end

```

Those additional encrypted types will then be available as:

- `AvramEncrypted::EncryptedBool`
- `AvramEncrypted::EncryptedUInt16`

> [!NOTE]
> Under the hood, this shard leverages Crystal's JSON pull-parser to stringify
> values before encrypting them, and the other way around. That's why any class
> or struct that implements to `#to_json` and `.from_json` will work.

## Contributing

We use [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/)
for our commit messages, so please adhere to that pattern.

1. Fork it (<https://github.com/your-github-user/avram_encrypted/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'feat: new feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Wout](https://codeberg.org/w0u7) - creator and maintainer
