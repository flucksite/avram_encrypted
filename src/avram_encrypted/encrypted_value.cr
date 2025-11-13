struct AvramEncrypted::EncryptedValue
  def initialize(
    @value : String,
    @keys : Hash(String, String) = AvramEncrypted.settings.keys,
  )
    @parts = @value.split(":")
  end

  def parse : Tuple(String, String)
    @parts.size == 2 ||
      raise InvalidEncryptedFormatError.new(format_error_message)

    {key, @parts.last}
  end

  private def key : String
    @keys[@parts.first]? ||
      raise InvalidKeyVersionError.new("Unknown key version: '#{@parts.first}'")
  end

  private def format_error_message
    "Invalid encrypted format: expected '[version]:[data]' but got '#{@value}'"
  end
end
