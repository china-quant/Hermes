#
# filename: accessor/code.sh.rb
# author: yrlihuan@gmail.com
#

require "rubygems"
require "json"

require File.expand_path("../base.rb", __FILE__)

module Accessor
  class CodeSh < Base
    def self.advanced_options(options, opts, can_list_all=true)
      opts.on("-m", "--more", "more information than just name") do |v|
        options[:more] = true
      end
    end


    def query(params={})
      raw_data = query_raw(params)

      data = {}
      raw_data.each do |code, dict|
        if params[:more]
          data[code] = {:name => dict["PRODUCTNAME"], :ipo_date => dict["IPO_DATE"]}
        else
          data[code] = dict["PRODUCTNAME"]
        end
      end

      data
    end

    def query_raw(params={})
      dir = data_dir

      all = params[:all]
      stocks = params[:stocks]

      data = {}
      Dir.entries(dir).each do |f|
        next if f.start_with? '.'

        code = f.gsub(".json", "")
        if all or stocks.index(code)
          text = File.open(File.join(dir, f)).read
          obj = JSON.load(text)
          data[code] = obj
        end
      end

      data
    end

    def update(identifier, params={})
      data = params[:data]
      path = File.join(data_dir, "#{identifier}.json")

      f = File.open(path, 'w')
      f.write(JSON.dump(data))
      f.close
    end

    def append(identifier, params={})
    end
  end
end


if $PROGRAM_NAME == __FILE__
  options = {}
  opts = OptionParser.new do |opts|
    Accessor.stock_options(options, opts)
    Accessor.common_options(options, opts)
    Accessor::CodeSh.advanced_options(options, opts)
  end

  opts.parse!
  Accessor.validate_stock_options(options, opts)

  gen = Accessor::CodeSh.new
  data = gen.query options

  puts JSON.dump(data)
end

