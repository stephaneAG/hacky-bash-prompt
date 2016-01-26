/*
  Note to myself: aheeemmmm !!!
  R ==> the following is a quickie implm of a fake user input parsing & formatting somewhat related to whatever the heck
        I might have been doing with the "original" hacky bash prompt code ( .sh version(s) )
        The below POC code works flawlessly where it was coded, aka in the js console of a browser
        ( which DOESN'T provide colors highlighting, DAMN ! ^^ -> should I investigate/hack .toString even further ? .. ;p )
        For what's left to be done, well, MUUUUUUCH
        => starting with, noting here some of the ideas I quickly scribbled on paper ;P
*/

// 0: set interpreter ( to use corresponding dict obj || file )
var interpreter = 'js'

// 0 bis: define a context ( to be used a root object )
var rootCtx = window;;

// 1: fake user input
var input = 'lol je suis un petit chien et interpreter est mon ami , tout comme console et console.log'

// 2: get user input into invisible buffer
var inputBuffer = input

// 3: log stuff out
/*
inputBuffer.split('\r\n').forEach(function(line){
  console.log('line: {' + line + '}')
  line.split(' ').forEach(function(chunk){
    console.log('chunk: [' + chunk + ']')
  })
})
*/

// 4: construct a quick obj that 'll hold the highlight color mapping for native & <interpreter> 'types' & 'words'
// R: for bash stuff quick printing from <type>:<format> to <formatted type>:
//    read -r -d '' myLol <<'EOF' # read the list of stuff, each on its line, with above syntax
//    for elem in $myLol; do echo -e "\e[${elem##*:}m ${elem%:*} --> ${elem##*:} \e[0m"; done
var parsingDict = {
  native: { // bash's
    types: { 
      builtin: '#C27B00', // 38;5;208
      alias: '#C27B00',  // 38;5;208
      function: '#C27B00',  // 38;5;208
      file: '',  //
      fifo: '#C4A000',  // 40;33
      shellscript: '#8AE234',  // 01;32
      executable: '#8AE234',  // 01;32
      text: '#B2B2B2',  // 38;5;249
      image: '#D7005F',  // 38;5;161
      video: '#875FAF',  // 38;5;97
      audio: '#06989A',  // 00;36
      archive: '#EF2929'  // 01;31
    },
    words: {}
  },
  js: {
    typesdef: function(objectName) {
      var object = rootCtx[objectName], getType = {}, theType;
      if( typeof object === 'undefined' ) theType = ''
      if( theType === '' ){
        if( typeof objectName === 'string' ) theType = 'text'; // types: text
        else if ( ! isNaN(objectName) ) theType = 'numeric'; // types: numeric
      } 
      else if ( object && getType.toString.call(object) === '[object Function]' ) theType = 'function'; // types: function
      else if( Object.prototype.toString.call( object ) === '[object Array]' ) theType = 'array'; // types: array
      else if( typeof object === 'string' ) theType = 'string'; // types: string
      else if ( ! isNaN(object) ) theType = 'number'; // types: number
      else if ( object !== null && typeof object === 'object' ) theType = 'object'; // types: object
      return theType
    },    
    types: {
      function: '#8C16E8',
      array: '#C05614',
      string: '#F8990D',
      number: '#E8166F',
      object: '#169FE8',
      // additionals: text, numeric [ & url/path ? ]
      text: '#B2B2B2',
      numeric: '#E8166F'
    },
    words: {
      chien: '#BADA55',
      suis: '#00DBFF'
    }
  },
}

// 5: colorize & format 'words' & then parse the leftovers' types
// in other words, if a chunk is not a word, then check its type to get its color & format ;)
// -> the end approach is building 2 arrays,on of style & the other of chunks, & then using the latter as the former's index 0 item as a string hodling '%c' delimiters for the styles to be applied on the user input
var dataArr = [], stylesArr = [];
inputBuffer.split('\r\n').forEach(function(line){
  console.log('line: {' + line + '}')
  line.split(' ').forEach(function(chunk){
    //console.log('chunk: [' + chunk + ']')

    // ---- do a crude parsing using the parsingDict ----
    // if interpreter is not supported, fallback to native's
    if ( !parsingDict[interpreter] ){
      if( parsingDict.native.words[chunk] ){
        console.log('chunk: [%c' + chunk + '%c]', 'color: ' + parsingDict.native.words[chunk] + ';', 'color: black;' )
        dataArr.push('%c' + chunk + '%c')
        stylesArr.push('color: ' + parsingDict.native.words[chunk] + ';', 'color: black;')
      }
      else if( parsingDict.native.types[chunk] ){
        console.log('chunk: [%c' + chunk + '%c]', 'color: ' + parsingDict.native.types[chunk] + ';', 'color: black;' )
        dataArr.push('%c' + chunk + '%c')
        stylesArr.push('color: ' + parsingDict.native.types[chunk] + ';', 'color: black;')
      }
      else {
        console.log('chunk: [' + chunk + ']')
        dataArr.push(chunk)
      }
    } else {
      if( parsingDict[interpreter].words[chunk] ){
        console.log('chunk: [%c' + chunk + '%c]', 'color: ' + parsingDict[interpreter].words[chunk] + ';', 'color: black;' )
        dataArr.push('%c' + chunk + '%c')
        stylesArr.push('color: ' + parsingDict[interpreter].words[chunk] + ';', 'color: black;')
      }
      // check if the <interpreter>'s typesdef fcn returns stg, in which case we use the returned value to get the correct color & format
      else if( parsingDict[interpreter].typesdef(chunk) ){
        console.log('chunk: [%c' + chunk + '%c]', 'color: ' + parsingDict[interpreter].types[ parsingDict[interpreter].typesdef(chunk) ] + ';', 'color: black;' )
        dataArr.push('%c' + chunk + '%c')
        stylesArr.push('color: ' + parsingDict[interpreter].types[ parsingDict[interpreter].typesdef(chunk) ] + ';', 'color: black;')
      }
      else {
        console.log('chunk: [' + chunk + ']')
        dataArr.push(chunk)
      }
      console.log('DEBUG: chunk type ' + parsingDict[interpreter].typesdef(chunk) )
    }

  })
})

// 6: pack the data & the styles ( colors & format ) & use that as visible user input buffer / check how it looks like before & after rendering ..
var styledInput = stylesArr;
styledInput.unshift( dataArr.join(' ') )
console.log('DEBUG styled input: ' + styledInput ) // before rendering
console.log.apply(console, styledInput ) // after rendering
