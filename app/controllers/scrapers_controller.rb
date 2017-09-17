class ScrapersController < ApplicationController
  require 'rubygems'
  require 'nokogiri'
  require 'open-uri'
  require 'mechanize'

  def crawl_yahoo_ixic
    agent = Mechanize.new
    url = "https://coinmarketcap.com/all/views/all/"
    page = agent.get(url)

    rows = page.search("table.yfnc_datamodoutline1 tr")
    (2..67).each do |n|
      date = rows[n].search("td")[0].text.to_datetime
      open = rows[n].search("td")[1].text.gsub(",", "").to_f
      high = rows[n].search("td")[2].text.gsub(",", "").to_f
      low = rows[n].search("td")[3].text.gsub(",", "").to_f
      close = rows[n].search("td")[4].text.gsub(",", "").to_f
      volume = rows[n].search("td")[5].text.gsub(",", "").to_f

      index = Index.find_by_symbol("IXIC")
      index.index_quotes.create(date: date, open: open, high: high, low: low, close: close, volume: volume) unless index.index_quotes.find_by_date(date).present?
    end
  end

end
