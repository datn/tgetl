#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'sqlite3'

# 2018 datn
# reads in a telegram jsonl dump and stores the contents into an sqlite database
#

args = ARGV

jsonfile = args[0]

if File.exist?(jsonfile)
	filething = File.new(jsonfile, "r")
else
	abort "No such file #{jsonfile}."
end

sqlitefile = args[1]

unless /db$/.match(sqlitefile) or /sqlite$/.match(sqlitefile)
	sqlitefile = "#{sqlitefile}.db"
end

if File.exist?(sqlitefile)
	print "Open #{sqlitefile} and clobber its messages table? [y/N] "
else
	print "Create new database #{sqlitefile}? [y/N] "
end

dbq = $stdin.gets.chomp

if dbq == "y"
	db = SQLite3::Database.new sqlitefile
else
	abort "Okay, whatever. Bye."
end

db.execute "DROP TABLE IF EXISTS 'messages'"
db.execute "CREATE TABLE 'messages' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 't_id' varchar, 'flags' integer, 'from_first_name' varchar NOT NULL, 'from_last_name' varchar NOT NULL, 'to_first_name' varchar NOT NULL, 'to_last_name' varchar NOT NULL, 'message' text, 'epochdate' TIMESTAMP NOT NULL, 'media_type' varchar, 'media_caption' text, 'media_last_name' varchar, 'media_first_name' varchar, 'media_url' varchar, 'media_desc' text, 'media_title' varchar, 'created_at' TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 'updated_at' TIMESTAMP DEFAULT CURRENT_TIMESTAMP)"

File.readlines(jsonfile).each do |line|
	eachone = JSON.parse(line)
	t_id = eachone["id"] 
	flags = eachone["flags"]
	from_first_name = eachone["from"]["first_name"]
	from_last_name = eachone["from"]["last_name"]
	to_first_name = eachone["to"]["first_name"]
	to_last_name = eachone["to"]["last_name"]
	message = eachone["text"]
	epochdate = eachone["date"]
	if eachone["media"].nil?
                media_type = nil
                media_first_name = nil
                media_last_name = nil
                media_caption = nil
                media_url = nil
                media_desc = nil
                media_title = nil
	else
		media_type = eachone["media"]["type"] 
		media_first_name = eachone["media"]["first_name"]
		media_last_name = eachone["media"]["last_name"]
		media_caption = eachone["media"]["caption"]
		media_url = eachone["media"]["url"]
		media_desc = eachone["media"]["description"]
		media_title = eachone["media"]["title"]
	end

	db.execute( "INSERT INTO messages ( 't_id', 'flags', 'from_first_name', 'from_last_name', 'to_first_name', 'to_last_name', 'message', 'epochdate', 'media_type', 'media_first_name', 'media_last_name', 'media_caption', 'media_url', 'media_desc', 'media_title' ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [t_id, flags, from_first_name, from_last_name, to_first_name, to_last_name, message, epochdate, media_type, media_first_name, media_last_name, media_caption, media_url, media_desc, media_title] )

end
