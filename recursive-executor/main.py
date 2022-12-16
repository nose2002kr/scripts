import os
import subprocess
from fnmatch import fnmatch
from configparser import ConfigParser

def get_files(dir: str,
              recur: bool,
              file_patterns: str) -> list:
    d = os.listdir(dir)
    dirs = []
    matched = []
    for file in d:
        relPath = dir + '/' + file
        if os.path.isdir(relPath):
            dirs.append(relPath)
            # print('dirs is appended ' + relPath)

        for pattern in file_patterns.split(';'):
            if fnmatch(file, pattern):
                matched.append(relPath)
                # print('matched is appended ' + relPath)
                break

    if recur:
        for dir in dirs:
            matched += get_files(dir, recur, file_patterns)

    return matched

def exec(files: list,
         command_template: str,
         expected_exit_code: int):
    for file in files:
        command = command_template.replace('{input}', file)
        exit_code = os.system(command)
        if exit_code != expected_exit_code:
            print(f'command "{command}" is terminated with unexpected exit code.')
        #else:
        #    print(f'command "{command}" is terminated.')



if __name__ == "__main__":
    config = ConfigParser()
    config.read('config.ini')

    search_config = config['Search']

    matched = get_files(search_config['directory'],
                        search_config['recursively'] == 'true',
                        search_config['allowFilePattern'])
    # print(matched)

    exec_config = config['Exec']

    exec(matched,
         exec_config['command'],
         int(exec_config['expectedExitCode']))

    print('Done.')
