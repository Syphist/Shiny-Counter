#!/bin/bash

#Shiny Counter v1.1 by Syphist
#Licensed under GPLv3

COUNT=0 #The amount of Encounters or SRs done on the CURRENT phase
PHASE=1 #Your shiny phase
TOTAL=0 #Total count for ALL phases
MODE=0 #0 = number only, 1 = header, 2 = footer, 3 = header and footer
CUT=0 #0 = Don't cut header or footer, 1 = length of string
NOFILE=0 #If set to non 0 this will prevent file writing
TEMP=0 #A temporary variable to allow invalid values to make the variable remain unchanged
TEMPC=0 #The variable to run checks against to determine if an invalid input was entered

cat << EOF
Shiny Counter v1.1 by Syphist <https://github.com/Syphist/Shiny-Counter>
Licensed under the GPLv3 <https://www.gnu.org/licenses/gpl-3.0.en.html>
Please consult with -h or the README.md for instructions
EOF

writefile ()
{ #$1 = filename, $2 = value
  if (( $NOFILE != 0 )); then #return the method early if file writing is disabled
    return 0
  fi

  output="" #set the output

  if [ -z "$1" ] || [ -z "$2" ]; then #check if all parameters are passed
    echo "Program Error: Invalid number of parameters in writefile()"
    echo "Please submit a bug report at: https://github.com/Syphist/Shiny-Counter/issues"
    return 1
  fi
  
  if (( $MODE == 1 )) || (( $MODE == 3 )); then #check for header
    if (( $CUT == 0 )); then
      output=$(cat header) #add the header
    else
      output=$(cat header | rev | cut -c ${#2}- | rev) #cut the header if the value is longer than 1 character
    fi
  fi

  output+="$2" #add the value to the output

  if (( $MODE == 2 )) || (( $MODE == 3 )); then #check for header
    if (( $CUT == 0 )); then
      output+=$(cat footer)
    else
      output+=$(cat footer | rev | cut -c ${#2}- | rev) #cut the footer if the value is longer than 1 character
    fi
  fi
  
  echo "$output" > "$1" #write to file

  return 0
}

show_help()
{
cat << EOF
Usage: bash counter.sh [-hxn] [-m MODE] [-c COUNT] [-p PHASE] [-t TOTAL]
A program to count encounters, phases, chain lengths, or soft resets until you find a shiny 
pokemon, file output is useful when using programs like OBS to output the results.

Application Options:
  -h              Show help options.
  -x              This option starts the program with the cutting of the header and/or 
                  footer enabled.
  -n              Starts the program without outputting a file.
  -m              Set the mode of the file output; 0 is output only; 1 is header and output 
                  only; 2 is footer and output only; 3 is header, output, and footer
  -c              Set the count value.
  -p              Set what phase you are on.
  -t              Set the total count value. (By default it is initialized to be the same 
                  as the count value)

Application Settings:
                  If set to 0 (default) the output files contain the output value only; if 
  Mode            1 the header and the ouput; if 2 the output and the footer; if 3 the 
                  header, output, and footer. Use -m to set this value at startup.

  Cut             If enabled this option cuts the header and footer based on output length. 
                  This value is disabled by default. Use -x to enable at startup.

  NoFile          If enabled this option disables file output. This value is disabled by 
                  default. Use -n to enable at startup.

Application Controls:
  space, enter    Increment the counter.
  0               Increment the phase, resets the regular counter, but not total.
  z               Manually set the count value.
  x               Manually set the phase value.
  c               Manually set the total count value.
  q               Manually set the mode.
  w               Manually toggle cutting on and off.
  e               Manually toggle file output on and off.

Github page: <https://github.com/Syphist/Shiny-Counter>
GNU GPLv3 License: <https://www.gnu.org/licenses/gpl-3.0.en.html>
EOF
}


#Command line arguments parsing
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "hxnm:c:p:t:" opt; do #find command line arguments
  case "$opt" in
  h) #Run help output
    show_help
    exit 0
    ;;
  x) #Set cut value to 1
    CUT=1
    echo "cut"
    ;;
  n) #Set nofile to 1
    NOFILE=1
    echo "nofile"
    ;;
  m) #Set the mode from the -m argument
    MODE=$OPTARG
    if [ ! "$MODE" = 1 ] && [ ! "$MODE" = 2 ] && [ ! "$MODE" = 3 ]; then #sets invalid entry to 0
      MODE=0
    fi
    echo "Mode: "$MODE
    ;;
  c) #Set the count from the -c argument
    COUNT=$OPTARG
    COUNT=$(( COUNT + 0 )) #Make sure count is a number
    echo "Count: "$COUNT
    ;;
  p) #Set the phase from the -p argument
    PHASE=$OPTARG
    PHASE=$(( PHASE + 0 )) #Make sure phase is a number

    if (( $PHASE < 1 )); then #Make sure that phase is at least 1
      PHASE=1
    fi

    echo "Phase: "$PHASE
    ;;
  t) #Set the total from the -t argument
    TOTAL=$OPTARG
    TOTAL=$(( TOTAL + 0 )) #Make sure total is a number
    if (($TOTAL >= $COUNT)); then
      echo "Total: "$TOTAL
    fi
    ;;
  esac
