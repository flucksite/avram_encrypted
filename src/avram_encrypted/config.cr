require "habitat"

module AvramEncrypted
  Habitat.create do
    setting keys : Hash(String, String), validation: :validate_at_least_one
    setting key_version : String, validation: :validate_existence
    setting auto_rotate : Bool = false
  end

  def self.validate_at_least_one(value : Hash(String, String))
    !value.empty? ||
      Habitat.raise_validation_error("At least one encryption key is needed")
  end

  def self.validate_existence(value : String)
    AvramEncrypted.settings.keys[value]? ||
      Habitat.raise_validation_error("The key version '#{value}' does not exist")
  rescue NilAssertionError
    Habitat.raise_validation_error("The `keys` setting must be set before the `key_version`")
  end
end
