; the horrible dynamic variables were taken from http://forum.swiftirc.net/viewtopic.php?f=34&t=7969&view=next
; Inspired by BillGreen and http://stackoverflow.com/questions/4867035/how-do-i-change-the-color-of-links-in-mirc/6071100#6071100

; Ordinary link coloring
alias urlreg return /(\x03\d{1,2}(?:,\d{1,2})?|)(.*?)(((?:(?:https?://)|(?:www\.))(?!\.)\S+\.(?!\.)\S+)|(?:[^\s ]+\.(?:com|org|edu|gov|net|tv|uk|cc|xxx|mil|co|us|se|fm|me|de|kr|sv|fr|jp|tk|be|ly|info|biz|us|in|mobi)(?![a-zA-Z])\S*))/ig
alias urlcolor return $+($chr(3), 12, $chr(31), $1-, $chr(3), $chr(31))
alias selfurlcolor return $+($chr(3), 12, $chr(31), $1-, $chr(31), $chr(3), $color(own))
alias imgreg return /(\x03\d{1,2}(?:,\d{1,2})?|)(.*?)((?:(?:http://)|(?:(?<!https://)www\.))(?!\.)(?!imageshack)\S+\.(?!\.)\S+\.(jpg|png|jpeg)(?=\x03))/ig
alias imgcolor return $+($chr(3), %DharmaOptions.OneClickColor , $1-)
alias selfimgcolor return $+($chr(3), %DharmaOptions.OneClickColor , $1-, $chr(3), $color(own))
alias imgurreg return /(imgur\.com/)(?:gallery/)?([\w]{5,})(?!,|(\....))/ig
;alias memeReg return /(\x03\d{1,2}(?:,\d{1,2})?|)(.*?)(\S+quickmeme\.com/meme/(\w*)\S+)(\s|$)/ig
alias memeReg return /(\x03\d{1,2}(?:,\d{1,2})?|)(.*?)(\S*quickmeme\.com/meme/(\w*)\S*)/ig
alias memecolor return $+($chr(3), %DharmaOptions.OneClickColor , $chr(31), http://i.qkme.me/, $1-, .jpg, $chr(3), $chr(31))
alias httpsurlreg return /(\x03\d{1,2}(?:,\d{1,2})?|)(.*?)((https://)(\S*(googleusercontent|dropbox|4chan|amazonaws|fbcdn|twimg)\S*\.(?!\.)\S+\.(jpg|png)))/ig
alias httpsurlcolor return $+($chr(3), %DharmaOptions.OneClickColor, http://, $1-, $chr(3))
on ^&$*:text:$($urlreg):*:{
  ; If we are in a channel, turn nick into ~&@%+nick if applicable
  var %nick = $iif($chan, $nick($chan, $nick).pnick, $nick)
  %nick = $regsubex( %nick, &@ , & )
  %nick = $regsubex( %nick, ~@ , ~ )
  var %message = $1-
  if ( %DharmaOptions.removelinecolors == 1 ) && ($network == own3Dch.at) { %message = $regsubex( %message , ^.., ) }
  %message = $regsubex( %message , $urlreg,\1\2$urlcolor(\3)\1)
  if ( $nick isop $chan ) || ( $nick ishop $chan ) {
    var %color = %DharmaOptions.opcolor
    if (destin isin %nick) {
      %color = 4
    }
    if ( $cnick($nick) != 0 ) && ( $cnick($nick) < $cnick( &@% ) ) {
      %color = $cnick($nick).color
    }
  }
  else if ( $cnick($nick) != 0 ) {
    var %color = $cnick($nick).color
  }

  %message = $+(<, $chr(3), %color, %nick, $chr(3), >) %message
  if ( %DharmaOptions.OneClickColor != $null ) { %message = $regsubex(%message, $imgreg,\1\2$imgcolor(\3)\1) }
  if ( %DharmaOptions.quickmeme == 1 ) { %message = $regsubex(%message, $memeReg,\1\2$memecolor(\4)\1) }
  if ( %DharmaOptions.https == 1 ) { %message = $regsubex(%message, $httpsurlreg,\1\2$httpsurlcolor(\5)\1) }
  if ($regex(%message, $imgurreg ) > 0 ) && ( %DharmaOptions.imgur == 1 ) {
    inc %imgurID
    var %n = $regex( %message , $imgurreg )
    set %imgur. [ $+ [ %imgurID ] $+ [ .Count ] ] %n
    set %imgur. [ $+ [ %imgurID ] $+ [ .Nick ] ] $iif($chan, $nick($chan, $nick).pnick, $nick)
    set %imgur. [ $+ [ %imgurID ] $+ [ .Msg ] ] %message
    set %imgur. [ $+ [ %imgurID ] $+ [ .Chan ] ] $chan

    tokenize 3 $regsubex( %message , /(.*?\S+imgur\.com/)(?:gallery/)?([\w]{4,})|(.*)/ig , \2 $chr(3))
    while (%n != 0) {
      set %imgur. [ $+ [ %imgurID ] $+ [ .Url. ] $+ [ %n ] ] [ $eval($($+($,%n)) , 2) ]
      noop $imgur $eval($($+($,%n)) , 2)
      sockopen $+( imgur. [ $+ [ %imgurID ] $+ [ .Url. ] $+ [ %n ] ] ) api.imgur.com 80
      .timer 1 15 .signal -n imgursignal
      dec %n
    }
  }
  ; print the message, default timestamp, highlighting options, and nick coloring
  else { echo -tcrl normal $iif($chan, $v1, $nick) %message }
  haltdef
}

on *:SIGNAL:imgursignal:{
  inc %imgurID.delay
  if ( %imgur. [ $+ [ %imgurID.delay ] $+ [ .count ] ] ==  1 ) {
    echo -tcrl normal $iif( %imgur. [ $+ [ %imgurID.delay ] $+ [ .Chan ] ] , $v1, %imgur. [ $+ [ %imgurID.delay ] $+ [ .Nick ] ] ) %imgur. [ $+ [ %imgurID.delay ] $+ [ .Msg ] ]
    unset [ $+( %, imgur. , %imgurID.delay , * ) ]
    sockclose [ $+( imgur. , %imgurID.delay , * ) ]
  }
}

on &*:INPUT:*:{
  if ($regex($1-,$urlreg) > 0) && ( $left($1-,1) != / ) {
    var %nick = $iif($chan, $nick($chan, $nick).pnick, $nick)
    var %message = $regsubex($1-, $urlreg,\1\2$selfurlcolor(\3)\1)
    if ($regex($1-,$imgreg) > 0) && ( %DharmaOptions.OneClickColor != $null ) { var %message = $regsubex( %message , $imgreg,\1\2$selfimgcolor(\3)\1) }
    var %color = $color(own)
    if ( $nick isop $chan ) || ( $nick ishop $chan ) { %color = %DharmaOptions.opcolor }
    echo -atcr normal $+($chr(3), $color(own) , < , $chr(3), %color , %nick , $chr(3), $color(own) , >) %message
    .msg $iif($chan, $v1, $target) $1-
    haltdef
  }
}

; Begin Imgur link processing
on *:sockopen:imgur.*: {
  sockwrite -nt $sockname GET /2/image/ $+ $eval( $+( %, $sockname) , 2 ) HTTP/1.1
  sockwrite -nt $sockname Host: api.imgur.com
  sockwrite -nt $sockname $crlf
}
on *:sockread:imgur.*: {
  var %read
  sockread %read
  if (*<original>* iswm %read ) {
    var %start = /((http|www)\S*)?imgur\.com/(?:gallery/)?(
    var %mid = %imgur. [ $+ [ $gettok($sockname,2,46) ] $+ [ .Url. ] $+ [ $gettok($sockname,4,46) ] ]
    var %end = [^ \t\r\n\x31\x03]{0,5})/g
    var %tempread = $regsubex(%read , /.*<original>(.*)</original>.*/ig ,\1)
    if (.jpg</original> isin %read ) || (.png</original> isin %read ) { set %imgur. [ $+ [ $gettok($sockname,2,46) ] $+ [ .Msg ] ] $regsubex( %imgur. [ $+ [ $gettok($sockname,2,46) ] $+ [ .Msg ] ] , $+( %start , %mid , %end ) , $+(, %DharmaOptions.OneClickColor,%tempread,)) }
    else set %imgur. [ $+ [ $gettok($sockname,2,46) ] $+ [ .Msg ] ] $regsubex( %imgur. [ $+ [ $gettok($sockname,2,46) ] $+ [ .Msg ] ] , $+( %start , %mid , %end ) , %tempread))
    inc %imgur. [ $+ [ $gettok($sockname,2,46) ] $+ [ .final ] ]
    if ( %imgur. [ $+ [ $gettok($sockname,2,46) ] $+ [ .final ] ] ==  %imgur. [ $+ [ $gettok($sockname,2,46) ] $+ [ .Count ] ] ) {
      ; print the message, default timestamp, highlighting options, and nick coloring
      echo -tcrl normal $iif( %imgur. [ $+ [ %imgurID ] $+ [ .Chan ] ] , $v1, %imgur. [ $+ [ %imgurID ] $+ [ .Nick ] ] ) %imgur. [ $+ [ $gettok($sockname,2,46) ] $+ [ .Msg ] ]
      unset [ $+( %, imgur. , $gettok($sockname,2,46) , * ) ]
    }
    sockclose $sockname
  }
  elseif (*error* iswm %read ) {
    inc %imgur. [ $+ [ $gettok($sockname,2,46) ] $+ [ .final ] ]
    if ( %imgur. [ $+ [ $gettok($sockname,2,46) ] $+ [ .final ] ] ==  %imgur. [ $+ [ $gettok($sockname,2,46) ] $+ [ .Count ] ] ) {
      ; print the message, default timestamp, highlighting options, and nick coloring
      echo -tcrl normal $iif( %imgur. [ $+ [ %imgurID ] $+ [ .Chan ] ] , $v1, %imgur. [ $+ [ %imgurID ] $+ [ .Nick ] ] ) %imgur. [ $+ [ $gettok($sockname,2,46) ] $+ [ .Msg ] ]
      unset [ $+( %, imgur. , $gettok($sockname,2,46) , * ) ]
    }
    sockclose $sockname
  }
}
