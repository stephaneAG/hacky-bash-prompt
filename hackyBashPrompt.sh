#!/bin/bash

# R: started as: ^^ ( What a journey !)
#myHackyPrompt(){ hiddenBuffer=""; visibleBuffer=""; fakePrompt="\e[01;32mF \e[m"; echo -en "\033[1A${fakePrompt}"; while IFS= read -s -n1 char; do hiddenBuffer="${hiddenBuffer}${char}"; visibleBuffer="${hiddenBuffer}"; echo -e "${fakePrompt}\e[01;32m${visibleBuffer}\e[m \033[1A"; done }

# testing how practical/feasable/usable/useful 'd be highlights in the bash PS1 prompt ;p
# current WIP usage: ./hackyBashPrompt.sh "\e[01;32m\xE2\x9A\xA1 \e[m"
# to get debug, in another term: while :; do cat < debugFifo; done;
# for fun, try to copy paste the following in the console ( using the standard Ctrl-Shift-C : Ctrl-Shift-V ): echo "Lol petit tef !"; pwd; echo $DISPLAY
#
# quite logically, but not [ consciously ] intented in the first place: 
# -> calling the 'exit' builtin 'll quit the hacky prompt & not display O_O ( my custom kawai chars for return ocde other than 0 ;P )
#
# also, among other things, I'm quite proud of the following: it gets everything in a $var after a certain other $var
# ex: wanna get '~/Documents/hackyBashPrompt' from '/home/stephaneag/Documents/hackyBashPrompt' while $USER is 'stephaneag' ? EASY !
# echo "~${PWD#*${USER}}"
# ~/Documents/hackyBashPrompt

# IDEA TO IMPLM ( .. )
# file(s) parsed to find matches:
# stores one name per line + its mapped color OR stores just 'types' ( function/alias/program/fifo/file/.. ) & their "highlight" color
# in either case, we 'll need fcns that check if some <stuff> exist, & if so, highlight it in the right color

# the following may be needed to be able to call custom stuff
# allow aliases expansion while in a script
shopt -s expand_aliases
# ALL RIGHT !!! -> it works with aliases, but it was a not-so-godd idea to source bindings ( read, calls to 'bind' )
. ~/Documents/lsWithIcons/stag_ils.sh
# quickies ;p
alias ls='ls --color'
function ils(){ ls -Cw $(( $(tput cols) - 4)) --color "${@}" | stag_ils; }
#source ~/bashrc/.bash_stephaneag_aliases_sourcer 2>/dev/null
# 2>&1 >/dev/null
#if [ -f ~/.bash_stephaneag_aliases_sourcer ]; then . ~/.bash_stephaneag_aliases_sourcer; echo "aliases & fcns sourced !"; fi;
#if [ -f /home/stephaneag/.bash_stephaneag_aliases_sourcer ]; then . /home/stephaneag/.bash_stephaneag_aliases_sourcer; echo "aliases & fcns sourced !"; fi;

# added to allow working seemlessly with the standard history file
HISTFILE="/home/stephaneag/.bash_history"
# read the history when entering the hacky prompt
history -r;
#history -c; history -r;

# make the history work from a script ?
set -o history

