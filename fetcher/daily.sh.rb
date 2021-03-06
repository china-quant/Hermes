#
# filename: fetcher/daily.sh.rb
# author: yrlihuan@gmail.com
#

require "rubygems"
require "json"
require "date"

require File.expand_path("../../accessor/all.rb", __FILE__)
require File.expand_path("../base.rb", __FILE__)

module Fetcher
  class DailySh < Base
    def run(force_update=false)
      accessor = accessor_cls.new

      data_existed = accessor.list
      codes = Accessor::CodeSh.new.query({:all => true}).keys
      codes.each do |code|
        # code sample: 6000036.ss
        if !force_update && data_existed[code]
          puts "skipping #{code}"
          next
        end

        puts "fetching #{code}"
        text = fetch_data(code)
        save_data(code, text)
      end
    end

    def url(code)
=begin rdoc
      #xhb 使用163的数据，雅虎的数据太久没有跟新
      today = Date.today
      y = today.year
      m = today.month
      d = today.day

      "http://ichart.finance.yahoo.com/table.csv?" +
      "s=#{code}.ss&d=#{m-1}&e=#{d}&f=#{y}&g=d&a=3&b=9&c=1990&ignore=.csv"
=end

      today = Date.today
      ul = "http://quotes.money.163.com/service/chddata.html?code=0#{code.to_s}" + \
      "&start=20000101&end=#{today.strftime('%Y%m%d')}&fields=TCLOSE;HIGH;LOW;TOPEN;LCLOSE;CHG;PCHG;TURNOVER;VOTURNOVER;VATURNOVER;TCAP;MCAP"
      return ul
    end

    def fetch_data(code)
      text = `curl -s "#{url(code)}" | iconv -f gb2312 -t utf-8`
      return text
    end

    def save_data(code, text)
      accessor = accessor_cls.new
      accessor.update(code, :data => text)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  gen = Fetcher::DailySh.new
  gen.run
end
