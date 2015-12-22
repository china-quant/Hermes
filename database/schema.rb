$LOAD_PATH.unshift File.expand_path("../lib/", File.dirname(__FILE__))
require "database/db_enviroment"
require "sequel"

SH_DIR = File.expand_path("../data/daily.sh/", File.dirname(__FILE__))
SZ_DIR = File.expand_path("../data/daily.sz/", File.dirname(__FILE__))

db_env  = AppDB.enviroment

DB = Sequel.connect(
       :adapter => db_env.adapter,
       :user => db_env.user,
       :host => db_env.host,
       :database => db_env.database,
       :password=> db_env.password
      )

Dir.entries(SH_DIR).each do |stk|
  next if stk.eql?(".") or stk.eql?("..")
  base_name = "sh" + File.basename(stk, ".*")
  DB.create_table base_name.to_sym do 
    primary_key :id
    Date :date
    String :code
    String :name
    String :close
    String :high
    String :low
    String :open
    String :lclose
    String :mchange
    String :pchange
    String :erate
    String :vol
    String :volmoney
    String :cap
    String :onsellcap
  end
end

