from google.cloud import storage, bigquery
import re

table_name = "terraform-test-316516:DATA.VENDOR_REGEXP_LIST"
target_bucket_name = 'ericjm24-temp-bucket'
query = (
"""
select VENDOR_NAME, CONVEYOR_NAME, REGEX_MATCH, REGEX_REPLACE_INPUT, REGEX_REPLACE_OUTPUT
from {}
where VENDOR_SFTP_BUCKET = "{}"
"""
)

def parse_filename(filename, reg_match, reg_sub_in=None, reg_sub_out=None):
    if not re.match(reg_match, filename):
        return None
    if (not reg_sub_in) and (not reg_sub_out):
        return filename
    if not reg_sub_in:
        return re.sub(reg_match, reg_sub_out, filename)
    return re.sub(reg_sub_in, reg_sub_out, filename)


def main(event, context):
    my_query = query.format(table_name, event['bucket'])
    bq_client = bigquery.Client()
    storage_client = storage.Client()
    source_bucket = storage_client.get_bucket(event['bucket'])
    target_bucket = storage_client.get_bucket(target_bucket_name)
    query_job = bq_client.query(my_query)
    rows = query_job.result()
    for row in rows:
        out_file = parse_filename(event['filename'], row['REGEX_MATCH'], row['REGEX_REPLACE_INPUT'], row['REGEX_REPLACE_OUTPUT'])
        if out_file:
            source_bucket.copy_blob(event['filename'], target_bucket, 'incoming/'+out_file)