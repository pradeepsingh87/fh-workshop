# Create a directory to download data unless if it not exist already
if not exist  ~/environment/fh-workshop/data mkdir  ~/environment/fh-workshop/data

# Change directory to the data directory
cd  ~/environment/fh-workshop/data

# Download the data for log to data directory
curl http://www.secrepo.com/maccdc2012/http.log.gz -o http.log.gz

# Run the python script to read data from the log file and send to the firehose stream FH-Stream-DirectPut
# The script starts sending simulated web access logs to firehose. It will stop after 10000 messages. You can run it again to send more messages.
python ~/environment/fh-workshop/app/send.py   -n 10000 -s FH-Stream-DirectPut


# Kinesis firehose takes this data and copies over to S3 in near real time . 
# The file is compressed in GZIP format on S3. When you download it, S3 automatically decompresses the file. 
# You don't need to uncompress the downloaded file in your local machine, just open the file with a text editor and check the incoming messages:

# This automatic file decompression happens for files stored by Firehose. 
# If you manually put a compressed file on S3, it may not be automatically decompressed when downloading unless you change the file meta data to denote that it is compressed.
