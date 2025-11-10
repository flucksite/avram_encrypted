require "lucky"
require "avram"
require "./encryptable"

annotation AvramEncrypted::Types
end

@[AvramEncrypted::Types(String, Int32)]
module AvramEncrypted
  {% for type in @type.annotation(AvramEncrypted::Types).args %}
    class Encrypted{{type}}
      include AvramEncrypted::Encryptable
    end
  {% end %}
end