done

if (( $TOTAL < $COUNT )); then #set the total to the count if it is less than the count
  TOTAL=$COUNT
  echo "Total: "$TOTAL
fi

if (( $NOFILE == 0 )); then #files will only be created if NOFILE is set to 0
  if [ ! -f header ]; then #create the header file if it doesn't exist
    touch header
  fi
  
  if [ ! -f footer ]; then #create the footer file if it doesn't exist
    touch footer
  fi
  
  #write all the files
  writefile "count" "$COUNT"
  writefile "phase" "$PHASE"
  writefile "total" "$TOTAL"
fi


while true; do #loop until ctrl + c
  read -rsn1 input #read the button press

  #Input Space or Enter for count increment
  if [ "$input" = "" ]; then #press space or enter to add 1 to the counter
    COUNT=$(( COUNT + 1 ))
    TOTAL=$(( TOTAL + 1 ))

    if (( $PHASE > 1 )); then
      echo "Count: "$COUNT" | Phase: "$PHASE" | Total: "$TOTAL
    else
      echo "Count: "$COUNT
    fi

    writefile "count" "$COUNT"
    writefile "total" "$TOTAL"

  #Input 0 for phase increment
  elif [ "$input" = "0" ]; then #press 0 to start a new phase
    PHASE=$(( PHASE + 1 ))
    COUNT=0

    echo "Total Count: "$TOTAL
    echo "Phase: "$PHASE

    writefile "count" "$COUNT"
    writefile "phase" "$PHASE"https://github.com/Syphist/Shiny-Counter/issues
    writefile "total" "$TOTAL"

  #Input z for count set
  elif [ "$input" = "z" ]; then #press z to change count
    echo -n "Please enter current count: "
    TEMP=$COUNT #Save count in case of invalid input
    read -r COUNT
    TEMPC=$COUNT #Save new count to compare
    COUNT=$(( COUNT + 0 )) #Make sure count is a number

    if [ ! "$COUNT" = "$TEMPC" ]; then #An invalid input will result in the count not being set
      COUNT=$TEMP
    fi

    echo "Count: "$COUNT
    writefile "count" "$COUNT"

    if (( $TOTAL < $COUNT )); then #Check if the total is less than the count, and if so set it to the count
      TOTAL=$COUNT
      echo "Total: "$TOTAL
      writefile "total" "$TOTAL"
    fi

  #Input x for phase set
  elif [ "$input" = "x" ]; then #press x to change phase
    echo -n "Please enter current phase: "
    TEMP=$PHASE #Save phase in case of invalid input
    read -r PHASE
    TEMPC=$PHASE #Save new phase to compare
    PHASE=$(( PHASE + 0 )) #Make sure phase is a number

    if [ ! "$PHASE" = "$TEMPC" ] || (( $PHASE < 1 )); then #Make sure the Phase is at least 1 and was a number and if not revert it
      PHASE=$TEMP
    fi

    echo "Phase: "$PHASE
    writefile "phase" "$PHASE"

  #Input c for total count set
  elif [ "$input" = "c" ]; then #press c to change current total count
    echo -n "Please enter current total count: "
    TEMP=$TOTAL #Save total in case of invalid input
    read -r TOTAL
    TEMPC=$TOTAL #Save new total to compare
    TOTAL=$(( TOTAL + 0 )) #Make sure total is a number

    if [ ! "$TOTAL" = "$TEMPC" ]; then #A non numeric input will revert Total back to its original value
      TOTAL=$TEMP
    fi

    if (( $TOTAL < $COUNT )); then #Check if the total is less than the count, and if so set it to the count
      TOTAL=$COUNT
    fi

    echo "Total: "$TOTAL
    writefile "total" "$TOTAL"

  #Input q to change mode
  elif [ "$input" = "q" ]; then #press q to change mode
    echo -n "Please enter desired mode: "
    TEMP=$MODE
    read -r MODE
    if [ ! "$MODE" = 1 ] && [ ! "$MODE" = 2 ] && [ ! "$MODE" = 3 ]; then #sets invalid entry to 0
      MODE=$TEMP
    fi
    echo "Your new mode is: ""$MODE"

    #Write all the files to reflect mode changes
    writefile "count" "$COUNT"
    writefile "phase" "$PHASE"
    writefile "total" "$TOTAL"

  #Input w to toggle Cut
  elif [ "$input" = "w" ]; then #swap cut on and off
    if (( $CUT == 0 )); then
      CUT=1
      echo "Cutting is now ENABLED"
    else
      CUT=0
      echo "Cutting is now DISABLED"
    fi

  #Input e to toggle NoFile
  elif [ "$input" = "e" ]; then #enable or disable file writing
    if (( $NOFILE == 0 )); then
      NOFILE=1
      echo "File writing is now DISABLED"
    else
      NOFILE=0

      if [ ! -f header ]; then #create the header file if it doesn't exist
        touch header
      fi
  
      if [ ! -f footer ]; then #create the footer file if it doesn't exist
        touch footer
      fi

      echo "File writing is now ENABLED"
    fi
  fi
done
