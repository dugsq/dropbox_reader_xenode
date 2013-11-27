dropbox-reader-xenode
=====================

**Dropbox Reader Xenode** monitors a specific file on Dropbox and pass it downstream to its children. It leverages the "dropbox-sdk" RubyGem to perform the file read operation. The Xenode will write the file to a local temporary folder by default, but it can also store the content of the file within message data for convenience (requires code change).

###Config file options:###
* loop_delay: defines number of seconds the Xenode waits before running the Xenode process. Expects a float. 
* enabled: determines if the Xenode process is allowed to run. Expects true/false. 
* debug: enables extra debug messages in the log file. Expects true/false. 
* dropbox_path: specifies the dropbox folder where the file is expected to be read. Expects a string.    
* named_file: specifies name of the file to be read. Expects a string. 
* access_token: specifies the application access token for your Dropbox account. Expects a string. 

###Example Configuration File:###
* enabled: true
* loop_delay: 60
* debug: false
* dropbox_path: "/source"
* named_file: "hello.txt"
* access_token: "1234567890abcdefg"

###Example Input:###
* The Dropbox Reader Xenode does not expect nor handle any input.  

###Example Output:###
* msg.context = [{file_path=>"tmp_dir/hello.txt",file_name=>"hello.txt"}]
