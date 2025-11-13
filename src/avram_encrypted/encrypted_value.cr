struct AvramEncrypted::EncryptedValue
  def initialize(
    @value : String,
    @keys : Hash(String, String) = AvramEncrypted.settings.keys,
  )
    @parts = @value.split(":")
  end

  # Parses the encrypted value and retuns a Tuple with the encryption key and
  # the encrypted payload.
  def parse : Tuple(String, String)
    @parts.size == 2 ||
      raise InvalidEncryptedFormatError.new(format_error_message)

    {key, @parts.last}
  end

  # Finds the encryption key for the version found in the header of the
  # encrypted value.
  private def key : String
    @keys[@parts.first]? ||
      raise InvalidKeyVersionError.new("Unknown key version: '#{@parts.first}'")
  end

  private def format_error_message
    "Invalid encrypted format: expected '[version]:[data]' but got '#{@value}'"
  end
end