# cleanup fcn
exitPrompt(){
  # dummy tests: passing the buffer through 'stag_ils' to get the colors replaced by colored icons ;P
  #iconizedBuf=$("${parsedBuffer}" | stag_ils)
  #echo -e "\033[1A${eraseLine}${fakePrompt}\b${visibleBuffer} ${fakeCursor}\033[1A";
  # the following line allows us to get rid of the fake cursor when the user hit enter after finished typing a previous command
  echo -e "${eraseLine}${fakePrompt}\b${visibleBuffer} \033[1A";

  # pass the command to be executed by the PS1's PROMPT COMMAND ( it 'll need to check for the content of a $var that 'd store the in-wating cmds, & also check another to know which prompt to return to )
  echo;
  eval "$hiddenBuffer"
  # the above works fine, but the below one allows to redirect only the errors to a $var ( ex: to tread them & remove mentions to our prompt script)
  # the below is commented out for the moment as it has the nasty side-effect of preventing output from valid commands for later troubled ones .. 
  #errors=$(eval "$hiddenBuffer" 2>&1 > /dev/null)
  #echo "ERRORS: $errors"
  returnCode="$?"
  #echo "return code for evaluated command: ${returnCode}"
  # NEAT: push our command to the history WITHOUT EXECUTING IT :D
  #HISTFILE="/home/stephaneag/.bash_history"
  #echo "$HISTFILE"
  #history -s 'echo Trololoooo' # works fine
  history -s "$hiddenBuffer"
  # quick fix, as it seems my script messes with my current $PROMPT_COMMAND history num
  # TODO: check if the following fix works in a "clean" term [ aka, one I didn't mess up .. ]
  #export HISTCMD=$(( $HISTCMD + 1 ))
  histCmdNum="${HISTCMD}"
  # the following allows the commands typed in our hacky prompt to be present in our regular history :D
  # append to history immediately -> clear history -> read history file [ code extracted from my .bash_stephaneag_history that was used for $PROMPT_COMMAND]
  # DONE: ( Nb ) we could even read the history when initiated, in case the user/admin wishes to use the history command right after entering the hacky prompt ;P
  #history -a; history -c; history -r;
  #history -a;
  # TODO determine if the above is actually needed  

  # TODO: get the history n° of the last command in history => $HISTCMD ?
  # TODO: capture the return code of eval
  # TODO: redirect errors of eval [ & show them in a nice manner ] as well as capture it's return code
  #echo -e "\bCleaning up .."

  # the below call exits the hackyBashPrompt & returns to the standard PS1 prompt
  #setterm -cursor on;
  #exit 0;

  # to return to our hacky prompt instead, while still mimixking the original PS1 ( not to say, integrating it ;p )
  hiddenBuffer=""; 
  visibleBuffer="";
  # TODO: get $USER -> stephaneag
  #echo "user: ${USER}"
  # TODO: get $HOSTNAME -> zenbook
  #echo "hostname: ${HOSTNAME}"
  # TODO: get $PWD & strip the first 2 chunks ( /<stuff>/<stuff> )
  #echo "tilde-pwd: ~${PWD#*${USER}}"
  ps1start="\e[38;5;208m\u2234\e[0m\n( \e[01;34m\u2605 ${returnCode}\e[0m \e[38;5;202m\xE2\x8C\x9B ${histCmdNum}\e[0m "
  ps1prevsucc=$( if [ ${returnCode} = 0 ]; then echo -e "\e[33m^_^\e[0m"; else echo "\e[31mO_O\e[0m"; fi; )
  #ps1end="${debian_chroot:+($debian_chroot)}\033[01;32m${$USER}@${HOSTNAME}\033[00m:\033[01;34m~${PWD#*${USER}}\033[00m\n\033[01;32m$\033[0m "
  ps1end=" ) \033[01;32m${USER}@${HOSTNAME}\033[00m:\033[01;34m~${PWD#*${USER}}\033[00m\n\033[01;32m\$\033[0m "
  #ps1end=" ) \n\033[01;32m\$\033[0m "
  #ps1end=" ) ${USER}\n\033[01;32m\$\033[0m "
  echo -e "${ps1start}${ps1prevsucc}${ps1end}"
  #echo;
  echo -e "\033[1A${eraseLine}${fakePrompt}\b${visibleBuffer} ${fakeCursor}\033[1A";
}


# basic helper that makes available an associative array with each type as key & corresponding style as value
# to get an iconized list of the below stuff, why not try the following ;P :genColorMapArray | stag_ils 
genColorMapArray(){
  #declare -A COLORMAP # made global so as to be able to access it from other fcns ( we could also have passed it as a param )
  #declare -a COLORMAP=() # R: -a => indexed array / -A => associative array
  echo "\n\n-- colormap start --" > ./debugFifo
  while read line; do
    if [ ! "${line:0:1}" == "#" ]; then
      echo -e "\e[${line#*:}m${line%:*}\e[m   ${line}" > ./debugFifo;
      COLORMAP["${line%:*}"]="${line#*:}"
      #lineType="${line%:*}"
      #lineStyle="${line#*:}"
    fi
  done < ./hackyColorMap
  echo "-- colormap end --\n\n" > ./debugFifo
  
  # print all keys ( supported types )
  #echo "${!COLORMAP[@]}"
  # print all value ( types' styles )
  #echo "${COLORMAP[@]}"
}


