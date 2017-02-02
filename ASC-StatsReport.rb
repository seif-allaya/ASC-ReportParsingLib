require './ASC-CSVParselib'
require 'optparse'
require 'sqlite3'

#########################################################
#	By: seif.allaya@gmail.com							#
#########################################################
#	Connect to sqlite3 database							#
#														#
#														#
# 	Print the stats										#
#########################################################

# Main
def main

	options = {}
	optparse = OptionParser.new do |opts|
		opts.banner = "Usage: ruby excel_to_json.rb [options]"
		opts.on('-i', '--database PATH', 'Input a valid Database name') { |folder| options[:inputdatabase] = folder }
		opts.on('-o', '--output filename', 'Output filename') { |output| options[:outputfile] = output }
	end
	begin
		optparse.parse!
		#Chech on Input Database name
		if options[:inputdatabase].nil?
			raise OptionParser::MissingArgument
		end
		#Chech on Output file name
		if options[:outputfile].nil?
			options[:outputfile] = "Stats-#{Time.now.strftime("%d-%m-%Y_%H%M")}.csv"
		end
		#ERROR
		rescue OptionParser::ParseError => e
			puts "[OH] No file PATH, Noting to do!!".colorize(:red)
			puts optparse
			exit
	end
	#Starting 
	begin
		db = SQLite3::Database.open(options[:inputdatabase])
		table_name = options[:inputdatabase].to_s.downcase
		stm = db.prepare "SELECT * FROM Cars LIMIT 5" 
		vulns_count = db.prepare("SELECT DISTINCT(Name) FROM #{table_name};").execute
		hosts		= db.prepare("SELECT DISTINCT(Host) FROM #{Table_name};").execute
		hosts_stat	= Array.new
		hosts.each{	|host|
			host_count = db.prepare("SELECT Count(Name) FROM #{Table_name}; WHERE Host = #{host}").execute
			hosts_stat << [host, host_count]
			}
		hosts_stat.sort! { |x,y| x[2] <=> y[2] }
	rescue SQLite3::Exception => e 
		puts "Exception occurred"
		puts e
	ensure
		stm.close if stm
		db.close if db
	# Save the results
	log("Total Vulnerabilities Count:",vulns_count)
	log("Affected Hosts Count:",hosts.count)
	log("Most vulnerable Host is#{hosts_stat[1]}:",hosts_stat[2])
	log("Second Most vulnerable Host is #{hosts_stat[1]}:",hosts_stat[2])
	log("Third Most vulnerable Host is #{hosts_stat[1]}:",hosts_stat[2])
	end
end

# Starting Point
main()