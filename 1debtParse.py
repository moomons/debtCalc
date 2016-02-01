#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import re
import string
import math

NumOfPeople = 7

NameToNum = {
    '罗': '1',
    '孟': '2',
    '冯': '3',
    '彭': '4',
    '王': '5',
    '雍': '6',
    '杨': '7',
}

Splitter = '，'

# rate = 4.7

# TODO: Read a text file line by line
inputfile = 'debtParse_input.txt'
# Load the text file
with open(inputfile) as f:
    # lines = f.readlines()
    lines = f.read().splitlines()
    # logfile_handle.write lines

# For each line
content_AUD = ''
content_CNY = ''
for line in lines:
    line = line.strip()
    if line.startswith("#"):
        continue
    # Split by blank
    args = re.split('\s+', line.upper())
    CountStage = 0
    flag_AUD = 0
    currlinecontent = ''
    for arg in args:
        arg = arg.strip()
        if CountStage == 0:
            CountStage += 1
            # currlinecontent += NameToNum[arg] + '\t'
            creditor = NameToNum[arg]
            # print(creditor)
        elif CountStage == 1:
            CountStage += 1
            # print(arg)
            if arg.startswith('A$', 0, 2):
                # print(arg[2:])
                flag_AUD = 1
                amount = float(arg[2:])
            elif arg.startswith('CN¥', 0, 4):
                # print(arg[4:])
                flag_AUD = 0
                amount = float(arg[4:])
            else:
                print('Error: Invalid currency')
            # currlinecontent += arg[2:] + '\t'
            print('Amount: ' + str(amount))

        elif CountStage == 2:
            CountStage += 1
            # currlinecontent += NameToNum[arg] + '\n'
            subarg = re.split(Splitter, arg)

            if subarg == ['EVERYONE']:
                amount = amount / NumOfPeople
                # print 'test: ' + str(amount)
                for debtor in range(1, NumOfPeople + 1):
                    # print('Debtor: ' + str(debtor))
                    currlinecontent = creditor + '\t'
                    currlinecontent += str(amount) + '\t'
                    currlinecontent += str(debtor) + '\n'
                    if flag_AUD == 1:
                        content_AUD += currlinecontent
                    else:
                        content_CNY += currlinecontent
                        # print(currlinecontent)
            else:
                # print(len(subarg))
                # print('Not everyone')
                amount = amount / len(subarg)
                for debtor_cn in subarg:
                    currlinecontent = creditor + '\t'
                    currlinecontent += str(amount) + '\t'
                    currlinecontent += NameToNum[debtor_cn] + '\n'
                    if flag_AUD == 1:
                        content_AUD += currlinecontent
                    else:
                        content_CNY += currlinecontent
                        # print(currlinecontent)
        else:
            print('Error')
            # break # DEBUG ONLY
# First element: creditor: NameToNum[arg]
#         Second element:
#            Detect if the beginning is 'A$' or 'CN¥', build the matrix separately
#        Third element: debtor
#            if debtor is 'everyone'
#                for each name in NameToNum: ...
#            Split by '、'
#                for each item: ...

# Example:
# Input:
# 罗    A$32.00    孟、冯
# Output:
# 1    16.00    2
# 1    16.00    3
#
# ( Which means:
# 罗    A$16.00    孟
# 罗    A$16.00    冯)
#

# Write content_CNY to file
with open('debtParse_output_CNY.txt', 'w') as outputfile:
    outputfile = outputfile.write(content_CNY)