# 1st very basic helper: splits the hiddenBuffer by spaces & try to find something that exist for each chunk obtained
parseBuffer(){
  parsedBuffer=""
  IFS=' ' read -a hidBufArr <<< "${1}"
  echo "-- chunks start --" > ./debugFifo
  for chunk in "${hidBufArr[@]}"; do
    # get the type of the chunk if any & use the corresponding color map
    # NOMORE_TODO: add a fix so that chunkc starting with '-' are returnedas unrecognized & not even passed to 'type -t' ( throws an error )
    # concerning the above concern: added a '2>/dev/null' -> easy, quick, & clean
    chunkType=$(getType "${chunk}")
    echo -e "Chunk type: ${chunkType}" > ./debugFifo
    if [ ! "${chunkType}" == "unrecognized" ]; then
      # the type returned seems supported, thus we directly use the corresponding style from the color map
      parsedChunk="\e[${COLORMAP[${chunkType}]}m${chunk}\e[m";
      parsedBuffer="${parsedBuffer} ${parsedChunk}"
      # log stuff to the debugFifo to allow us to keep a clean output on the hackyPrompt ;)
      #echo "COLORMAP: ${!COLORMAP[@]}" > ./debugFifo
      echo -e "${parsedChunk}" > ./debugFifo
    # little dummy dumb test - not using the $chunkType since it was written before & actually doesn't care about the 'type' but instead focuses on an hardocded value ( there could be more of them, or another )
    elif [ "${chunk}" == "grenouille" ]; then 
      parsedChunk="\e[01;32m${chunk}\e[m";
      # replace every occurences of the chunk by the above - we could also have done things cleaner by using some $parsedBuff var & using that than ( we'll see .. )
      # DONE: replace the current way of doing things by adding either original chunk or parsed chunk to the output instead of replacing all -> dumb ex: grenouilleS != grenouille ;D
      #visibleBuffer="${visibleBuffer//grenouille/TEFOU}"
      #visibleBuffer="${visibleBuffer//$chunk/$parsedChunk}"
      # ABOVE ONE WAS USED BEFORE REWORK
      parsedBuffer="${parsedBuffer} ${parsedChunk}"
      # log stuff to the debugFifo to allow us to keep a clean output on the hackyPrompt ;)
      echo -e "${parsedChunk}" > ./debugFifo
      # R: don't know the reason why, but the above issues a glitch that return the us to the prompt in the first terminal ( ?! )
      #echo -e "${chunk}" > ./debugFifo
    else
      # log stuff to the debugFifo to allow us to keep a clean output on the hackyPrompt ;)
      # TODO: add the following fix to remove the ';' that may suffix a chunk, for the chunk to be colored (ex: pwd; echo hello world )
      if [ "${#chunk}" -gt 1 ] && [ "${chunk:${#chunk}-1}" == ";" ];then
        chunkType=$(getType "${chunk::-1}")
        if [ ! "${chunkType}" == "unrecognized" ]; then
          # the type returned seems supported, thus we directly use the corresponding style from the color map
          parsedChunk="\e[${COLORMAP[${chunkType}]}m${chunk::-1}\e[m;";
          parsedBuffer="${parsedBuffer} ${parsedChunk}"
        else
          echo -e "${chunk}" > ./debugFifo
          parsedBuffer="${parsedBuffer} ${chunk}"
        fi
      else
        echo -e "${chunk}" > ./debugFifo
        parsedBuffer="${parsedBuffer} ${chunk}"
      fi
    fi
    # log stuff to the debugFifo to allow us to keep a clean output on the hackyPrompt ;)
    #echo -e "${chunk}" > ./debugFifo
  done
  # return the parsed buffer
  echo "${parsedBuffer}"
  # dummy tests: passing the buffer through 'stag_ils' to get the colors replaced by colored icons ;P
  #echo -e "${parsedBuffer}" | stag_ils
  
  echo -e "-- chunks end --\n\n" > ./debugFifo
  # TODO: for each chunk that has a matching <stuff_type>, replace it by <colorStartForSuchType>itself<colorEnd> before adding it to the visibleBuffer string, else just add it to it the string
}


