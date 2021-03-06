#!/bin/bash

lehe=0
#python2.7 forward_sensitivity.py $lehe .1 .1 .1 1 1

# Run full number of cases and use timer
#: <<'EOF'    # Use to block this section of code
tmp=./tmp.txt # Temp file to store output and determine whether the run failed
logfile=./output/sensitivity/le_log.txt # Where to store the run, inputs, and time
log_ext=./output/sensitivity/ext_le.txt
> $logfile
> $log_ext
case=1        # Used to number the cases
for D in .01 #.1 1 10              # Diffusion coefficient
do
    for g in .01 #.1 1 10          # gammaD
    do
        for b in .01 #.1 1 10      # beta
        do
            for k in .01 .1 1 3 6 9  # k0
            do
                > $tmp # Clear temp
		printf "Case number %i: \n" $case >> $logfile
		printf "D0 = %f, gammaD = %f, beta = %f, k = %f \n" $D $g $b $k >> $logfile
                /bin/time -f '%e' -a -o $logfile python2.7 forward_sensitivity.py $lehe $D $g $k $b $case &>> $tmp
		#num_lines=$(cat $tmp | wc -l) # Count the lines of output
		last_step=$(cat $tmp | grep "Currently" | tail -c 4)
		#if [ $num_lines -ne 2 ]       # A working program will have 2 lines (input list, then \n)
		if [ $last_step -ne 224 ]
		then
		    printf "FAILED: STOPPED AT %i \n" $last_step >> $logfile
		    grep -v "Currently" $tmp >> $log_ext
		fi
                case=$(($case + 1))
            done
        done
    done
done
#EOF

