#################################################################################################################################################################
############################################## Steps for Direct Put Method ######################################################################################
#################################################################################################################################################################

# Create a directory to download data unless if it not exist already
if not exist  ~/environment/fh-workshop/data mkdir  ~/environment/fh-workshop/data

# Change directory to the data directory
cd  ~/environment/fh-workshop/data

# Download the data for log to data directory
curl http://www.secrepo.com/maccdc2012/http.log.gz -o http.log.gz

# Run the python script to read data from the log file and send to the firehose stream FH-Stream-DirectPut
# The script starts sending simulated web access logs to firehose. It will stop after 10000 messages. You can run it again to send more messages.
python ~/environment/fh-workshop/app/send_with_direct_put.py   -n 10000 -s FH-Stream-DirectPut


# Kinesis firehose takes this data and copies over to S3 in near real time . 
# The file is compressed in GZIP format on S3. When you download it, S3 automatically decompresses the file. 
# You don't need to uncompress the downloaded file in your local machine, just open the file with a text editor and check the incoming messages:

# This automatic file decompression happens for files stored by Firehose. 
# If you manually put a compressed file on S3, it may not be automatically decompressed when downloading unless you change the file meta data to denote that it is compressed.


#################################################################################################################################################################
############################################## Steps for Using Kinsis Agent #####################################################################################
#################################################################################################################################################################
# Amazon Kinesis Agent is a standalone Java software application that offers an easy way to collect and send data to Kinesis Data Firehose. 
# The agent continuously monitors a set of files and sends new data to your Kinesis Data Firehose delivery stream. The agent handles file rotation, checkpointing, and retry upon failures. 
# It delivers all of your data in a reliable, timely, and simple manner. It also emits Amazon CloudWatch metrics to help you better monitor and troubleshoot the streaming process.

sudo yum install –y aws-kinesis-agent

# Now, we need to create a configuration file for the Kinesis Agent. First, we need to retrieve the Role ARN which was created during the Setting Up process to allow Kinesis Agent access Firehose. 
# Type the following command in the shell window:

aws iam get-role --role-name FH-KinesisAgentFirehoseRole | grep Arn
     "Arn": "arn:aws:iam::332045890583:role/FH-KinesisAgentFirehoseRole"
     
# Update agent.json file with above ARN . Make sure you also update the deliveryStream to the one that you created .

# Copy the agent.json file to below path
sudo cp agent.json /etc/aws-kinesis/agent.json

# Run the following commands in the shell window to start the Kinesis Agent:
sudo service aws-kinesis-agent start

# If you want Kinesis Agent to be started automatically when the system restarts, you need to run the following command as well:
sudo chkconfig aws-kinesis-agent on

# Now run the script to generate the logs in /tmp/api.log
cd  ~/environment/fh-workshop/app
python generate_api_log.py -n 10000

# Go to roles.tf and update the line for  "Service" = "firehose.amazonaws.com" and replace that with AWS": "arn:aws:iam::xxxxxxxxxxxx:role/service-role/AWSCloud9SSMAccessRole"