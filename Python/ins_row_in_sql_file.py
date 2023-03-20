#!/usr/bin/python
# -*- coding: cp1251 -*-
import os
import stat
from os import listdir

# Path to files
path = r'C:\test'

os.chmod(path, 0o777)

# Take filenames from folder
path_content = [el for el in listdir(path) if el.endswith('.sql')]  # take only .sql files from folder

for i in path_content:
    full_path = path + "\\" + i
    v_cnt = 0
    with open(full_path, 'r') as input_file:
        lines = input_file.read().splitlines()
    with open(full_path, "w+") as output:
        for line in lines:
            output.write(line + '\n')
            if line.find("$$P_REG_NAME") != -1 and v_cnt == 0:
                output.write(r"    some_text" + '\n') # text for insert
                v_cnt = 1 # helps to prevent duplicates
    if v_cnt == 0: # if we didn't insert row show filename with path
        print(full_path)
