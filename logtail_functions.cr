module LogtailFunctions
  extend self

  # takes a filename as an argument and returns the inode as an integer
  def get_inode(file)
    begin
      File.info(file).@stat.st_ino
    rescue
      STDERR.puts "#{FAIL} - Something went wrong while trying to get the inode of the file \"#{file}\""
    end
  end

  # takes a filename as an argument
  # if the filename doesn't exist, it will abort
  def check_if_filename_exists(filename)
    unless File.exists?(filename)
      abort "#{FAIL} - Sorry, \"#{filename}\" doesn't exist"
    end
  end

  # takes a filename as an argument
  # checks if the filename is a real file instead of symlink/device etc.
  def check_if_valid_file(filename)
    unless File.file?(filename)
      abort "#{FAIL} - Sorry, \"#{filename}\" - this is not a file"
    end
  end

  # takes a directory as an argument
  # checks if the user running this script has permissions to write there or not
  def check_if_path_is_writable(directory)
    unless File.writable?(directory)
      abort "#{FAIL} - Sorry, I do not have permission to write at \"#{directory}\""
    end
  end

  # takes a filename as an argument
  # checks if the user running this script has permissions to read the file or not
  # if the user does not have the permissions it aborts
  def check_if_file_is_readable(filename)
    unless File.readable?(filename)
      abort "#{FAIL} - Sorry, I do not have permission to read \"#{filename}\""
    end
  end
end
