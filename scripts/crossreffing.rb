#!/usr/bin/ruby

require 'serrano'
require 'nokogiri'


def finddoi(query)

  # puts "bibl: " + bibl.to_s
  # query = bibl.css("title")
  # puts query

  response = Serrano.works(query: query)
  items = response['message']['items']

  items.each do |item|
    puts "LOOOOOOOOOL: " + item.to_s

    if item['title'].include?(query) ||
        item['subtitle'].include?(query) ||
        item['container-title'].include?(query)
      return item['DOI']
    end
  end

  return ""
end


# def findcrossref(bibl)
#   title = bibl.css("title").text
#   publisher = bibl.css("publisher")
#
# end

# x = Serrano.works(query: "The Brill Dictionary of Religion")
#
# items = x['message']['items']
#
#
# title = items['title']
#
# puts items[0]

# items.each do |item|
#   puts item.keys
#   puts item['title']
#   puts item['publisher']
#   puts item['author']
# end