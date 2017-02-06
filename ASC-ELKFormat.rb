require './ASC-CSVParselib'
require 'optparse'
require 'pp'

#########################################################
#	By: seif.allaya@gmail.com							
#########################################################
#	Read CSV file										
#	Sort CSV file										
#	Format Risk										
#	Regroup Vulnerabilities by CVE and Host				
#	Remove duplicates in CVE and Host fiels	
# 	Save the result	
#########################################################

# Main
def main
  options = {}
  optparse = OptionParser.new do |opts|
    opts.banner = "Usage: ruby excel_to_json.rb [options]"
     opts.on('-i', '--input filename', 'Input a valid .csv file') { |file| options[:inputfile] = file }
     opts.on('-o', '--output filename', 'Output filename') { |output| options[:outputfile] = output }
   end
   begin
    optparse.parse!
    #Chech on Input file name
	if options[:inputfile].nil?
		raise OptionParser::MissingArgument
    end
    #Chech on Output file name
	if options[:outputfile].nil?
		options[:outputfile] = "output_data_#{Time.now.strftime("%d-%m-%Y_%H%M")}.csv"
    end
	#ERROR
	rescue OptionParser::ParseError => e
		puts "[OH] No file supplied, Noting to do!!".colorize(:red)
		puts optparse
		exit
	end
	#Starting 
	data = Array.new
	data = CSV.read(options[:inputfile])
	header = data.shift
	log("Loading data from input file",data.count)
	data.sort! {|x, y| x[$Name] <=> y[$Name]}
	data = degroup_by_host(data)
	log("Degrouped data per Host",data.count)
	data = degroup_by_port(data)
	log("Degrouped data per Port",data.count)
	# Format cells
	columns_to_delete = [$CVE,$Synopsis,$Description,$Solution,$Plugin_Output,$See_Also,$concatenate]
	data.each {|row|
		# Delete columns content
		columns_to_delete.each {|column|
			row[column]  = ""
		}
		#row[$CVSS] = row[$CVSS].gsub(",",".")
		row[$Risk] = row[$Risk].gsub("'","")
		row[$Name] = row[$Name].gsub("\n","")
	}
#	data.unshift(header) #Not needed in ELK
	print_result(data,options[:outputfile])	
	log("Writing data to output file #{options[:outputfile]}",data.count)
end

# Starting Point
main()