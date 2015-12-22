require "yaml"

class DBenviroment
  
  CONF_FILE = File.expand_path( "../../config/db.yml", File.dirname(__FILE__) )

  
  attr_reader :adapter, :host, :database, :user, :password

  def self.load!
    config = YAML.load_file(CONF_FILE)
    env = ENV["APP_ENV"] || "development"
    e = config[env] 
    new(e["adapter"], e["host"], e["database"], e["user"], e["password"])
  end

  def initialize(adapter, host, database, user, password)
    @adapter = adapter
    @host = host
    @database = database
    @user = user
    @password = password
  end

end


class AppDB
  def self.enviroment
    @env ||= DBenviroment.load!
  end
end

