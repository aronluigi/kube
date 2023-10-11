import argparse
import boto3
import os
import pyarrow.parquet as pq
from loguru import logger
import time

# --------------------------------
# CLI arguments
# --------------------------------
parser = argparse.ArgumentParser(
                    prog='replay',
                    description='Replay parquet files form source to destination',
                    epilog='----------')

parser.add_argument('-p', '--path',
                    help='ex: ./data/s3/user-event',
                    required=True)
parser.add_argument('-dt', '--destination_type',
                    choices=['kinesis', 'kafka'],
                    help='kinesis or kafka',
                    required=True)
parser.add_argument('-t', '--topic',
                    help='topic/stream name',
                    required=True)
args = parser.parse_args()

# --------------------------------
# Validation
# --------------------------------
path = os.path.join(os.getcwd(), args.path)
if os.path.isdir(path) is False:
    raise BaseException(f'{path} is not a directory')

# --------------------------------
# Implementation
# --------------------------------
kinesis_endpoint_url = 'http://127.0.0.1:4566'
kinesis_client = boto3.client('kinesis', endpoint_url=kinesis_endpoint_url)

def put_records_into_kinesis(records, stream_name):
    records_count = len(records)
    for i in range(0, records_count, 500):
        chunk = records[i:i + 500]  # Put up to 500 records at a time
        records_to_put = [{'Data': record,'PartitionKey': str(i)} for i, record in enumerate(chunk)]
        kinesis_client.put_records(StreamName=stream_name, Records=records_to_put)
        logger.debug(f'Put {len(chunk)} records to Kinesis stream.')
        time.sleep(1)

def create_kinesis_stream(stream_name, shard_count=1):
    try:
        kinesis_client.create_stream(StreamName=stream_name, ShardCount=shard_count)
        logger.info(f'Created Kinesis stream: {stream_name}')
    except kinesis_client.exceptions.ResourceInUseException:
        logger.info(f'Kinesis stream {stream_name} already exists.')

def handle_kinesis():
    logger.info('Starting Kinesis replay')

    create_kinesis_stream(args.topic)
    files = os.listdir(path)
    for file in files:
        parquet_file_path = os.path.join(path, file)
        logger.info(f'Importing file: {parquet_file_path}')
        # Read the Parquet file
        parquet_table = pq.read_table(parquet_file_path)
        # Convert Parquet data to a list of dictionaries
        parquet_records = parquet_table.to_pandas().to_dict(orient='records')
        # Convert records to bytes
        byte_records = [str(record).encode('utf-8') for record in parquet_records]
        # Put records into the Kinesis stream
        put_records_into_kinesis(byte_records, args.topic)
        logger.info('All records have been put into the Kinesis stream as bytes.')

if args.destination_type == "kinesis":
    handle_kinesis()
