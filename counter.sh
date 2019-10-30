#!/bin/bash

#Shiny Counter v1.2 by Syphist
#Licensed under GPLv3

COUNT=0 #The amount of Encounters or SRs done on the CURRENT phase
INCREMENT=1 #The amount the counter increments
PHASE=1 #Your shiny phase
TOTAL=0 #Total count for ALL phases
MODE=0 #0 = number only, 1 = header, 2 = footer, 3 = header and footer
CUT=0 #0 = Don't cut header or footer, 1 = length of string
NOFILE=0 #If set to non 0 this will prevent file writing

NUMTEST='^[0-9]+$' #Regex for testing if an input is a number

#NOTE: Save files are 4 lines, each line contains what number each variable corresponds to, it will look like this:
#COUNT
#PHASE
#TOTAL
#INCREMENT

cat << EOF
Shiny Counter v1.2 by Syphist <https://github.com/Syphist/Shiny-Counter>
Licensed under the GPLv3 <https://www.gnu.org/licenses/gpl-3.0.en.html>
Please consult with -h or the README.md for instructions.

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
      output=$(cat "./meta/header.cfg") #add the header
    else
      output=$(cat "./meta/header.cfg" | rev | cut -c ${#2}- | rev) #cut the header if the value is longer than 1 character
    fi
  fi

  output+="$2" #add the value to the output

  if (( $MODE == 2 )) || (( $MODE == 3 )); then #check for header
    if (( $CUT == 0 )); then
      output+=$(cat "./meta/footer.cfg")
    else
      output+=$(cat "./meta/footer.cfg" | rev | cut -c ${#2}- | rev) #cut the footer if the value is longer than 1 character
    fi
  fi
  
  echo "$output" > "$1" #write to file

  return 0
}

show_help()
{
cat << EOF
Usage: bash ./counter.sh [-hxn] [-m MODE] [-s SAVE] [-c COUNT] [-p PHASE] [-t TOTAL] [-i INCREMENT]
A program to count encounters, phases, chain lengths, or soft resets until you find a shiny 
Pokemon, file output is useful when using programs like OBS to output the results.

Application Options:
  -h              Show help options.
  -x              This option starts the program with the cutting of the header and/or 
                  footer enabled.
  -n              Starts the program without outputting a file.
  -m              Set the mode of the file output; 0 is output only; 1 is header and output 
                  only; 2 is footer and output only; 3 is header, output, and footer
  -s              Specifies a save to load from within the ./saves directory. If you use
                  the arguments -c, -p, -t, or -i it will set those after the save is
				  loaded thus overwriting them in memory.
  -c              Set the count value.
  -p              Set what phase you are on. (Has to be greater than 1)
  -t              Set the total count value. (By default it is initialized to be the same 
                  as the count value and cannot be less than the count value)
  -i			  Set the increment in which the counter counts up at.

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
  c               Manually set the count value.
  p               Manually set the phase value.
  t               Manually set the total count value.
  i               Manually change the increment.
  r               Manually set the mode.
  t               Manually toggle cutting on and off.
  y               Manually toggle file output on and off.
  s               Save your current hunt to a file to be loaded later.
  l               Load one of your saved hunts from a file.
  h               Display controls in the application.
  q               Quit Application.

Github page: <https://github.com/Syphist/Shiny-Counter>
GNU GPLv3 License: <https://www.gnu.org/licenses/gpl-3.0.en.html>
EOF
}

#For some reason it hates me and will not let me do this comparison in the while statement
test_num()
{
  #if no input is received, return false
  if [ -z "$1" ]; then
	return 0
  fi
  
  #if input is not 0 and is a number return true
  if [[ "$1" =~ $NUMTEST ]] && [[ "$1" != "0" ]]; then
	return 1 
  fi
	
  #otherwise return false
  return 0
}

#writes a save file
writesave()
{
  if [ -z "$1" ]; then #check if a parameter is passed
    echo "Program Error: Invalid number of parameters in writesave()"
    echo "Please submit a bug report at: https://github.com/Syphist/Shiny-Counter/issues"
    return 1
  fi
  
  if [ ! -d "./saves/" ]; then #checks if the saves directory exists, and if it doesn't, makes one
    mkdir saves
  fi
  
  echo -e "$COUNT\n$PHASE\n$TOTAL\n$INCREMENT" > "./saves/$1" #write the save
  
  echo "$1 saved successfully."
}

loadsave()
{
  validsave=1

  if [ -z "$1" ]; then #check if a parameter is passed
    echo "You did not enter a file name, no file was loaded."
    return 1
  fi
  
  if [ ! -d "./saves/" ]; then #checks if the directory exists
    echo "No saves found, please make a save first or import one to the ./saves directory."
	mkdir saves #makes one if it doesn't
	return 0
  fi
  
  if [ ! -f "./saves/$1" ]; then #checks if the save you entered exists
    echo "The save you entered does not exist. No save was loaded."
	return 0
  fi
  
  #TODO: Add error checking
  
  loadc=$(sed '1q;d' "./saves/$1") #load the count into a temp variable
  
  if ! [[ "$loadc" =~ $NUMTEST ]]; then #checks if the loaded value is correct
    echo "The save contains the invalid count \"$loadc\"."
	validsave=0
  fi
  
  loadp=$(sed '2q;d' "./saves/$1") #load the phase into a temp variable
  
  if test_num "$loadp" ; then #checks if the loaded value is correct
    echo "The save contains the invalid phase \"$loadp\"."
	validsave=0
  fi
  
  loadt=$(sed '3q;d' "./saves/$1") #load the total into a temp variable
  
  if ! [[ "$loadt" =~ $NUMTEST ]] || (( $TOTAL < $COUNT )); then #checks if the loaded value is correct
    echo "The save contains the invalid count \"$loadt\"."
	validsave=0
  fi
  
  loadi=$(sed '4q;d' "./saves/$1") #load the increment into a temp variable
  
  if test_num "$loadi" ; then #checks if the loaded value is correct
    echo "The save contains the invalid phase \"$loadi\"."
	validsave=0
  fi
  
  if (( $validsave == 1 )); then
    COUNT=$loadc
	PHASE=$loadp
	TOTAL=$loadt
	INCREMENT=$loadi
  else
	echo "The save was not loaded due to errors."
	return 0
  fi
  
  echo "Count: "$COUNT" | Phase: "$PHASE" | Total: "$TOTAL" | Increment: "$INCREMENT
  
  return 0
}

#Command line arguments parsing
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "hxnm:s:c:p:t:i:" opt; do #find command line arguments
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
    echo "No files will be created."
    ;;
  m) #Set the mode from the -m argument
    MODE=$OPTARG
    if [ ! "$MODE" = 1 ] && [ ! "$MODE" = 2 ] && [ ! "$MODE" = 3 ]; then #sets invalid entry to 0
      MODE=0
    fi
    echo "Mode: "$MODE
    ;;
  s)
    if [ -d "./saves/" ] && [ -f "./saves/$OPTARG" ]; then
	  echo Loaded save.
	  loadsave $OPTARG
	else
	  echo "ERROR: The save you specified on launch does not exist."
	fi
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
  i) #Set the total from the -i argument
    INCREMENT=$OPTARG
    INCREMENT=$(( INCREMENT + 0 )) #Make sure increment is a number
    if ((INCREMENT <= 0)); then
	  INCREMENT=1
    fi
	echo "Increment: "$INCREMENT
    ;;
  esac
