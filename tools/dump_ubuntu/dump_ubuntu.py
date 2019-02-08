import datetime
import json
import os
import re
import shutil
import subprocess

# For enable database dump feature
# you need to install PostgreSQL 10
#
# How to install PostgreSQL 10 on Ubuntu:
# https://gist.github.com/alistairewj/8aaea0261fe4015333ddf8bed5fe91f8
import sys

_config_files_path_list = [
    '/var/lib/container/common/opt/privatix/config/dappctrl.config.local.json',
    '/var/lib/container/common/opt/privatix/config/dappvpn.config.json',
    '/var/lib/container/vpn/opt/privatix/config/dappvpn.config.json',
    '/opt/privatix/gui/settings.json',
    '/opt/privatix/gui/package.json',

    '/opt/privatix/gui/node_modules/dappctrlgui/settings.json',
    '/opt/privatix/gui/node_modules/dappctrlgui/package.json',
]

_log_folders_path_list = [
    '/var/lib/container/common/var/log/',
    '/var/lib/container/common/etc/var/log/',
    '/var/lib/container/vpn/var/log/openvpn/',
]

_binaries_that_supports_versions = [
    '/var/lib/container/common/root/go/bin/dappctrl',
    '/var/lib/container/common/root/go/bin/dappvpn',
]

_log_pattern = '(dappvpn|dappctrl|server)'
_zip_path = sys.argv[1] if len(sys.argv) > 1 else datetime.datetime.now().strftime('%y-%m-%d %H-%M-%S.zip')


def create_folder(root, name):
    folder_name = os.path.join(root, name)
    print('Creating folder: {}'.format(folder_name))
    os.mkdir(folder_name)
    return folder_name


def collect(folder, file):
    print('\tCopying: {}'.format(file))

    try:
        shutil.copy2(file, folder)
        print('\t\tok')

    except Exception as exception:
        print('\t\tfailed: {}'.format(exception))

    return file


def collect_configs(root):
    configs_folder = create_folder(root, 'configs')
    for config in _config_files_path_list:
        collect(configs_folder, config)


def collect_logs(root):
    logs_folder = create_folder(root, 'logs')
    for log_folder in _log_folders_path_list:
        if not os.path.exists(log_folder):
            continue

        print('Processing log folder: {}'.format(log_folder))
        for entry in os.listdir(log_folder):
            if re.match(_log_pattern, entry):
                collect(logs_folder, os.path.join(log_folder, entry))


def collect_database(root):
    try:
        main_config_name = _config_files_path_list[0]
        print('Trying open main config: {}'.format(main_config_name))
        with open(main_config_name) as f:
            config = json.load(f)
        db_connection_info = config['DB']['Conn']
        database_folder = create_folder(root, 'database')
        print('Trying to dump the DB: '.format(db_connection_info))
        subprocess.call(['pg_dump',
                         '-h', db_connection_info['host'],
                         '-p', db_connection_info['port'],
                         '-U', db_connection_info['user'],
                         '-f', os.path.join(database_folder, db_connection_info['dbname'] + '.sql'),
                         db_connection_info['dbname']])
        print('\t\tok')

    except Exception as exception:
        print('\t\tfailed: {}'.format(exception))


def collect_versions(root):
    versions_folder = create_folder(root, 'versions')
    with open(os.path.join(versions_folder, 'binary_versions.txt'), 'w+') as f:
        for binary in _binaries_that_supports_versions:
            try:
                print('\tExecute: {0} -version'.format(binary))
                result = subprocess.check_output([binary, '-version']).decode('utf-8')
                f.write('{0}\n{1}\n'.format(binary, result))
            except Exception as exception:
                print('\tfailed: {}'.format(exception))


def zip_folder(folder_name):
    shutil.make_archive(folder_name, 'zip', folder_name)


abs_zip_path = os.path.abspath(_zip_path)
root_folder = os.path.splitext(abs_zip_path)[0]

if not os.path.exists(root_folder):
    os.makedirs(root_folder)

collect_configs(root_folder)
collect_logs(root_folder)
collect_database(root_folder)
collect_versions(root_folder)
zip_folder(root_folder)

shutil.rmtree(root_folder)
