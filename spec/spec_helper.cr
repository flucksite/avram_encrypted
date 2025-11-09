require "spec"
require "../src/avram_encrypted"

def set_up_default_test_keys
  AvramEncrypted.configure do |settings|
    settings.keys = {
      "v1" => "EnjmNNd/WgF9b9cm3ObR+9cYPHQ7G7lIiUL/pShKWP0=",
      "v2" => "WFRN364zJAqxuc/j5KTlEzSRNXIrulL6Hx4bV6T9UuA=",
      "v3" => "yacNMiqag1nKl+4o/y/99reAuC4BJqWK3CzniIxo/xM=",
    }
    settings.key_version = "v2"
  end
end