# 2nd basic helper: returns a string depending on the type of the $var passed ( function/alias/program/fifo/file/.. )
# Nb: it's be also nice to know how the filetyped are checked against, to be able to use the standard $LS_COLORS [ + our overrides ] as well if wanted ( aka, by passing some flag / using a different keystroke )
getType(){
  fileType=$(type -t "${1}" 2>/dev/null)
  if [ "${fileType}" == "alias" ]; then echo "alias";
  elif [ "${fileType}" == "function" ]; then echo "function";
  elif [ "${fileType}" == "builtin" ]; then echo "builtin";
  elif [ "${fileType}" == "file" ]; then #echo "file";
    whichFile=$(which "${1}")
    if [ ! "${whichFile}" == "" ];then
      mimeType=$(xdg-mime query filetype "${whichFile}" 2>/dev/null)
      if [ "${mimeType}" == "inode/fifo" ]; then echo 'fifo';
      elif [ "${mimeType}" == "application/x-shellscript" ]; then echo 'shellscript';
      elif [ "${mimeType}" == "application/x-executable" ]; then echo 'executable';
      elif [ "${mimeType}" == "text/plain" ]; then echo 'text';
      else
        echo "unrecognized";
      fi
    else echo "standard file";
    fi
  else #echo "unrecognized";
    mimeType=$(xdg-mime query filetype "${1}" 2>/dev/null)
    if [ "${mimeType}" == "inode/fifo" ]; then echo 'fifo';
    elif [ "${mimeType}" == "application/x-shellscript" ]; then echo 'shellscript';
    elif [ "${mimeType}" == "application/x-executable" ]; then echo 'executable';
    elif [ "${mimeType}" == "text/plain" ]; then echo 'text';
    else
      echo "unrecognized";
    fi
  fi
}

# flush the fifo that may be currently cat-ted on another term using 'while :; do cat < debugFifo; done;'
# errr .. can't ! -> though, we could find some way to tell the debugFifo the clear the terminal it'srunnig in ? ( .. )

# declare our color map globally
declare -A COLORMAP
# before anything, populate our color map
genColorMapArray

