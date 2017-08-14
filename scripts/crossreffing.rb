#!/usr/bin/ruby

require 'serrano'
require 'nokogiri'

def finddoi(query)
  response = Serrano.works(query: query)

  items = response['message']['items']

  items.each do |item|
    if (item['title'] && item['title'].include?(query)) ||
        (item['subtitle'] && item['subtitle'].include?(query)) ||
        (item['container-title'] && item['container-title'].include?(query))
      return item['DOI']
    end
  end

  return ""
end
