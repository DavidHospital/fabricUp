import boto3
import argparse
import logging
import os

logging.basicConfig(level=logging.INFO, format="%(asctime)s:%(levelname)s:%(message)s")


def find_backup_file(backups_dir, file_ext=".zip"):
    file_ext = file_ext if file_ext.startswith(".") else f".{file_ext}"
    files = [f"{backups_dir}/{file}" for file in os.listdir(backups_dir) if file.endswith(file_ext)]
    return max(files, key=os.path.getctime)

def backup_world(bucket, backup_filename):
    with open(backup_filename, "rb") as data:
        try:
            key = backup_filename.split("/")[-1]
            logging.info(f"Uploading world archive {key} to {bucket.name}...")
            archive = bucket.upload_fileobj(data, key)
        except Exception as e:
            logging.error(f"Failed to archive: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="s3_backup", description="backups a world archive to a s3 bucket")
    parser.add_argument("-d", "--backup-dir", required=True, help="directory containing local world archives (backups)")
    parser.add_argument("-b", "--bucket", required=True, help="s3 bucket name")

    args = parser.parse_args()
    print(args.backup_dir, args.bucket) 

    bucket = boto3.resource("s3").Bucket(args.bucket)
    
    backup_file = find_backup_file(args.backup_dir)
    if not backup_file:
        logger.error(f"No files to backup found in {backups_dir}")
        exit()
    backup_world(bucket=bucket, backup_filename=backup_file)
