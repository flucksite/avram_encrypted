require "avram"

class TestDatabase < Avram::Database
end

TestDatabase.configure do |settings|
  settings.credentials = Avram::Credentials.void
end

Avram.configure do |settings|
  settings.database_to_migrate = TestDatabase
end

abstract class BaseModel < Avram::Model
  def self.database : Avram::Database.class
    TestDatabase
  end
end
