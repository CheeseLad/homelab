import subprocess
import datetime
import os
from login import db_host, db_user, db_password, db_name

current_directory = os.getcwd()

backup_path = '"' + current_directory + '/backup/' + '"'

timestamp = datetime.datetime.now().strftime('%Y-%m-%d-%H-%M-%S')
backup_file = f'{db_name}-{timestamp}.sql'

command = f'mysqldump -h {db_host} -u {db_user} -p{db_password} {db_name} > {backup_path}{backup_file}'

with open('logs.txt', 'a') as log:
    log.write(f'Backup started at {timestamp}\n')

subprocess.run(command, shell=True)
