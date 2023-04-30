import logging
import argparse
import random
import socket
import struct
import time

# This script simulates API access logs and writes the logs into /tmp/api.log.

logger = logging.getLogger()

fh = logging.FileHandler('/tmp/api.log')
fh.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s %(levelname)s: %(message)s')
fh.setFormatter(formatter)
logger.addHandler(fh)

logger.setLevel(logging.DEBUG)

parser = argparse.ArgumentParser(__file__, description="Firehose event generator")
parser.add_argument("--num", "-n", dest='num_messages', help="Number of messages to send, 0 for inifnite, default is 1000", type=int, default=1000)

args = parser.parse_args()

num_messages = args.num_messages

sent = 0
while True:
    uri = random.choice(["/employee", "/inventory", "/leave", "/item", "/assign", "/report"])
    method = random.choices(["GET", "PUT", "POST", "DELETE"], weights=[0.6, 0.2, 0.15, 0.05], k=1)[0]
    response = random.choices(["200", "500", "403"], weights=[0.9, 0.03, 0.07], k=1)[0]
    ip = socket.inet_ntoa(struct.pack('>I', random.randint(0x0a0a0000, 0x0a0affff)))
    msg = f"{ip} 8080 {method} {uri} {response}"

    logger.info(msg)

    sent += 1
    if sent % 100 == 0:
        print(f"{sent} api logs created")

    if sent >= num_messages and num_messages > 0:
        break

    time.sleep(0.01)
