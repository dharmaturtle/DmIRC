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

; Requires the $download snippet can be found here: http://sephiroth.bounceme.net/forum/viewtopic.php?t=104
; No need to change anything normally
; Simply paste it to remote and you will get an echo after someone pasted a youtube uri
; if you wanna use it for a bot change the post alias to return $true
;
; Update: 21.01.2012
;  - added some errorchecking
;  - changed Wildmatch
;  - better parsing
;  - added youtu.be-links
alias -l post { return $false }
on *:text:*youtube*v=*:*: {
  var %url = $wildtok($1-,*youtube.com/*v=*, 1, 32)
  if ($youtube(%url)) {
    tokenize 9 $ifmatch
    ; Author -> $1
    ; Duration -> $2
    ; Rating -> $3
    ; Date (last updated OR published) -> $4
    ; Preview Picture -> $5
    ; Title -> $6
    echo $iif($chan,$chan,$nick) Y0,4T $+($6,$1,$3,$2,$5))
  }
}
on *:text:*youtu.be*:*:{
  var %url = $wildtok($1-,http://youtu.be/*, 1, 32)
  if ($len(%url)) {
    %url = /?v= $+ $gettok(%url,3,47)
    if ($youtube(%url)) {
      tokenize 9 $ifmatch
      echo $iif($chan,$chan,$nick) Y0,4T $+($6,$1,$3,$2,$5))
    }
  }
}
alias youtube {
  ; http://www.youtube.com/watch?v=B0fFDk2M0zE&feature=fvhl#cookie
  ; example: $youtube(...youtube.com/watch?v=vid)
  var %x = $gettok($1-,1,35) , %o = $null, %r = $null, %y = 0
  %x = $gettok(%x,2-,63)
  %y = $numtok(%x,38)
  while (%y) {
    %o = $gettok(%x,%y,38)
    if ($gettok(%o,1,61) == v) { %r = $gettok(%o,2,61) }
    dec %y
  }
  if (!$len(%r)) { return $false }
  else { %x = %r }
  %x = $left( %x , 11)
  if ($download(tmpfile,GET,http://gdata.youtube.com/feeds/api/videos/ $+ %x ,2)) {
    bread tmpfile 0 $lof(tmpfile) &bin
    var %string = $b(&bin,<author>)
    if ($regex(%string,/\<author\>\<name\>(.*)\<\/name\>/ig)) { var %author = $+(14,$chr(32),by $regml(1),) }
    var %string = $b(&bin,<yt:duration)
    if ($regex(%string,/\<yt:duration seconds='([\d]+)'\/\>/ig)) { var %duration = $duration($regml(1),3) }
    var %string = $b(&bin,<gd:rating)
    if ($regex(%string,/average='([^']+)' max='([\d]+)'/ig)) { var %rating = $+(8,$chr(32),$round($regml(1),1),★) } 
    var %string = $b(&bin,<title)
    if ($regex(%string,/type='text'>([^<]+)/ig)) { var %title = $regml(1) }
    var %string = $b(&bin,<updated>)
    if ($regex(%string,/\<updated>([\d]{4})-([\d]{2})-([\d]{2})T([\d]{2}:[\d]{2})\:/ig)) { var %date = $regml(3) $+ . $+ $regml(2) $+ . $+ $regml(1) $regml(4) }
    else {
      var %string = $b(&bin,<published>)
      if ($regex(%string,/\<published>([\d]{4})-([\d]{2})-([\d]{2})T([\d]{2}:[\d]{2})\:/ig)) { var %date = $regml(3) $+ . $+ $regml(2) $+ . $+ $regml(1) $regml(4) }
    }
    var %preview = $+($chr(32), $chr(3),%DharmaOptions.OneClickColor,$chr(31) , http://i.ytimg.com/vi/ $+ %x $+ /0.jpg)
    if ($isfile(tmpfile)) { .timer 1 300 !.remove tmpfile }
    if (!$len(%author)) var %author = $+(14by n/a,)
    if (!$len(%duration)) var %duration = 00:00:00
    if ($left(%duration,4) == 00:0) var %duration = $chr(32) $right(%duration,4)
    else if ($left(%duration,2) == 00) var %duration = $chr(32) $right(%duration,5)
    else var %duration = $chr(32) %duration
    if (!$len(%date)) var %date = n/a
    if (!$len(%preview)) var %preview = n/a
    if (!$len(%title)) var %title = n/a
    if (!$len(%rating)) var %rating = $+(8,$chr(2),n/a,★)
    if ( %DharmaOptions.youtube.uploader == 0 ) { var %author = $chr(15) }
    if ( %DharmaOptions.youtube.duration == 0 ) { var %duration = $chr(15) }
    if ( %DharmaOptions.youtube.rating == 0 ) { var %rating = $chr(15) }
    if ( %DharmaOptions.youtube.preview == 0 ) { var %preview = $chr(15) }
    %x = $t( %author , %duration , %rating , %date , %preview , %title)
    ;14by $+($1, 8 $3, ★, ) $2 $+($chr(3), 12, $chr(31), $5)
  }
  else { var %x = $false }
  if ($isfile(tmpfile)) { .timer 1 300 !.remove tmpfile }
  return %x
}
alias -l t { var %x = $0,%o | while (%x) { %o = $ [ $+ [ %x ] ] $+ $chr(9) $+ %o | dec %x } | return %o }
alias -l b { return $bvar($1,$bfind($1,1,$2).text,$iif($version > 6.31,4000,800)).text }