done

if (( $TOTAL < $COUNT )); then #set the total to the count if it is less than the count
  TOTAL=$COUNT
  echo "Total: "$TOTAL
fi

if (( $NOFILE == 0 )); then #files will only be created if NOFILE is set to 0
  
  if [ ! -d "./meta" ]; then #make the meta directory if it doesn't exist
	mkdir meta
  fi
  
  if [ ! -f "./meta/header.cfg" ]; then #create the header file if it doesn't exist
    touch "./meta/header.cfg"
  fi
  
  if [ ! -f "./meta/footer.cfg" ]; then #create the footer file if it doesn't exist
    touch "./meta/footer.cfg"
  fi
  
  #write all the files
  writefile "./meta/count.txt" "$COUNT"
  writefile "./meta/phase.txt" "$PHASE"
  writefile "./meta/total.txt" "$TOTAL"
fi


while true; do #loop until ctrl + c
  read -rsn1 input #read the button press
  input=$(echo $input | tr '[:upper:]' '[:lower:]') #make it lowercase
  
  #Input Space or Enter for count increment
  if [ "$input" = "" ]; then #press space or enter to add 1 to the counter
    COUNT=$(( COUNT + INCREMENT ))
    TOTAL=$(( TOTAL + INCREMENT ))

    if (( $PHASE > 1 )); then
      echo "Count: "$COUNT" | Phase: "$PHASE" | Total: "$TOTAL
    else
      echo "Count: "$COUNT
    fi

    writefile "./meta/count.txt" "$COUNT"
    writefile "./meta/total.txt" "$TOTAL"

  #Input 0 for phase increment
  elif [ "$input" = "0" ] || [ "$input" = ")" ]; then #press 0 to start a new phase
    PHASE=$(( PHASE + 1 ))
    COUNT=0

    echo "Count: "$COUNT" | Phase: "$PHASE" | Total: "$TOTAL

    writefile "./meta/count.txt" "$COUNT"
    writefile "./meta/phase.txt" "$PHASE"
    writefile "./meta/total.txt" "$TOTAL"

  #Input c for count set
  elif [ "$input" = "c" ]; then #press c to change count
    echo -n "Please enter current count: "
    read -r COUNT

    while ! [[ "$COUNT" =~ $NUMTEST ]] ; do
	  echo -n "\"$COUNT\""" is not a positive number. Please enter a positive number: "
	  read -r COUNT
	done

    echo "Count: "$COUNT
    writefile "./meta/count.txt" "$COUNT"

    if (( $TOTAL < $COUNT )); then #Check if the total is less than the count, and if so set it to the count
      TOTAL=$COUNT
      echo "Total: "$TOTAL
      writefile "./meta/total.txt" "$TOTAL"
    fi

  #Input p for phase set
  elif [ "$input" = "p" ]; then #press p to change phase
    echo -n "Please enter current phase: "
    read -r PHASE
	
	while test_num "$PHASE" ; do
	  echo -n "\"$PHASE\""" is not a positive number. Please enter in a number: "
	  read -r PHASE
	done

    echo "Phase: ""$PHASE"
    writefile "./meta/phase.txt" "$PHASE"

  #Input t for total count set
  elif [ "$input" = "t" ]; then #press t to change current total count
    echo -n "Please enter current total count: "
    read -r TOTAL
	
	while ! [[ "$TOTAL" =~ $NUMTEST ]] || (( $TOTAL < $COUNT )) ; do
	  echo -n "\"$TOTAL\""" is not a positive number or is lower than the count. Please enter in a valid number: "
	  read -r TOTAL
	done

    echo "Total: ""$TOTAL"
    writefile "./meta/total.txt" "$TOTAL"
    
  #Input i to change increment
  elif [ "$input" = "i" ]; then
    echo -n "Please enter in a new Increment: "
    read -r INCREMENT
	
	#This will test if it is a number
	while test_num "$INCREMENT" ; do
	  echo -n "\"$INCREMENT\""" is not a positive number. Please enter in a number: "
	  read -r INCREMENT
	done
	
	echo "Increment: ""$INCREMENT"

  #Input w to change mode
  elif [ "$input" = "w" ]; then #press w to change mode
    echo -n "Please enter desired mode (leave blank to remain unchanged): "
    read -r modetemp
	
	#check if the mode is not a valid value it will keep asking to retry
    while [ ! "$modetemp" = 0 ] && [ ! "$modetemp" = 1 ] && [ ! "$modetemp" = 2 ] && [ ! "$modetemp" = 3 ] && [ ! "$modetemp" = "" ]; do 
      echo -n "\"$modetemp\""" is not a valid mode. Please enter in a valid mode (leave blank to remain unchanged): "
	  read -r modetemp
    done
	
	#if it is not blank set the mode, if it is things will remain unchanged
	if [ ! "$modetemp" = "" ]; then 
	  MODE=$modetemp
	
      echo "Your new mode is: ""$MODE"

      #Write all the files to reflect mode changes
      writefile "./meta/count.txt" "$COUNT"
      writefile "./meta/phase.txt" "$PHASE"
      writefile "./meta/total.txt" "$TOTAL"
	else
	  echo "Your mode was not changed."
	fi

  #Input e to toggle Cut
  elif [ "$input" = "e" ]; then #swap cut on and off
    if (( $CUT == 0 )); then
      CUT=1
      echo "Cutting is now ENABLED"
    else
      CUT=0
      echo "Cutting is now DISABLED"
    fi

  #Input r to toggle NoFile
  elif [ "$input" = "r" ]; then #enable or disable file writing
    if (( $NOFILE == 0 )); then
      NOFILE=1
      echo "File writing is now DISABLED"
    else
      NOFILE=0
      
	  if [ ! -d "./meta" ]; then #make the meta directory if it doesn't exist
	    mkdir meta
	  fi
	  
      if [ ! -f "./meta/header.cfg" ]; then #create the header file if it doesn't exist
        touch "./meta/header.cfg"
      fi
  
      if [ ! -f "./meta/footer.cfg" ]; then #create the footer file if it doesn't exist
        touch "./meta/footer.cfg"
      fi

      echo "File writing is now ENABLED"
    fi
  
  #Input s to save your progress
  elif [ "$input" = "s" ]; then
    #get file name
	echo -n "Please enter in a save file name: "
	read -r savefile
	
	#writes the save
    writesave $savefile
  
  #Input l to load a save
  elif [ "$input" = "l" ]; then
    #get file name
    echo -n "Please enter a file to load: "
	read -r savefile
	
	#loads the save
	loadsave $savefile
  elif [ "$input" = "h" ]; then
  #print out the application controls
    echo "Application Controls:
  space, enter    Increment the counter.
  0               Increment the phase, resets the regular counter, but not total.
  c               Manually set the count value.
  p               Manually set the phase value.
  t               Manually set the total count value.
  i               Manually change the increment.
  q               Manually set the mode.
  w               Manually toggle cutting on and off.
  e               Manually toggle file output on and off.
  s               Save your current hunt to a file to be loaded later.
  l               Load one of your saved hunts from a file.
  h               Display controls in the application.
  q               Quit Application.
Please use the -h argument for more info if needed."

  #Press q to quit
  elif [ "$input" = "q" ]; then
    echo -n "Are you sure you want to quit? Unsaved changes will be lost! (y/N): "
	read -rn1 input
	input=$(echo $input | tr '[:upper:]' '[:lower:]') #make it lowercase
	
	#bash isn't happy with a multiple condition while loop so I am doing this a dumb way
	while true; do
	  #If yes exit
	  if [ "$input" = "y" ]; then
	    echo -e "\nGoodbye."
	    exit
	  fi
	  
	  #If n or blank reset
	  if [ "$input" = "n" ] || [ "$input" = "" ]; then
	    echo -e "\nApplication exit was cancelled."
	    break
	  fi
	  
	  #if it is invalid continue the loop
	  echo -en "\nInvalid input. Are you sure you want to quit? Unsaved changes will be lost! (y/N): "
	  read -rn1 input
	  input=$(echo $input | tr '[:upper:]' '[:lower:]') #make it lowercase	
	done
  fi
done
