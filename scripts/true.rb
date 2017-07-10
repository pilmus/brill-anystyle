#!/usr/bin/ruby

require 'anystyle/parser'
Anystyle.parser.train 'originele_plus_brill_v2', true
Anystyle.parser.model.path="./modelgroundup.mod"
Anystyle.parser.model.save
