# hacky-bash-prompt
###Hacky highlights in the bash interactive PS1 prompt ;p
<img src="http://stephaneadamgarnier.com/hackyBashPrompt/hackyBashPrompt_1.png" align="" height="" width="" >
standard types are recognized & highlighted according to the $LS_COLORS standards & tweaks

<img src="http://stephaneadamgarnier.com/hackyBashPrompt/hackyBashPrompt_2.png" align="" height="" width="" >
custom patterns, not present / relying on $LS_COLORS, can be added / supported as well

<img src="http://stephaneadamgarnier.com/hackyBashPrompt/hackyBashPrompt_3.png" align="" height="" width="" >
supports multiple commands separated by ";" [ but currently NOT multiline stuff with "\" -> gotta bind it ;p ]

<img src="http://stephaneadamgarnier.com/hackyBashPrompt/hackyBashPrompt_4.png" align="" height="" width="" >
supports aliases & other custom functions, just needs sourcing ;p [ & hence, supports [stag_ils](https://github.com/stephaneAG/stag_ils) for iconized ls ;D ]

<img src="https://cdn.rawgit.com/github/octicons/master/svg/alert.svg" width="25"> very early WIP:
- tab completion NOT implemented yet, POC code resides in [codeExcerptForTabCompletion.tef](https://github.com/stephaneAG/hacky-bash-prompt/blob/master/codeExcerptForTabCompletion.tef)
- history partially implemented [ & acting weird about the commnd n° ;p ], but UP/DOWN arrows NOT available [ yet ? ]


My personal attempt ( in a few hours POC, mainly spent diggin skills 'round the web ;p ) at a colored interactive prompt

After hearing about it, share goals with the "fishshell", which is wayy more advanced [ & I suppose, wayy less hacky .. ]

[fishshell](http://fishshell.com/docs/current/tutorial.html)

Nb: one of the constraints that I imposed upon myself was keeping using the bash shell, as well as using only bash scripts to "make that bear dance" ;P
