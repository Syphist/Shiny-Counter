# Shiny Counter
This script will allow you to count your encounters, phases, chain lengths, or soft resets until you get a shiny Pokemon. This program keeps track of many variables, including the counter, what phase you are on, and what your total count across all phases is. You will see a live update shown in the command line to help you keep track of the action you just took and what the value was changed to. It will also output files by default (this can be disabled) which are intended to be used with programs like OBS to display live results of the counter.

It's as simple as downloading counter.sh and running it in bash. Keep in mind this will create files in the same directory as it so I would personally recommend giving it its own dedicated folder for organizational purposes.

# Usage
You simply need to run the command ```bash counter.sh``` (other command line interpreters are not tested) and the program will start. Although saving is not implemented (yet) so you will have to set the values. This can be accomplished 2 ways, both of which are explained below. The following sections will cover the Controls, Settings, Files, and Command Line Arguments.

## Controls
This section will go over the in application controls that will allow you to use the program and all the functions. All controls are a single key that correspond to a function. The keys are hardcoded and cannot be rebound without editing the code. (This may be changed in the future) Below is the list of controls.

* Space or Enter: This will increment the base counter and total counter. This is done whenever you want to add a count to your encounters, chain length, or soft resets.
* 0: This will increment the phase counter and reset the base counter (but not the total counter) and is used to indicate a new phase.
* z: This is used to manually set the value of the counter. This is one of the 2 ways to continue where you left off, or can be used to correct a mistake.
* x: This is used to manually set the value of the phase counter. This is one of the 2 ways to continue where you left off, or can be used to correct a mistake.
* c: This is used to manually set the value of the total counter. This is one of the 2 ways you can pick up where you left off, or can be used to correct a mistake.
* q: This is used to change the Mode setting. You can enter a number 0-3. Anything else will be parsed as 0.
* w: This is used to toggle the Cut setting between on and off.
* e: This is used to toggle the NoFile setting between on and off. 

## Settings
* Mode: This will change what is sent to the output files. The default mode is 0. If it is set to 0 you will only get the output value. If 1 you will get a header then the ouput. If 2 you will get the output then a footer. If 3 you will get a header, the ouput then a footer.
* Cut: This option will cut the header and/or footer based on the length of the output value. The default value is off. For example if your header is abc and your value is 9, it will output abc9, however if incremented to 10 you will get ab10, and if you reach 100 you will get a100. This is mainly useful when using monospace fonts on a display with a fixed width.
* NoFile: This is by far the simplest option. It supresses all file outputs. When toggled on it will create a header and footer file to prevent errors.

## Files
* header: This file contains the header. You can enter any set of characters you want to be at the start of every output file. This file can be changed while the program is running and the change will be immediate.
* footer: This file contains the footer. You can enter any set of characters you want to be at the end of every output file. This file can be changed while the program is running and the change will be immediate.
* count: This is the output file for your counter. You will want to use this to interface with the program to send the counter value (and possibly header and footer) to another desired program.
* phase: This is the output file for your phase counter. You will want to use this to interface with the program to send the counter value (and possibly header and footer) to another desired program.
* total: This is the output file for your total counter. You will want to use this to interface with the program to send the counter value (and possibly header and footer) to another desired program.

## Command Line Arguments
Like any other command line program you can use arguments with this script too. This is the second method of setting all the values when you first start the program.
* -h: This will display the help page embedded in the program and exit. You cannot run the program with this argument.
* -x: This will toggle the Cut setting on when the program starts, as the default is off.
* -n: This will toggle the NoFile setting on when the program starts, as the default is off.
* -m <value>: This will set your Mode setting to the <value> if it is a number 0-3, otherwise it will set it to 0.
* -c <value>: This will set the counter to the <value>. Anything that is not a number is counted as 0 by default in bash.
* -p <value>: This will set the phase counter to the <value>. Anything that is not a number is not accepted.
* -t <value>: This will set the total counter to the <value>. Anything that is not a number is not accepted.
