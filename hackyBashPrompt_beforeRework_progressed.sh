#!/bin/bash

# testing how practical/feasable/usable/useful 'd be highlights in the bash PS1 prompt ;p
# current WIP usage: ./hackyBashPrompt.sh "\e[01;32m\xE2\x9A\xA1 \e[m"
# to get debug, in another term: while :; do cat < debugFifo; done;

# file(s) parsed to find matches:
# stores one name per line + its mapped color OR stores just 'types' ( function/alias/program/fifo/file/.. ) & their "highlight" color
# in either case, we 'll need fcns that check if some <stuff> exist, & if so, highlight it in the right color

# 1st very basic helper: splits the hiddenBuffer by spaces & try to find something that exist for each chunk obtained
parseBuffer(){
  parsedBuffer=""
  IFS=' ' read -a hidBufArr <<< "${1}"
  echo "-- chunks start --" > ./debugFifo
  for chunk in "${hidBufArr[@]}"; do
    # little dummy dumb test
    if [ "${chunk}" == "grenouille" ]; then 
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
      echo -e "${chunk}" > ./debugFifo
      parsedBuffer="${parsedBuffer} ${chunk}"
    fi
    # log stuff to the debugFifo to allow us to keep a clean output on the hackyPrompt ;)
    #echo -e "${chunk}" > ./debugFifo
  done
  # return the parsed buffer
  echo "${parsedBuffer}"
  
  echo -e "-- chunks end --\n\n" > ./debugFifo
  # TODO: for each chunk that has a matching <stuff_type>, replace it by <colorStartForSuchType>itself<colorEnd> before adding it to the visibleBuffer string, else just add it to it the string
}


# 2nd basic helper: returns a string depending on the type of the $var passed ( function/alias/program/fifo/file/.. )
# Nb: it's be also nice to know how the filetyped are checked against, to be able to use the standard $LS_COLORS [ + our overrides ] as well if wanted ( aka, by passing some flag / using a different keystroke )
getType(){
  if [ $(type -t "${1}") == "alias" ]; then echo "alias";
  elif [ $(type -t "${1}") == "function" ]; then echo "function";
  elif [ $(type -t "${1}") == "file" ]; then
    #then echo "file";
    # but WHAT TYPE OF FILE ?
    if [ ! $(which "${1}") == "" ]; then
      if [ $(xdg-mime query filetype $(which "${1}") ) == "application/x-shellscript" ]; then echo 'shellscript';
      elif $(xdg-mime query filetype $(which "${1}") ) == "application/x-executable" ]; then echo 'executable';
      elif [ $(xdg-mime query filetype $(which "${1}") ) == "inode/fifo" ]; then echo 'fifo';
      elif [ $(xdg-mime query filetype $(which "${1}") ) == "text/plain" ]; then echo 'text';
      else
        echo "'not which' file";
      fi
    else 
      #if [ ! which "${1}" == "" ]; then
      #  echo "which not empty"
      #else
        echo "'not which' file";
      #fi
    fi
  else echo "unrecognized";
  fi
}
# - the following works fine
getType(){
  fileType=$(type -t "${1}")
  if [ "${fileType}" == "alias" ]; then echo "alias";
  elif [ "${fileType}" == "function" ]; then echo "function";
  elif [ "${fileType}" == "file" ]; then echo "file";
  else echo "unrecognized";
  fi
}
# - the following works fine ( also =D )
getType(){
  fileType=$(type -t "${1}")
  if [ "${fileType}" == "alias" ]; then echo "alias";
  elif [ "${fileType}" == "function" ]; then echo "function";
  elif [ "${fileType}" == "file" ]; then echo "file";
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
#
getType(){
  fileType=$(type -t "${1}")
  if [ "${fileType}" == "alias" ]; then echo "alias";
  elif [ "${fileType}" == "function" ]; then echo "function";
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
    # check if we have a "special" key ( at least backspace & enter for now
    if [ "${char}" == $(tput kbs) ]; then 
      echo "[Backspace key]"> ./debugFifo; 
      if [ ! "${hiddenBuffer}" == "" ];then hiddenBuffer="${hiddenBuffer::-1}"; fi;
      visibleBuffer=$(parseBuffer "${hiddenBuffer}")
      # TODO: add check if previosu char in hiddenBuffer is a space & handle that by adding a '\b' before the ${fakeCursor}
      if [ "${hiddenBuffer:${#hiddenBuffer}-1}" == " " ];then echo -e "${eraseLine}${fakePrompt}\b${visibleBuffer} ${fakeCursor}\033[1A";
      else echo -e "${eraseLine}${fakePrompt}\b${visibleBuffer}${fakeCursor}\033[1A";
      fi
      #tput cuf $(( ${#visibleBuffer} + 2 ))
    elif [ "${char}" == "" ]; then echo "[Enter key]"> ./debugFifo;
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
  setterm -cursor off
#}
