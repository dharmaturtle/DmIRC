; Thanks to FiberOptics for this nifty snippet ;)
alias download {
  var %r = $(|,) return $false, %e = scon -r !echo $color(info) -a $!!download: Error -
  if (!$isid) %e this snippet can only be called as an identifier. %r
  if ($os isin 9598) %e this snippet requires Windows ME or higher. %r
  if ($version < 6) %e this snippet requires mIRC version 6.0 or higher. %r
  var %dir = $nofile($1), %file = $nopath($1), %method = $upper($2), %url = $3
  if (!$gettok(%dir,2,58)) { %dir = $mircdir $+ %dir }
  var %bit = $4, %headers = $iif($2 == get,$5,$6), %postdata = " $+ $5", %res
  if (* !iswm %file) %e you must specify a file to save the data to. %r
  if (%file != $mkfn(%file)) %e file %file contains illegal characters. %r 
  if (* !iswm %dir) %dir = $mircdir
  elseif (!$isdir(%dir)) %e no such folder %dir %r
  if (!$istok(get head post,$2,32)) %e method can only be GET, HEAD or POST. %r
  ;if (!$regex(%e,$3,/^\S+\.\S+\.\S+$/)) %e you didn't specify an url to download from. %r
  if ($2 != head) {
    if ($4 !isnum 1-3) %e bitmask should be a digit in range 1-3. %r 
    if ($2 == post) && (* !iswm $5) %e you didn't specify any post data. %r
    if (%headers) && (!$regsub(%e,%headers,/(\S+?): (.+?)(?=\s?\n|$)/g,"\1" $chr(44) "\2",%headers)) {
      %e bad header syntax. Correct -> Label: value seperated by $!!lf's %r
    }
  }
  var %file = $+(",%dir,%file,"), %id = $+(@download,$ticks,$r(1111,9999),.vbs), %a = aline %id
  if (http://* !iswm $3) %url = http:// $+ $3
  .comopen %id wscript.shell 
  if ($comerr) %e could not open Wscript.Shell. %r
  write -c %file
  window -h %id
  %a on error resume next  
  %a sub quit $lf set http = nothing : set ado = nothing : wscript.quit $lf end sub
  %a sub errmsg 
  %a set fso = createobject("scripting.filesystemobject")
  %a set file = fso.createtextfile( %file ,true)
  %a file.write("Err number: " & err.number & " = " & err.description) : file.close
  %a set fso = nothing 
  %a quit
  %a end sub
  %a arr = array("winhttp.winhttprequest.5.1","winhttp.winhttprequest","msxml2.serverxmlhttp","microsoft.xmlhttp")
  %a i = 0 $lf while i < 4 and not isobject(http) : set http = createobject(arr(i)) : i = i + 1 : wend 
  %a if not isobject(http) then errmsg
  %a err.clear
  %a http.open $+(",%method,") , $+(",%url,") ,false
  %a http.setrequestheader "User-Agent","Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)"
  if (%headers) { tokenize 10 %headers | scon -r %a http.setrequestheader $* }
  if (%method == post) {
    %a http.setrequestheader "Content-Type","application/x-www-form-urlencoded" 
    %a http.send %postdata
  }
  else %a http.send
  %a if err then errmsg
  %a set ado = createobject("adodb.stream") 
  %a if not isobject(ado) then errmsg
  %a ado.open
  if (%bit != 2) {
    %a ado.type = 2 : ado.charset = "ascii" 
    %a ado.writetext "HTTP/1.1 " & http.status & " " & http.statustext,1
    %a ado.writetext http.getallresponseheaders,1 : ado.position = 0 
  }
  if (%bit != 1) %a ado.type = 1 : ado.read : ado.write http.responsebody 
  %a ado.savetofile $iif($mid(%file,3,1) != :,$qt($mircdir $+ $remove(%file,")),%file) ,2 : ado.close : quit
  savebuf %id $qt($mircdir $+ %id)
  close -@ %id
  .comclose %id $com(%id,run,1,bstr*,wscript.exe $qt($mircdir $+ %id),uint,0,bool,true)
  .timer 1 300 .remove %id
  ; * This fixes one Line HTML Files with more than 4000 chars per line * (for example winamp shoutcast servers)
  .fopen file %file 
  .fseek -w file Err number:* = *
  var %pos = $fopen(file).pos
  .fclose file
  if (!%pos) {
    %res = $read(%file,t,1) 
    if (Err number:*=* iswm %res) || (!$file(%file)) %e $iif(%res,%res,no data could be retrieved) - %url %r
  }
  else {
    return $true
  }
  :error
  if ($com(%id)) .comclose %id
  if ($isfile(%id)) .timer 1 300 .remove %id
  if ($window(%id)) close -@ %id
  return $false
}

; Allows clicking on an Image to preview it.
on ^*:hotlink:*:*:{
  if (%imagePreview == $true) {
    if ($regex($1,/^(http:\x2F\x2F)?(?(1)(?:www\.)?|www\.).+?\x2F(?:.+\x2F)?.+\.(?:jp(?:e)?g|gif|png|bmp)$/i)) {
      if ($mouse.key = 1) {
        ; The timer is here to allow the clicking on multiple pics at once
        if (!%downloading [ $+ [ $1 ] ]) { !.timer 1 0 GetAndDrawPreview $1 }
        else { echo $color(info) -ag * $1 is loading, please wait. }
      }
      elseif (%imageHoverEffect) {
        !.timer -m 1 $iif(%imageHoverTime,$ifmatch,400) ImageHoverEffect $1 $mouse.dx $mouse.dy
      }
    }
    halt
  }
  else { halt }
}
on *:start:{
  unset %downloading*
}
alias ImageHoverEffect {
  if ($mouse.dx == $2 && $mouse.dy == $3) {
    if (!%downloading [ $+ [ $1 ] ]) { !.timer 1 0 GetAndDrawPreview $1 }
    else { echo $color(info) -ag * $1 is loading, please wait. }
  }
}
alias GetAndDrawPreview {
  if (!$isalias(download)) { echo $color(info) -ag * $!download alias is required. | !return }
  !set %downloading [ $+ [ $1 ] ] $true
  !var %fname = imgcache\ $+ $mkfn($1)
  !var %% = $false,%image = $false,%404 = $false
  if (!$exists(%fname)) {
    if ($download(%fname,HEAD,$1,1)) {
      if ($read(%fname,nw,Content-Type: image/*)) { %image = $true }
      %% = $true
      if (%image && %imageInformFileSize && $read(%fname,nw,Content-Length: *))  { !var %fz = $gettok($ifmatch,2,32) | if (%fz > 1048576) { %% = $input(Image File is larger than 1MB. $crlf $+ Imagesize: $bytes(%fz).suf $crlf $+ Do you still wanna download it?,ywd,Large file) } }
      elseif (%image && %imageInformUnknownFileSize && !$read(%fname,nw,Content-Length: *)) { %% = $input(Size is unknown. Continue?,ywd,Unknown filesize) }
      if ($read(%fname,wn,HTTP/1.1 404*)) { %404 = $true }
      !.remove %fname
    }
  }
  else { !var %% = $true,%image = $true }
  if (%% &&  %image && !%404) {
    !var %mpos = $mouse.dx $mouse.dy
    if (!$exists(%fname)) {
      if (!$isdir(imgcache)) { !mkdir imgcache }
      if ($download(%fname,GET,$1,2)) { !var %downloaded = $true }
      else { !var %downloaded = $false | !goto error }
    }
    else { var %downloaded = $true }
    if ($lof(%fname) == 0) {
      !.remove %fname
      !.timer -m 1 0 noop $!input( $+ $1 is not an Image. $crlf $crlf $+ (error while downloading/0B file),owd,Invalid File)
      !goto end
    }
    !unset %downloading [ $+ [ $1 ] ]
  }
  if (%downloaded) {
    !var %@ = @ImagePreview: $+ $nopath($1)
    if ($window(%@)) !window -c %@
    if ($pic(%fname).width && $pic(%fname).height && $pic(%fname).size) {
      !var %w = $pic(%fname).width
      !var %h = $pic(%fname).height
      ; Aspect Size if the pic is to large
      !var %a = %w / %h
      if (%h > $calc($window(-1).h - 150)) { %h = $window(-1).h - 150 | %w = %h * %a } 
      if (%w > $calc($window(-1).w - 150)) { %w = $window(-1).w - 150 | %h = %w / %a }
      if ($len(%imageMaxHeight)) { if (%h > %imageMaxHeight) { %h = %imageMaxHeight | %w = %h * %a } }
      if ($len(%imageMaxWidth)) { if (%w > %imageMaxWidth) { %w =  %imageMaxWidth | %h = %w / %a } }
      ; Show me the picture :)
      if (%imageMethod) {
        !window -Bhdk0 $+ $iif(%imageOnTop,o) %@ $iif(%imageMousePos,%mpos,-1 -1) $int(%w) $int(%h)
        !background -r %@ %fname
      }
      else {
        !window -Bhpdk0 $+ $iif(%imageOnTop,o) +d %@ $iif(%imageMousePos,%mpos,-1 -1) $int(%w) $int(%h)
        !drawpic -ms %@ 0 0 $int(%w) $int(%h) %fname
      }
      !renwin %@ %@ - $1
      !window -ak0w0 %@
      if (%imageRemCache) { !.remove %fname }
    }
    else {
      if (%imageOnFailLoad) { !.url -n $1 }
      if (%imageOnFailInform == 1) { !.timer -m 1 0 noop $!input( $+ $1 is not an Image.,owd,Invalid File) }
      elseif (%imageOnFailInform == 2) { !.timer -m 1 0 echo $color(info) -ag * $1 is not an Image. }
      elseif (%imageOnFailInform == 3) { !beep }
      !.remove %fname
    }
  }
  !goto end
  :error
  if ($gettok($error,1,58) == * drawpic) {
    if ($window(%@)) { !window -c %@ }
    ; Show me the picture cuz it should be possible with /background
    !window -Bhdk0 $+ $iif(%imageOnTop,o) %@ $iif(%imageMousePos,%mpos,-1 -1) $int(%w) $int(%h)
    !background -r %@ %fname
    !renwin %@ %@ - $1
    if (%imageOnFailInform == 1) { !.timer -m 1 0 noop $!input(An Error occured while drawing the picture $!+ $!chr(44) using alternative method to display it.,owd,Display Error) }
    elseif (%imageOnFailInform == 2) { !echo $color(info) -ag * An Error occured while drawing the picture, using alternative method to display it. }
    elseif (%imageOnFailInform == 3) { !beep }
    !window -ak0w0 %@
    if (%imageRemCache) { !.remove %fname }
  }
  else {
    if ($window(%@)) { !window -c %@ }
    if ($isfile(%fname)) { !.remove %fname }
    !unset %downloading [ $+ [ $1 ] ]
    var %e = Error while loading the image: $crlf $+ $1 $&
      $iif($error,$str($crlf,2) $+ Errormessage: $remove($gettok($gettok($error,1,40),2-,32),$mircdir)) $&
      $iif(%imageOnFailLoad && !%404,$crlf $crlf $+ Opening in Browser.,$iif(%404,$crlf $crlf $+ Server returned 404 file not found.))
    if (%imageOnFailInform == 1) { !.timer -m 1 0 noop $!input( %e ,owd,Invalid File) }
    elseif (%imageOnFailInform == 2) { !echo $color(info) -ag * $replace(%e,$crlf,$chr(32)) }
    elseif (%imageOnFailInform == 3) { !beep }
    if (%imageOnFailLoad) { !.url -n $1 }
  }
  !reseterror
  :end
  if (!%downloaded) {
    if ($isfile(%fname)) { !.remove %fname }
    !.unset %downloading [ $+ [ $1 ] ]
    !var %message = $1 not downloaded. $& 
      $iif(!%image,File is no picture.,$iif(!%%,To large for you eh?)) $& 
      $iif(%imageOnFailLoad && !%404 && %%,$crlf $crlf $+ Opening in Browser.,$iif(%404,$crlf $crlf $+ Server returned 404 file not found.))
    if (%imageOnFailInform == 1) { !.timer -m 1 0 noop $!input(%message,owd,Not loaded) }
    elseif (%imageOnFailInform == 2) { !echo $color(info) -ag * $replace(%message,$crlf,$chr(32)) }
    elseif (%imageOnFailInform == 3) { !beep }
    if (%imageOnFailLoad) && (%%) && (!%404) { !.url -n $1 }
  }
}
menu @ImagePreview:* {
  sclick:!set %imageMove $mouse.x $mouse.y
  uclick:!unset %imageMove
  mouse:{
    if (%imageMove && $mouse.key & 1) {
      !window $active $&
        $calc($mouse.dx - $gettok(%imageMove,1,32)) $&
        $calc($mouse.dy - $gettok(%imageMove,2,32)) $& 
        $window($active).w $window($active).h
    }
  }
  dclick:!background -x $active | !goto end | :error | !reseterror | :end | !window -c $active | cleanmircini
  $iif(!$isfile(imgcache\ $+ $mkfn($right($window($active).title,-2))),$style(2)) &Picture Information
  .Width $chr(9) $pic(imgcache\ $+ $mkfn($right($window($active).title,-2))).width $+ px : $null
  .Height $chr(9) $pic(imgcache\ $+ $mkfn($right($window($active).title,-2))).height $+ px: $null
  .Size $chr(9) $bytes($pic(imgcache\ $+ $mkfn($right($window($active).title,-2))).size).suf : $null
  .-
  .Filename $chr(9) $nopath($right($window($active).title,-2)) : $null
  .Got it from $chr(9) $nofile($right($window($active).title,-2)) : $null
  -
  $iif(!$isfile(imgcache\ $+ $mkfn($right($window($active).title,-2))),$style(2)) &Open with Paint: !run mspaint imgcache\ $+ $mkfn($right($window($active).title,-2)) | !goto end | :error | !noop $input(MSPaint not installed? Buayaka!.,owd,Error while Opening.) | !reseterror | :end
  $iif(!$isfile(imgcache\ $+ $mkfn($right($window($active).title,-2))),$style(2)) Op&en associated Programm: !run imgcache\ $+ $mkfn($right($window($active).title,-2)) | !goto end | :error | !noop $input(No Programm found.,owd,Error while Opening.) | !reseterror | :end
  Ope&n Picture in default browser:!url -n $right($window($active).title,-2)
  Cop&y Picture-URL to clipboard:!clipboard $right($window($active).title,-2)
  -
  $iif(!$isfile(imgcache\ $+ $mkfn($right($window($active).title,-2))),$style(2)) &Remove file from Cache:!.remove imgcache\ $+ $mkfn($right($window($active).title,-2))
  &Close: !background -x $active | !goto end | :error | !reseterror | :end | !window -c $active | cleanmircini
  -
}
on *:close:@ImagePreview*:{
  !background -x $active | !goto end | :error | !reseterror | :end | cleanmircini
}
; removes the backgroundentrys from the mirc.ini created by the imagepreview resize option
alias -l cleanMircIni {
  !var %x = $ini($shortfn($mircini),background,0),%s
  while (%x) {
    %s = $ini($shortfn($mircini),background,%x)
    if (@ImagePreview:* iswm %s) { !.remini $shortfn($mircini) background %s }
    !dec %x
  }
  !unset %imageMove
}
menu channel,query,@ImagePreview:* {
  &ImagePreview 
  .&Settings
  ..$iif(%imagePreview,$style(1)) &Enable ImagePreview: switchSet Preview
  ..$iif(%imageRemCache,$style(1)) &Remove file after loading: switchSet RemCache
  ..$iif(%imageMethod,$style(1)) Re&sizable: switchSet Method
  ..$iif(%imageMousePos,$style(1)) O&pen at Mouseposition: switchSet MousePos
  ..$iif(%imageOnTop,$style(1)) &Always on Top: switchSet OnTop
  ..$iif(%imageShowCacheDir,$style(1)) Show ca&ched files: switchSet ShowCacheDir
  ..$iif(%imageCacheInfo,$style(1)) Show cache i&nfo:switchSet CacheInfo
  ..-
  ..On &fail inform me ( $+ $iif(%imageOnFailInform,$gettok(Dialog BoxEchoBeep,%imageOnFailInform,1),Off) $+ )
  ...$iif(%imageOnFailInform == 1,$style(1)) &Dialog Box: !set %imageOnFailInform 1
  ...$iif(%imageOnFailInform == 2,$style(1)) &Echo: !set %imageOnFailInform 2
  ...$iif(%imageOnFailInform == 3,$style(1)) &Beep: !set %imageOnFailInform 3
  ...$iif(%imageOnFailInform == $null,$style(1)) &Off: !unset %imageOnFailInform
  ..$iif(%imageOnFailLoad,$style(1)) On fa&il load in browser: switchSet OnFailLoad
  ..$iif(%imageInformFileSize,$style(1)) Inform me if Image is larger than &1MB:switchSet InformFileSize
  ..$iif(%imageInformUnknownFileSize,$style(1)) Inform &me on unknown Filesize:switchSet InformUnknownFileSize
  ..-
  ..$iif(%imageHoverEffect,$style(1)) Open a&utomatical after $iif(%imageHoverTime,$ifmatch,400) $+ ms hovering:switchSet HoverEffect
  ..$iif($len(%imageHoverTime),$style(1)) Set H&over Time:if ($?="Hover time till the picture will load automatical $crlf $+ (time in milliseconds):" isnum && $! > 0) { set %imageHoverTime $! } | else { unset %imageHoverTime }
  ..-
  ..$iif($len(%imageMaxHeight),$style(1)) Max &Height $iif($len(%imageMaxHeight),( $+ %imageMaxHeight $+ )):if ($?="Maximum height for the images: $crlf $crlf $+ (Keep it empty to remove the limitation)" isnum && $! > 0) { set %imageMaxHeight $! } | else { unset %imageMaxHeight }
  ..$iif($len(%imageMaxWidth),$style(1)) Max &Width $iif($len(%imageMaxWidth),( $+ %imageMaxWidth $+ )):if ($?="Maximum width for the images:  $crlf $crlf $+ (Keep it empty to remove the limitation)" isnum && $! > 0) { set %imageMaxWidth $! } | else { unset %imageMaxWidth }
  .-
  .&Open Cache:!run imgcache\
  .&Clear Cache $iif(%imageCacheInfo,$iif($findfile(.,*,1,!set %ipx 0),) ( $+ $findfile(imgcache\,*,0,!inc %ipx $lof($1-)).shortfn files, $bytes(%ipx).suf $+ )):echo $color(info) -ag * $findfile(imgcache\,*,0,!.remove $1-).shortfn file(s) removed from cachedir.
  .$iif(%imageShowCacheDir,-)
  .$iif(%imageShowCacheDir,C&ached Files)
  ..$submenu($_icf($1).h)
  ..$submenu($_icf($1).c)
  .$iif(%imageShowCacheDir,&Remove File)
  ..$submenu($_icf($1).r)
  ..$_icf
}
alias -l _icf {
  if (%imageShowCacheDir) {
    if ($1 isnum) {
      if ($prop == h) { if ($findfile(imgcache\,*,$1).shortfn) { !hadd -m icf i $+ $1 $ifmatch | !var %f = $ifmatch | !return $null : $null } }
      elseif ($prop == c) { !var %f = $hget(icf,i $+ $1) | !return $iif(%f,Open $chr(35) $+ $1 $chr(9) $gettok($longfn(%f),-1,95)) : !run %f }
      elseif ($prop == r) { !var %f = $hget(icf,i $+ $1) | !return $iif(%f,Remove $chr(35) $+ $1 $chr(9) $gettok($longfn(%f),-1,95)) : !.remove %f }
    }
    else { if ($hget(icf,0).item) { !.timerclearpics 1 1 !hfree icf } }
  }
}
alias switchSet { 
  if (!%image [ $+ [ $1 ] ]) { set %image [ $+ [ $1 ] ] $true }
  else { set %image [ $+ [ $1 ] ] $false }
}
alias imglist {
  if ($isid) {
    if ($window(@imglist)) {
      var %h = $gettok($strip($sline(@imglist,1)),1,9)
      if ($1 == begin) { return - }
      if ($1 isnum) && ($findfile(imgcache,* [ $+ [ %h ] $+ ] *,$1)) { 
        var %f = $v1
        return $gettok($nopath(%f),3-,95) : run %f
      }
      if ($1 == end) { return More...:run imgcache }
    }
  }
  elseif ($1 == -r) {
    if ($window(@imglist)) {
      var %h = $gettok($strip($sline(@imglist,1)),1,9)
      var %x = $findfile(imgcache,* $+ %h $+ *,0,if ($gettok($nopath($longfn($1-)),2,95) == %h) !.remove $1- ).shortfn
      !.timer 1 0 imglist
    }
  }
  else {
    var %x = $findfile(imgcache,*,0,inc %imghost $+ $gettok($1-,2,95))
    %x = $var(%imghost*,0)
    if ($window(@imglist)) { window -c @imglist }
    window -elk0z -t70,9999 @imglist
    aline @imglist 00,01Host $+ $chr(9) $+ Files
    aline @imglist 00,01 $+ $str(-,70) $+ $chr(9) $+ $str(-,100)
    %y = 0
    while (%y < %x) {
      inc %y
      if (2 // %y) {
        aline @imglist 00,01 $+ $remove($var(%imghost*,%y),$(%imghost,0)) $+ $chr(9) $+ $var(%imghost*,%y).value
      }
      else {
        aline @imglist 00,02 $+ $remove($var(%imghost*,%y),$(%imghost,0)) $+ $chr(9) $+ $var(%imghost*,%y).value
      }
    }
    unset %imghost*
  }
}
menu @imglist {
  $iif($sline(@imglist,1).ln > 2,Files)
  .$submenu($imglist($1))
  $iif($sline(@imglist,1).ln > 2,Remove all Files from $gettok($strip($sline(@imglist,1)),1,9)):imglist -r $gettok($strip($sline(@imglist,1)),1,9)
}