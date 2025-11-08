struct AvramEncrypted::EncryptedValue
  def initialize(@value : String)
    @parts = @value.split(":")
  end

  def parse : Tuple(String, String)
    @parts.size == 2 ||
      raise InvalidEncryptedFormatError.new(
        "Invalid encrypted format: expected '[version]:[data]' but got '#{@value}'"
      )

    {key, @parts.last}
  end

  private def key : String
    AvramEncrypted.settings.keys[@parts.first]? ||
      raise InvalidKeyVersionError.new("Unknown key version: '#{@parts.first}'")
  end
end
