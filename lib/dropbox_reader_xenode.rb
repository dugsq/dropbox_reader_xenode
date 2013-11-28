# Copyright Nodally Technologies Inc. 2013
# Licensed under the Open Software License version 3.0
# http://opensource.org/licenses/OSL-3.0

# 
# @version 0.1.0
#
# Dropbox Reader Xenode monitors a specific file on Dropbox and pass it downstream to its children. 
# It leverages the "dropbox-sdk" Ruby Gem to perform the file read operation. 
# The Xenode will write the file to a local temporary folder by default, but it can also store the 
# content of the file within message data for convenience (requires code change).
#
# Config file options:
#   loop_delay:         Expected value: a float. Defines number of seconds the Xenode waits before running process(). 
#   enabled:            Expected value: true/false. Determines if the xenode process is allowed to run.
#   debug:              Expected value: true/false. Enables extra logging messages in the log file.
#   dropbox_path:       Expected value: a string. Specifies the dropbox folder where the file is expected to be found.   
#   named_file:         Expected value: a string. Specifies the file to be read.
#   access_token:       Expected value: a string. Specify the access token for your Dropbox account.
#
# Example Configuration File:
#   enabled: true
#   loop_delay: 60
#   debug: false
#   dropbox_path: "/source"
#   named_file: "hello.txt"
#   access_token: "1234567890abcdefg"
#
# Example Input:    The Dropbox Reader Xenode does not expect nor handle any input.  
#
# Example Output:
#   msg.context = {file_path=>"tmp_dir/hello.txt",file_name=>"hello.txt"}
#

require 'dropbox_sdk'

class DropboxReaderXenode
  include XenoCore::XenodeBase
  
  def startup
    mctx = "#{self.class}.#{__method__} - [#{@xenode_id}]"
    
    begin
      @file_path    = @config[:dropbox_path] if @config[:dropbox_path]
      @access_token = @config[:access_token] if @config[:access_token]
      @named_file   = @config[:named_file]  if @config[:named_file]
      
      @client = DropboxClient.new(@access_token)
      
      @fullpath = File.join(@file_path, @named_file) #dropbox folder where the source file is located
      do_debug("Dropbox Path including file name: #{@fullpath}")
      
      @localpath = File.join(@tmp_dir, @named_file) #local path to store the file for reuse
      do_debug("Local Path including file name: #{@localpath}")
            
    rescue Exception => e
      catch_error("#{mctx} - #{e.inspect} #{e.backtrace}")
    end    
  end
  
  def process
    mctx = "#{self.class}.#{__method__} [#{@xenode_id}]"
    
    begin
    @contents = @client.get_file(@fullpath) #get the file from dropbox

    if @contents && File.exist?(@localpath) == false

      File.open(@localpath, "w") do |file|  #write the dropbox file locally
        file.write(@contents)
        do_debug("File written to Local Path: #{@localpath}")
      end

      msg = XenoCore::Message.new

      msg.context = msg.context || {}
      msg.context[:file_path] = @localpath    #add the full path of local file to message context
      msg.context[:file_name] = @named_file   #add the name of file to message context
#      msg.data = @contents                    #add the entire file in message data, works for small files
      do_debug("Message Context Set: #{msg.context[:file_path]},#{msg.context[:file_name]}")
      write_to_children(msg)
    end
    
    rescue Exception => e
      catch_error("#{mctx} - #{e.inspect} #{e.backtrace}")
    end
  end
  
end
