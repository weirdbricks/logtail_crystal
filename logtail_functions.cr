module LogtailFunctions
	extend self

	# takes a filename as an argument and returns the inode as an integer
	def get_inode(file)
	        # because I could not find a more direct way to get the inode of a file, I cast the output of .info to a string
	        # and then split the string up - finally I convert the inode number to an integer
	        begin
	                File.info(file).to_s.split("@st_ino=")[1].split("_u64")[0].to_i
	        rescue
	                STDERR.puts "#{FAIL} - Something went wrong while trying to get the inode of the file \"#{file}\""
	        end
	end

	# takes a filename as an argument
	# if the filename doesn't exist, it will abort
	def check_if_filename_exists(filename)
	        if File.exists?(filename)
	                STDERR.puts "#{OK} - \"#{filename}\" exists"
	        else
	                abort "#{FAIL} - Sorry, \"#{filename}\" doesn't exist"
	        end
	end

	# takes a filename as an argument
	# checks if the filename is a real file instead of symlink/device etc.
	def check_if_valid_file(filename)
	        if File.file?(filename)
	                STDERR.puts "#{OK} - I'll load this file: #{filename}"
	                logfile=File.new(filename)
	        else
	                abort "#{FAIL} - Sorry, \"#{filename}\" - this is not a file"
	        end
	end

	# takes a directory as an argument
	# checks if the user running this script has permissions to write there or not
	def check_if_path_is_writable(directory)
	        if File.writable?(directory)
	                STDERR.puts "#{OK} - I do have permissions to write at \"#{directory}\""
	        else
	                abort "#{FAIL} - Sorry, I do not have permissions to write at \"#{directory}\""
	        end
	end

        # takes a filename as an argument
        # checks if the user running this script has permissions to read the file or not
	# if the user does not have the permissions it aborts
        def check_if_file_is_readable(filename)
                if File.readable?(filename)
                        STDERR.puts "#{OK} - I do have permissions to read \"#{filename}\""
                else
                        abort "#{FAIL} - Sorry, I do not have permissions to read \"#{filename}\""
                end
        end
end
