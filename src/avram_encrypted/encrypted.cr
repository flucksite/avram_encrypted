require "lucky"
require "avram"
require "./encryptable"

module AvramEncrypted
  {% for type in [String] %}
    class Encrypted{{type}}
      include AvramEncrypted::Encryptable
    end
  {% end %}
end
