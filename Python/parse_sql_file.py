#!/usr/bin/python
# -*- coding: utf-8 -*-
from os import listdir
import re

# Path to files
path = r'C:\test'

# Take filenames from folder
path_content = [el for el in listdir(path) if el.endswith('.sql')]  # take only .sql files from folder


# Find all sources after words FROM or JOIN
query_pattern = r'(?:FROM|JOIN)\s+(\w+\.\w+)'

# tables variable list type
tables = []
for i in path_content:
    full_path = path + "\\" + i
    # Open file with sql queries
    with open(full_path, 'r') as f:
        content = f.read()
        i_tables = [source.upper() for source in re.findall(query_pattern, content, flags=re.IGNORECASE)]
        tables.extend(i_tables)

unique_tables = set(tables)  # remove duplicates

# set doesn't store sorted data, we need to convert it
lst_sorted = sorted(unique_tables, key=lambda x: x.split('.')[0])

for el in lst_sorted:
    print(el)