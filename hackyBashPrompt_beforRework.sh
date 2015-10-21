#!/bin/bash

# testing how practical/feasable/usable/useful 'd be highlights in the bash PS1 prompt ;p
# current WIP usage: ./hackyBashPrompt.sh "\e[01;32m\xE2\x9A\xA1 \e[m"
# to get debug, in another term: while :; do cat < debugFifo; done;

# file(s) parsed to find matches:
# stores one name per line + its mapped color OR stores just 'types' ( function/alias/program/fifo/file/.. ) & their "highlight" color
# in either case, we 'll need fcns that check if some <stuff> exist, & if so, highlight it in the right color

# 1st very basic helper: splits the hiddenBuffer by spaces & try to find something that exist for each chunk obtained
parseHiddenBuffer(){
  IFS=' ' read -a hidBufArr <<< "${1}"
  echo "-- chunks start --" > ./debugFifo
  for chunk in "${hidBufArr[@]}"; do
    # little dummy dumb test
    if [ "${chunk}" == "grenouille" ]; then 
      parsedChunk="\e[01;32m${chunk}\e[m";
      # replace every occurences of the chunk by the above - we could also have done things cleaner by using some $parsedBuff var & using that than ( we'll see .. )
      # TODO: replace the current way of doing things by adding either original chunk or parsed chunk to the output instead of replacing all -> dumb ex: grenouilleS != grenouille ;D
      #visibleBuffer="${visibleBuffer//grenouille/TEFOU}"
      visibleBuffer="${visibleBuffer//$chunk/$parsedChunk}"
      # log stuff to the debugFifo to allow us to keep a clean output on the hackyPrompt ;)
      #echo -e "${parsedChunk}" > ./debugFifo
      # R: don't know the reason why, but the above issues a glitch that return the us to the prompt in the first terminal ( ?! )
      #echo -e "${chunk}" > ./debugFifo
    #else 
      # log stuff to the debugFifo to allow us to keep a clean output on the hackyPrompt ;)
      #echo -e "${chunk}" > ./debugFifo
    fi
    # log stuff to the debugFifo to allow us to keep a clean output on the hackyPrompt ;)
    #echo -e "${chunk}" > ./debugFifo
  done
  echo -e "-- chunks end --\n\n" > ./debugFifo
  # TODO: for each chunk that has a matching <stuff_type>, replace it by <colorStartForSuchType>itself<colorEnd> before adding it to the visibleBuffer string, else just add it to it the string
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
    #echo -en "\033[1A"
    hiddenBuffer="${hiddenBuffer}${char}";
    visibleBuffer="${hiddenBuffer}";
    parseHiddenBuffer "${hiddenBuffer}"
    #echo -e "${eraseLine}${fakePrompt}\e[01;32m${visibleBuffer}\e[m \033[1A";
    #echo -e "${eraseLine}${fakePrompt}\e[01;32m${visibleBuffer}\e[m${fakeCursor}\033[1A";
    # R: the above is the last one auto-coloring in green the output
    echo -e "${eraseLine}${fakePrompt}${visibleBuffer}${fakeCursor}\033[1A";
    #echo -en "${cursorAtEOL}";
    tput cuf $(( ${#visibleBuffer} + 2 ))
    #tput cuf $(( ${#visibleBuffer} + ${fakePromptCharsLen} ))
    #echo -e "${eraseLine}${fakePrompt}\e[01;32m${visibleBuffer}\e[m";
  done

  # restore the cursor
  setterm -cursor off
#}
