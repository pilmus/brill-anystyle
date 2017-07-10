#!/usr/bin/ruby

require 'anystyle/parser'
Anystyle.parser.train 'originele_training_file_plus_brill_v2.txt', true
Anystyle.parser.model.path="./origineel_plus_brill.mod"
Anystyle.parser.model.save
