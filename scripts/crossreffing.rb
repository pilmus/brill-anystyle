#!/usr/bin/ruby

require 'serrano'
require 'nokogiri'


# def findcrossref(bibl)
#   title = bibl.css("title").text
#   publisher = bibl.css("publisher")
#
# end

x = Serrano.works(query: "The Brill Dictionary of Religion")

items = x['message']['items']


title = items['title']

puts items[0]

# items.each do |item|
#   puts item.keys
#   puts item['title']
#   puts item['publisher']
#   puts item['author']
# end