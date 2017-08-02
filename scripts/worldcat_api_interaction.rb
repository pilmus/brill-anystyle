#!/usr/bin/ruby

require 'net/http'
require 'json'

def find_author(forename, surname)

  author = get_author(forename + " " + surname)

  unless author.to_s.empty?
    viaf = author["@id"].sub!("VIAF|", "")
    name = author["text"]

    if name.include?(forename) && name.include?(surname)
      return viaf
    end
  end

  return ""
end

def find_single_author(fullname)
  author = get_author(fullname)
  unless author.to_s.empty?
    viaf = author["@id"].sub!("VIAF|", "")
    name = author["text"]

    if name.include?(forename) && name.include?(surname)
      return viaf
    end
  end

  return ""
end

def get_author(name)
  url = "http://www.viaf.org/viaf/search?query=cql.any+=+\"" + name + "\"&maximumRecords=1&httpAccept=application/json"
  puts "url: " + url
  uri = URI(url)

  response = Net::HTTP.get(uri)
  parsed = JSON.parse(response)

  # puts "parsed: " + parsed.to_s

  searchRetrieveResponse = parsed["searchRetrieveResponse"]
  unless searchRetrieveResponse.to_s.empty?
    records = searchRetrieveResponse["records"]
    unless records.to_s.empty?
      records_0 = records[0]
      unless records_0.to_s.empty?
        record = records_0["record"]
        unless record.to_s.empty?
          recordData = record["recordData"]
          unless recordData.to_s.empty?
            titles = recordData["titles"]
            unless titles.to_s.empty?
              if titles.key?(:author)
                author = titles["author"]
                return author
              end
            end
          end
        end
      end
    end
  end
  return ""
end