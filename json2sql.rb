#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'sqlite3'

#write each line to an sql file
#note content of each line
#at the end, decide the column data type and prepend that to the sql file

args = ARGV
$columns = Hash.new
$columnsr = Hash.new
$lengths = Hash.new
# data types
# 0 = null
# 1 = integer
# 2 = real/float
# 3 = text/varchar

jsonfile = args[0]

if File.exist?(jsonfile)
        filething = File.new(jsonfile, "r")
else
        abort "No such file #{jsonfile}."
end

def process_hash(recordh, current_key, hash)
	hash.each do |new_key, value|
		combined_key = [current_key, new_key].delete_if { |k| k.empty? }.join('__')
		if value.is_a?(Hash)
			process_hash(recordh, combined_key, value)
		else
			recordh[combined_key] = value
			case value.class.to_s
    			when "String"
				if /^[0-9]+\.[0-9]*$/.match(value) or /^\.[0-9]+$/.match(value)
					$columns[combined_key]=2 if ( !$columns.key?(combined_key) ) or ( 2 > $columns[combined_key] )
				elsif value == "spunt"
					$columns[combined_key]=0
				else
					$columns[combined_key]=3 if ( !$columns.key?(combined_key) ) or ( 3 > $columns[combined_key] )
				end
			when "Integer","FalseClass","TrueClass"
				$columns[combined_key]=1 if ( !$columns.key?(combined_key) ) or ( 1 > $columns[combined_key] )
			else
				$columns[combined_key]=3 if ( !$columns.key?(combined_key) ) or ( 3 > $columns[combined_key] )
			end
      			$lengths[combined_key] = value.to_s.length unless $lengths[combined_key] and value <= $lengths[combined_key]
		end
	end
end

File.readlines(jsonfile).each do |line|
	recordh = {}
        eachone = JSON.parse(line)
	process_hash(recordh, '', eachone)
p $columns
  p "----------------------------"
  p $lengths
  p "----------------------------"
  p recordh
end
