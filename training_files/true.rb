#!/usr/bin/ruby

require 'anystyle/parser'
Anystyle.parser.train 'train.txt', true
Anystyle.parser.model.path="./een_file.mod"
Anystyle.parser.model.save
