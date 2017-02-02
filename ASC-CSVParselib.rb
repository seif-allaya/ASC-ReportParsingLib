require 'csv'
require 'colorize'

#########################################################
#	By: seif.allaya@gmail.com							#
#########################################################
#	Library of functions								#
#########################################################

$column_delimiter   = ","
$list_delimiter     = "\n"
$EOL			= "\r"
#Plugin ID,CVE,CVSS,Risk,Host,Protocol,Port,Name,Synopsis,Description,Solution,See Also,Plugin Output
$Plugin_ID 		= 0
$CVE 			= 1
$CVSS 			= 2
$Risk 			= 3
$Host 			= 4
$Protocol 		= 5
$Port 			= 6
$Name 			= 7
$Synopsis 		= 8
$Description 	= 9
$Solution 		= 10
$Plugin_Output 	= 11
$See_Also 		= 12
$concatenate 	= 13

### Group CVE per vulnerability
def regroup_by_cve(input)
	tableau = Array.new()
	last = input.shift
	input.each {|current|
		if current[$Unique_ID] == last[$Unique_ID] && current[$Name] == last[$Name]
			#Create the full list of CVE for an unique vulnerability
			last[$CVE]  = last[$CVE].to_s  << $list_delimiter  << current[$CVE].to_s
		else
			#Saving The vulnerability anbd going for the next one
			tableau << last
			last = current
		end
	}
	tableau << last
	return(tableau)
end

### Group Host per vulnerability
def regroup_by_host(input)
	tableau = Array.new()
	last = input.shift
	input.each {|current|
		if (current[$Name] == last[$Name]) && (current[$Port] == last[$Port]) && (current[$Risk] == last[$Risk])
			#Create the full list of host for an unique vulnerability
			last[$Host] = last[$Host].to_s << $list_delimiter  << current[$Host].to_s
		else
			#Saving The vulnerability and going for the next one
			tableau << last
			last = current
		end
	}
	tableau << last
	return(tableau)
end

### Degroup Host per vulnerability
def degroup_by_host(input)
	tableau = Array.new()
	input.each {|current|
		hosts = current[$Host].split($list_delimiter)
		hosts.each {|host|
			current[$Host] = host 
			tableau << current}
		}
	return(tableau)
end




### Removing irrelevant records and set ordering values
def format_risk(input)
	relevant 	= Array.new()
	irrelevant 	= Array.new()
	input.each {|current|
	case current[$Risk]
	when "Critical"
		current[$Risk] = "D-Critical"
		relevant << current
	when "High"
		current[$Risk] = "C-High"
		relevant << current
	when "Medium"
		current[$Risk] = "B-Medium"
		relevant << current
	when "Low"
		current[$Risk] = "A-Low"
		relevant << current
	else
		irrelevant << current
	end	
	}
	return(relevant)
end
			
### Regroupement CVE/Host
def regroup_by_host_and_cve(input)
	tableau = Array.new()
	last = input.shift
	input.each {|current|
		# Verify that it is the same vulnerability
		if (current[$Name] == last[$Name]) && (current[$Port] == last[$Port]) && (current[$Risk] == last[$Risk])
			# Creat a list of CVE and Hosts
			last[$Host] = last[$Host].to_s << $list_delimiter  << current[$Host].to_s
			last[$CVE]  = last[$CVE].to_s  << $list_delimiter  << current[$CVE].to_s
		else
			# Save the vulnerability and oving to the next one
			tableau << last
			last = current
		end
	}
	tableau << last
	return(tableau)
end

### Format CVE/Host
def remove_duplicates_cve_and_host(input)
	input.each{ |e|
		e[$Host] = e[$Host].split($list_delimiter).uniq.join($list_delimiter) unless  e[$Host].nil?
		e[$CVE]	 = e[$CVE].split($list_delimiter).uniq.join($list_delimiter) unless  e[$CVE].nil?
	}
	return(input)
end

### Print the current state
def log(message, value)
puts "Action conducted : #{message}, Data records Count : #{value.to_s.green}"
end

### Fill CVE with N/A
def fill_blank_cve(input)
	input.each{ |e|
		if e[$CVE].to_s == ""
			e[$CVE] =  "N/A"
		end
	}
	return(input)
end

### Save the result
def print_result(mydata,output_file)
	CSV.open(output_file, "w") do |csv|
		mydata.each{|row| csv << row}
	end
end