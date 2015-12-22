$LOAD_PATH.unshift File.expand_path("../lib/", File.dirname(__FILE__))
require "database/db_enviroment"
require "sequel"
require 'pry'
require 'csv'

SH_DIR = File.expand_path("../data/daily.sh/", File.dirname(__FILE__))
SZ_DIR = File.expand_path("../data/daily.sz/", File.dirname(__FILE__))

db_env  = AppDB.enviroment
column = [:date, :code, :name, :close, :high, :low, :open, :lclose, :mchange, :pchange, :erate, :vol, :volmoney, :cap, :onsellcap]

DB = Sequel.connect(
       :adapter => db_env.adapter,
       :user => db_env.user,
       :host => db_env.host,
       :database => db_env.database,
       :password=> db_env.password
      )

all_tables = DB.tables

Dir.entries(SH_DIR).each do |stk|
  next if stk.eql?(".") or stk.eql?("..")
  base_name = "sh" + File.basename(stk, ".*")
  if all_tables.include?(base_name.to_sym)
    table = DB[base_name.to_sym]
    headers = nil
    CSV.foreach(SH_DIR + '/' + stk) do |row|
      if headers.nil?
        headers = row
        next
      end
      insert_hash = Hash[column.zip(row)]
      table.insert(insert_hash)
    end
  end
end

