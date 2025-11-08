module AvramEncrypted
  class Error < ::Exception; end

  class InvalidEncryptedFormatError < Error; end

  class InvalidKeyVersionError < Error; end
end
