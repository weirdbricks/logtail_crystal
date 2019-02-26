# we can have 1 or 2 arguments, but not 0 or more than 2
if ARGV.size == 0 || ARGV.size > 2
	puts "Usage: You need to provide a filename"
	puts "#{PROGRAM_NAME} filename"
	puts "Optionally you can provide a filename to store the offset position, by default it will be under \"/tmp\""
	exit 0
end

##########################################################################################
# Keep things pretty :)
##########################################################################################

OK   = "[  OK  ]"
INFO = "[ INFO ]"
FAIL = "[ FAIL ]"

##########################################################################################
# Include functions from files
##########################################################################################

require "./logtail_functions.cr"
include LogtailFunctions 

##########################################################################################
# Startup checks
##########################################################################################

filename=ARGV[0]
check_if_file_is_readable(filename)
check_if_filename_exists(filename)
current_inode=get_inode(filename)

# if an offset filename was provided, then use that as the location for the offset
# if no offset was provided create an offset file under /tmp/
if ARGV.size == 2
	offset_filename=ARGV[1]
else
	basename=File.basename(filename)
	offset_filename="/tmp/#{basename}.offset"
end

# open a File handler
filename = File.new(filename)

# get the directory of the passed offset filename
offset_directory=File.dirname(offset_filename)
# make sure that the directory the offset filename lives in is writeable
check_if_path_is_writable(offset_directory)

# ok, now check if there is an existing offset file. If there is one, try to use it.
# if not, we start from 0 and create the offset file
stored_first_byte_number=0
if File.exists?(offset_filename)
	puts "#{INFO} - The offset file #{offset_filename} exists - attempting to read values from it..."
	begin
		# note - the format of the file is expected to look like this:
		# inode number = first_byte_number
		string_from_offset_file  = File.read(offset_filename)
		stored_inode             = string_from_offset_file.split("=")[0].strip.to_i
		stored_first_byte_number = string_from_offset_file.split("=")[1].strip.to_i

		# if the filename size is the same as the stored position there's nothing else to do. 
		if (filename.size == stored_first_byte_number) && (current_inode == stored_inode)
			puts "#{OK} - Got the inode: #{stored_inode} - The current size of the file is the same as the stored position: #{stored_first_byte_number} bytes. No new lines."
			exit 0
		end

		# although very unlikely if the byte position is the same but the inode different, start from the beginning
		if (filename.size == stored_first_byte_number) && (current_inode != stored_inode)
			puts "#{OK} - The current size of the file is the same as the stored position: #{stored_first_byte_number} bytes, but the inodes are different. Starting from 0."		
			stored_first_byte_number = 0
		end

		# in the case someone run a `cat /dev/null` against our file, the current number of bytes will be less
		# than our saved values but the inodes will be the same!!! we want to catch that
		if (filename.size < stored_first_byte_number) && (current_inode == stored_inode)
			puts "#{OK} - The inodes are the same but the file is smaller than the last saved position. Starting from 0"
			stored_first_byte_number = 0
		end

		if (filename.size != stored_first_byte_number) && (current_inode == stored_inode)
			puts "#{OK} - The inodes are the same: #{stored_inode} - Will start from: #{stored_first_byte_number}"
		end

	rescue
		puts "Something went wrong while trying to tokenize: #{string_from_offset_file}"
	end
else
	puts "#{INFO} - I did not find an existing file \"#{offset_filename}\""
end

# move ahead in the file skipping the bytes we've already read
filename.seek(stored_first_byte_number)

loop do
	next_bytes=filename.gets
	break if next_bytes.nil?
        puts next_bytes
end

File.write(offset_filename, "#{current_inode}=#{filename.pos}")
