class ScrapersController < ApplicationController
  require 'rubygems'
  require 'nokogiri'
  require 'open-uri'
  require 'mechanize'

  # t.string :name
  # t.string :symbol
  # t.datetime :released_at
  # t.text :description
  # t.boolean :active
  # t.string :founder
  # t.string :hash_algorithm
  # t.string :timestamping_method
  # t.string :color_hexidecimal
  # t.string :website
  # t.decimal :supply_total, precision: 25, scale: 10
  # t.decimal :supply_circulating, precision: 25, scale: 10

  def crawl_coinmarketcap
    agent = Mechanize.new
    url = "https://coinmarketcap.com/all/views/all/"
    page = agent.get(url)

    paths = []
    page.search("table tbody tr").each do |row|
      paths << row.search(".currency-name a")[0].attributes["href"].value
    end

    x = []
    paths.each do |path|
      url = "https://coinmarketcap.com" + path
      page = agent.get(url)
      info = [page.search("h1.text-large img")[0].attributes["alt"].value, page.search("h1.text-large small.hidden-md").text.gsub("(","").gsub(")","")]
      details = page.search(".coin-summary-item-detail")
      supply_circulating_idx = nil; supply_total_idx = nil;
      page.search(".coin-summary-item-header").each_with_index do |header, index|
        supply_circulating_idx = index if header.text.include?("Circulating Supply")
        supply_total_idx = index if header.text.include?("Max Supply")
      end
      if details.any?
        if supply_circulating_idx.present?
          info << details[supply_circulating_idx].text.strip.split(" ").first.gsub(",","").to_i
        else
          info << ""
        end
        if supply_total_idx.present?
          info << details[supply_total_idx].text.strip.split(" ").first.gsub(",","").to_i
        else
          info << ""
        end
      end
      if page.search("ul.list-unstyled").first.search("li a").try(:first).try(:text) == "Website"
        info << page.search("ul.list-unstyled").first.search("li a").first.attributes["href"].value
      else
        info << ""
      end
      x << info
    end
    x
  end

end
