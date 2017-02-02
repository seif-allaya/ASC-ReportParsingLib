require './ASC-CSVParselib'
require 'optparse'

#########################################################
#	By: seif.allaya@gmail.com							#
#########################################################
#	Read folder file CSV files							#
#	Create CSV file from the Concatenation of all inputs#
#	--Sort Data--										#
# 	Save the result										#
#########################################################

# Main
def main

	options = {}
	optparse = OptionParser.new do |opts|
		opts.banner = "Usage: ruby excel_to_json.rb [options]"
		opts.on('-i', '--input PATH', 'Input a valid folder PATH') { |folder| options[:inputfolder] = folder }
		opts.on('-o', '--output filename', 'Output filename') { |output| options[:outputfile] = output }
	end
	begin
		optparse.parse!
		#Chech on Input file name
		if options[:inputfolder].nil?
			raise OptionParser::MissingArgument
		end
		#Chech on Output file name
		if options[:outputfile].nil?
			options[:outputfile] = "Consolidated-Output-#{Time.now.strftime("%d-%m-%Y_%H%M")}.csv"
		end
		#ERROR
		rescue OptionParser::ParseError => e
			puts "[OH] No file PATH, Noting to do!!".colorize(:red)
			puts optparse
			exit
	end
	#Starting 
	data = Array.new
	header = ""
	files = Dir.entries(options[:inputfolder])
	files.each{	|file|
		extension = file[(file.length-3)..file.length].to_s.downcase
		if extension=="csv"  
			records = Array.new
			records = CSV.read("#{options[:inputfolder]}/"<< file)
			header = records.shift
			log("Loading data from #{file}",records.count)
			records.each{ |row|
				data << row
			}
		end
	}
	#data.sort! {|x, y| x[$Name] <=> y[$Name]}
	#log("Sorting data",data.count)
	data.unshift(header)
	print_result(data,options[:outputfile])	
	log("Writing data to consolidated output file",data.count)
end

# Starting Point
main()