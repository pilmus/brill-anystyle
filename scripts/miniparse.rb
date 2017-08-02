#!/usr/bin/ruby

require 'net/http'
require 'json'
require 'active_support'
require 'active_support/core_ext'

url = 'http://www.worldcat.org/identities/find?fullName=' + ARGV[0]
uri = URI(url)

response = Net::HTTP.get(uri)

json = Hash.from_xml(response).to_json

parsed = JSON.parse(json)

closestForm = parsed["nameAuthorities"]["match"][0]["closestForm"]

puts parsed["nameAuthorities"]["match"][0]

puts closestForm


