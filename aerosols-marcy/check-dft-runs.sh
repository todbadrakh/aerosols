#!/bin/bash

total=`ls -l *.com | wc -l`
normal=`grep Normal *.log | wc -l`
failed=`grep Error *.log | wc -l`

grep Normal *.log
grep Error *.log
echo " "
echo "==> TOTAL CALCULATIONS: $total"
echo "--> SUCCESSFUL CALCULATIONS: $normal"
echo "--> FAILED CALCULATIONS: $failed"