#myHackyPrompt(){
  # as I have a little glitch sometimes, we disable the visual cursor ;p
  setterm -cursor off
  # a good-looking cursor could be done if reworking the way visible buffer is refreshed, aka having a fcn that refresh each <blink freq> & display output, while another 'd modify buffer on key press
  # before having the above & a nice blinking cursor, we can at least provide a fake cursor, so as to know where we're at (  nb: currently, we're only at the end, since no backspace nor directions are handled )
  fakeCursor="\e[107mT\e[m"
  eraseLine="\033[1000D\033[K"
  #cursorAtEOL="\033[${#visibleBuffer}C"
  visiBuffLen="${#visibleBuffer}"
  #cursorAtEOL="\033[${visiBuffLen}C"
  # the above may need a fcn to work properly - the following hardcoded one works flawlessly - maybe the above one needs to be in the while loop ?
  cursorAtEOL="\033[4C"
  hiddenBuffer=""; 
  visibleBuffer="";
  # for a little more style, we could pass a letter / icon as parameter to have it displayed instead of the '$ ' ( currently 'F ') default one
  fakePrompt="\e[01;32mF \e[m";
  fakePromptCharsLen=2
  # if passed a prompt item ( a replacement for the '$ ' or anything being the only/last line of the $PS1 prompt ), use that instead of the default
  # ex usage: ./hackyBashPrompt.sh "\e[01;32m\xE2\x9A\xA1 \e[m"
  if [ ! "${1}" == "" ]; then fakePrompt="${1}"; fi;
  echo -en "\033[1A${eraseLine}${fakePrompt}${fakeCursor}"; 
  while IFS= read -s -n1 char; do
    # needed debug for backspace & Cie
    #echo "char received: " $(echo -n $char | od -x) >  ./debugFifo
    echo "char received: " $(echo -n $char | hexdump -C) > ./debugFifo
    charHex=$(printf "\\\x%s" $(printf "$char"|xxd -p -c1 -u))
    echo "char hex: ${charHex}" > ./debugFifo
    # check if we have a "special" key ( backspace, enter, arrow keys, .. )
    if [ "${char}" == $(tput kbs) ]; then 
      echo "[Backspace key]"> ./debugFifo; 
      if [ ! "${hiddenBuffer}" == "" ];then 
        hiddenBuffer="${hiddenBuffer::-1}";
        visibleBuffer=$(parseBuffer "${hiddenBuffer}")
        # TODO: WIP -> not sure for the correct location of the below fix ..yet worked fine, FIRST TRY !!! yayyyyyyyyyyyyyyyy ;P
        if [ "${visibleBuffer}" == "" ];then visibleBuffer=" "; fi;
        # TODO: add check if previosu char in hiddenBuffer is a space & handle that by adding a '\b' before the ${fakeCursor}
        if [ "${hiddenBuffer:${#hiddenBuffer}-1}" == " " ];then echo -e "${eraseLine}${fakePrompt}\b${visibleBuffer} ${fakeCursor}\033[1A";
        else echo -e "${eraseLine}${fakePrompt}\b${visibleBuffer}${fakeCursor}\033[1A";
        fi
      fi
      #tput cuf $(( ${#visibleBuffer} + 2 ))
    elif [ "${char}" == "" ]; then 
      echo "[Enter key]"> ./debugFifo;
      exitPrompt
    #elif [ "${char}" == $(tput kcuu1) ]; then echo "[Up key]"> ./debugFifo;
    #elif [ "${char}" == "[" ]; then
    elif [ "${charHex}" == "\x1B" ]; then 
      echo "[maybe Arrow key]"> ./debugFifo;
      read -rsn1 -t 0.1 ndeChar
      ndeCharHex=$(printf "\\\x%s" $(printf "$ndeChar"|xxd -p -c1 -u))
      if [ "${ndeCharHex}" == "\x5B" ]; then
        echo "[surely Arrow key]"> ./debugFifo;
        read -rsn1 -t 0.1 arrowChar
        if [ "${arrowChar}" == "A" ]; then echo "[Up key]"> ./debugFifo;
        elif [ "${arrowChar}" == "B" ]; then echo "[Down key]"> ./debugFifo;
        elif [ "${arrowChar}" == "C" ]; then echo "[Right key]"> ./debugFifo;
        else echo "[Left key]"> ./debugFifo;
        fi
      fi
      #case "$tmp" in
      #  "A") echo "[Up key]"> ./debugFifo;;
      #  "B") echo "[Down key]"> ./debugFifo;;
      #  "C") echo "[Right key]"> ./debugFifo;;
      #  "D") echo "[Left key]"> ./debugFifo;;
      #esac
    elif [ "${charHex}" == "\x09" ]; then echo "[Tab key]"> ./debugFifo;
      # check whether it's the first or second time we hit the tab key consecutively
      # check the last char at the end of the hidden buffer ( aka "before" the cursor )
    elif [ "${char}" == " " ]; then echo "[Space key]"> ./debugFifo;
      hiddenBuffer="${hiddenBuffer}${char}";
      #hiddenBuffer="${hiddenBuffer}S";
      #hiddenBuffer="${hiddenBuffer}\\${char}";
      #visibleBuffer=$(parseBuffer "${hiddenBuffer}")
      #visibleBuffer=$(parseBuffer "${hiddenBuffer}${char}")
      visibleBuffer=$(parseBuffer "${hiddenBuffer}")
      echo -e "${eraseLine}${fakePrompt}\b${visibleBuffer} ${fakeCursor}\033[1A";
      #tput cuf $(( ${#visibleBuffer} + 2 ))
      #tput cuf 1
    else
      #echo -en "\033[1A"
      hiddenBuffer="${hiddenBuffer}${char}";
      #visibleBuffer="${hiddenBuffer}";
      #parseHiddenBuffer "${hiddenBuffer}"
      visibleBuffer=$(parseBuffer "${hiddenBuffer}")
      #echo -e "${eraseLine}${fakePrompt}\e[01;32m${visibleBuffer}\e[m \033[1A";
      #echo -e "${eraseLine}${fakePrompt}\e[01;32m${visibleBuffer}\e[m${fakeCursor}\033[1A";
      # R: the above is the last one auto-coloring in green the output
      echo -e "${eraseLine}${fakePrompt}\b${visibleBuffer}${fakeCursor}\033[1A";
      #echo -en "${cursorAtEOL}";
      #tput cuf $(( ${#visibleBuffer} + 2 ))
      #tput cuf $(( ${#visibleBuffer} + ${fakePromptCharsLen} ))
      #echo -e "${eraseLine}${fakePrompt}\e[01;32m${visibleBuffer}\e[m";
    fi
  done

  # restore the cursor
  setterm -cursor on
#}
