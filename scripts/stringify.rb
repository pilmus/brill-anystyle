#!/usr/bin/ruby

require_relative 'worldcat_api_interaction'

def stringify_author(tagdict_author, bibl)
  if tagdict_author.include? 'and' # case: multiple authors

    puts "\n\n\nANDDD: " + tagdict_author.to_s + "\n\n\n"

    authors = tagdict_author.split('and')

    puts "\n\n\nANDDD: " + authors.to_s + "\n\n\n"
  else # case: one author
    authors = [tagdict_author]
  end

  authors.each {|potential_author|

    puts "PAUTHOR: " + potential_author.to_s

    potential_author.strip!
    if includes_nums_punct?(potential_author)
      bibl.add_child "<author><name type=\"misparsed\">" + potential_author + "</name></author>"
      next # return
    end

    if single_word?(potential_author) # case: author name is a single word (ie. Homerus)
      viaflink = find_single_author(potential_author)
      unless viaflink.to_s.empty?
        bibl.add_child "<author ref=\"" + viaflink + "\"><name type=\"mononym\">" + potential_author + "</name></author>"
        next # return
      end
      bibl.add_child "<author><name type=\"misparsed\">" + potential_author + "</name></author>"
      next # return

    elsif potential_author.include? ',' # case: first and last name
      author = potential_author.split(', ')
      surname = author[0]
      forename = author[1]

      if letter_and_name_forename?(forename)
        bibl.add_child "<author><name type =\"polynym\"><surname>"+surname+"</surname><forename>"+forename+"</forename></name></author>"
        next # return
      else
        viaflink = find_author(forename, surname)
        unless viaflink.to_s.empty?
          bibl.add_child "<author ref=\"" + viaflink + "\"><name type=\"polynym\"><surname>"+surname+"</surname><forename>"+forename+"</forename></name></author>"
          next # return
        end
        bibl.add_child "<author><name type=\"misparsed\">" + potential_author + "</name></author>"
        next # return
      end
    else
      bibl.add_child "<author><name type=\"misparsed\">" + potential_author + "</name></author>"
    end
  }
end

def single_word?(string)
  !string.strip.include? " "
end

def letter_forename?(forename)
  /^([-]?[A-Z]\. ?)+$/ =~ forename
end

def letter_and_name_forename?(forename)
  /([-]?[A-Z]\.)+/ =~ forename
end

def includes_nums_punct?(name)
  /[\W*\d*&&[^-'., ]]/ =~ name.strip
end