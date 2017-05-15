#!/bin/bash

#Shiny Counter v1.0 by Syphist
#Licensed under GPLv3

COUNT=0 #The amount of Encounters or SRs done on the CURRENT phase
PHASE=1 #Your shiny phase
TOTAL=0 #Total count for ALL phases
MODE=0 #0 = number only, 1 = header, 2 = footer, 3 = header and footer
CUT=0 #0 = Don't cut header or footer, 1 = length of string
NOFILE=0 #If set to non 0 this will prevent file writing

writefile ()
{ #$1 = filename, $2 = value
  if [ ! "$NOFILE" = 0 ]; then #return the method early if file writing is disabled
    return 0
  fi

  output=""

  if [ -z "$1" ] && [ -z "$2" ]; then #check if all parameters are passed
    echo "Invalid number of parameters in writefile()"
    return 1
  fi
  
  if [ "$MODE" = 1 ] || [ "$MODE" = 3 ]; then #check for header
    if [ "$CUT" = 0 ]; then
      output=$(cat header) #add the header
    else
      output=$(cat header | rev | cut -c ${#2}- | rev) #cut the header if the value is longer than 1 character
    fi
  fi

  output+="$2"

  if [ "$MODE" = 2 ] || [ "$MODE" = 3 ]; then #check for header
    if [ "$CUT" = 0 ]; then
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

Application Controls:
  space, enter   Increment the counter.
  0              Increment the phase, resets the regular counter, but not total.
  z              Manually set the count value.
  x              Manually set the phase value.
  c              Manually set the total count value.
  q              Manually set the mode.
  w              Manually toggle cutting on and off.
  e              Manually toggle file output on and off.
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
    echo "Count: "$COUNT
    ;;
  p) #Set the phase from the -p argument
    PHASE=$OPTARG
    echo "Phase: "$PHASE
    ;;
  t) #Set the total from the -t argument
    TOTAL=$OPTARG
    echo "Total: "$TOTAL
    ;;
  esac
done


if [ "$TOTAL" = 0 ]; then #set the total to the count if it is 0
  TOTAL=$COUNT
fi

if [ "$NOFILE" = 0 ]; then #files will only be created if NOFILE is set to 0
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
  if [ "$input" = "" ]; then #press space or enter to add 1 to the counter
    COUNT=$(( COUNT + 1 ))
    TOTAL=$(( TOTAL + 1 ))
    echo "Count: "$COUNT

    writefile "count" "$COUNT"
  elif [ "$input" = "0" ]; then #press 0 to start a new phase
    PHASE=$(( PHASE + 1 ))
    COUNT=0
    echo "Total Count: "$TOTAL
    echo "Phase: "$PHASE
    writefile "count" "$COUNT"
    writefile "phase" "$PHASE"
    writefile "total" "$TOTAL"
  elif [ "$input" = "z" ]; then #press z to change count
    echo -n "Please enter current count: "
    read -r COUNT
    writefile "count" "$COUNT"
  elif [ "$input" = "c" ]; then #press x to change phase
    echo -n "Please enter current phase: "
    read -r PHASE
    writefile "phase" "$PHASE"
  elif [ "$input" = "v" ]; then #press c to change current total count
    echo -n "Please enter current total count: "
    read -r TOTAL
    writefile "total" "$TOTAL"
  elif [ "$input" = "q" ]; then #press q to change mode
    echo -n "Please enter desired mode (invalid values = 0): "
    read -r MODE
    if [ ! "$MODE" = 1 ] && [ ! "$MODE" = 2 ] && [ ! "$MODE" = 3 ]; then #sets invalid entry to 0
      MODE=0
    fi
    echo "Your new mode is: ""$MODE"
  elif [ "$input" = "w" ]; then #swap cut on and off
    if [ "$CUT" = 0 ]; then
      CUT=1
      echo "Cutting is now ENABLED"
    else
      CUT=0
      echo "Cutting is now DISABLED"
    fi
  elif [ "$input" = "e" ]; then #enable or disable file writing
    if [ "$NOFILE" = 0 ]; then
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
