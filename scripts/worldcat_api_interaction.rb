#!/usr/bin/ruby

require 'net/http'
require 'json'

def find_author(forename, surname)
  author, viaflink = get_author_and_viaf(forename + " " + surname)

  unless author.to_s.empty?
    if author.include?(forename) && author.include?(surname)
      unless viaflink.to_s.empty?
        return viaflink
      end
    end
  end
  return ""
end

def find_single_author(fullname)
  author, viaflink = get_author_and_viaf(fullname)
  unless author.to_s.empty?
    if author.include?(fullname)
      unless viaflink.to_s.empty?
        return viaflink
      end
    end
  end
  return ""
end

def get_author_and_viaf(name)
  url = "http://www.viaf.org/viaf/search?query=cql.any+=+\"" + name + "\"&maximumRecords=1&httpAccept=application/json"
  uri = URI(url)

  response = Net::HTTP.get(uri)
  parsed = JSON.parse(response)

  sRR = parsed["searchRetrieveResponse"]

  numRecs = sRR["numberOfRecords"]

  if numRecs == "0"
    puts "\nNo records found for " + name.to_s + "\n"
    return "", ""
  end


  records = sRR["records"]


  records_0 = records[0]
  record = records_0["record"]
  recordData = record["recordData"]
  mH = recordData["mainHeadings"]
  mHEl = mH["mainHeadingEl"]


  begin
    datafield = mHEl[0]["datafield"]
  rescue => e
    datafield = mHEl["datafield"]
  end


  subfield = datafield["subfield"]

  document = recordData["Document"]
  primTopic = document["primaryTopic"]

  begin
    author = subfield[0]["#text"]
  rescue NoMethodError => e
    author = subfield["#text"]
  end

  viaflink = primTopic["@resource"]

  unless author.to_s.empty?
    unless viaflink.to_s.empty?
      return author, viaflink
    end
    return author, ""
  end
  return "", ""
end