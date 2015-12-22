#
# filename: fetcher/minute.sh.rb
# author: yrlihuan@gmail.com
#

require "rubygems"
require "json"
require "date"

require File.expand_path("../../accessor/all.rb", __FILE__)
require File.expand_path("../base.rb", __FILE__)

module Fetcher
  class MinuteSh < Base
    def run(force_update=false, update_last_month_only=false)
      accessor = accessor_cls.new

      # SINA only have data after 2008 :(
      today = Date.today
      jan1_2008 = Date.parse "2008-01-01"
      last_month = Date.parse("%d-%02d-01" % [(today << 1).year, (today << 1).month])
      start_month = update_last_month_only && last_month || jan1_2008

      codes = code_cls.new.query({:all => true, :more => true})
      codes.each do |code, data|
        # some stocks don't have a ipo_date
        next unless data.key?(:ipo_date) && data[:ipo_date] && data[:ipo_date] < "2030-01-01"

        ipo_date = Date.parse data[:ipo_date]
        d = ipo_date < start_month && start_month || ipo_date

        # update date prior to the current month
        while d.year < today.year || d.month < today.month
          y = d.year
          m = d.month

          # next month
          d = d >> 1

          data_existed = accessor.exists?(code, y, m)
          next if !force_update && data_existed

          raw = fetch_data(code, y, m)
          parsed = parse_data(raw)

          if parsed
            save_data(code, y, m, parsed)
          else
            puts "fail to parse: #{y}, #{m}"
          end
        end
      end
    end

    def code_cls
      Accessor::CodeSh
    end

    def url(code, year, month)
      "http://finance.sina.com.cn/realstock/company/sh#{code}/hisdata/#{year}/%02d.js" % month
    end

    def fetch_data(code, year, month)
      puts "#{url(code, year, month)}"
      `curl -s "#{url(code, year, month)}"`
    end

    def parse_data(raw)
      # check "http://finance.sina.com.cn/realstock/company/sh600036/hisdata/2013/02.js" for a sample data
      return nil unless raw.start_with? 'var'

      parts = raw.split('"')
      return nil unless parts.count == 3

      # save the raw data into a temp file
      fname = "/tmp/minute_sh_#{rand}"
      ftmp = File.open(fname, "w")
      ftmp.write raw
      ftmp.close

      result = ''
      script = File.expand_path("../../tools/sina_finance_decoder/SinaFinanceDecoder.xml", __FILE__)
      cmd = "adl #{script} -- #{fname} 2>&1"
      result = `#{cmd}`

      `rm #{fname}`

      # TODO: how to validate the result
      result
    end

    def save_data(code, year, month, text)
      accessor = accessor_cls.new
      accessor.update(code, :data => text, :year => year, :month => month)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  options = {}
  opts = OptionParser.new do |opts|
     opts.on("-l", "--update_latest", "only run to update latest month") do |date|
      options[:update_latest] = true
    end
  end

  opts.parse!

  gen = Fetcher::MinuteSh.new
  gen.run(false, options[:update_latest])
end
