; Dharma wrote this! For once.

alias options {
  set %DharmaOptions.list There are $cnick(0) nicks in the list. Reset as necessary.
  $dialog(DharmaOptions,DharmaOptions)
}

menu channel {
  Options:/Options
  Live status:/live
  Now playing:/nowplaying
  Moo happily!:/describe # moos happily! Moo!
}

dialog DharmaOptions {
  title "Options"
  size -1 -1 360 710
  option pixels
  box "Give random colors to...", 1, 5 172 350 172
  radio "Everyone", 2, 15 192 80 15, group
  radio "Voices", 3, 159 192 80 15
  radio "No one", 4, 286 192 56 15
  check "Permit black as a possible random color", 5, 15 216 250 15
  check "Play a sound when BillBot says {live}", 6, 15 396 250 15
  check "Auto describe YouTube links", 9, 15 421 250 15
  check "1-click image links", 11, 15 509 200 15
  text "Image links (i.e. ending in .jpg) will be opened in mIRC with 1 click.", 12, 33 523 350 16
  text "NEEDS ADDITIONAL SETUP!!! Right click a blank area in a channel,", 13, 33 538 350 16
  text "then select Image Preview > Settings > Enable Image Preview", 14, 33 553 350 16
  button "Close", 16, 155 675 50 28, ok
  button "Delete all nick colors and restore mod colors", 15, 70 260 230 25
  box "Reset nick colors", 17, 21 238 320 90
  text "Double click the preview to close.", 8, 33 568 200 16
  combo 19, 33 584 120 150, size drop
  text "Colorize links that can be 1-clicked.", 22, 163 585 186 16
  edit %qnick, 23, 65 14 100 21, autohs %qnick
  text "Username", 24, 15 16 50 16
  text "Password", 25, 196 16 47 16
  edit %qpass, 26, 245 14 100 21, pass autohs %qpass
  check "Uploader", 29, 36 434 142 20
  check "Rating", 30, 36 450 100 20
  check "Duration", 31, 36 466 100 20
  check "Preview image", 32, 36 482 308 20
  check "Convert https:// to http:// for Facebook and other images.", 20, 33 607 308 20
  check "Append extensions to imgur.com links.", 33, 33 625 300 20
  check "Append extensions to quickmeme.com links.", 34, 33 643 306 20
  text "Over 9000 nicks in the list may cause mIRC to lag. (Really.)", 18, 35 290 300 16
  text %DharmaOptions.list , 21, 35 305 300 16
  check "Remove line colors", 36, 15 88 306 20
  button "Refresh IP/Reconnect/Register nick", 37, 90 128 190 25
  text "Own3d chat servers may change IPs; refresh if you can't connect.", 38, 15 109 350 16
  box "Other", 7, 5 352 350 318
  box "Rizon", 10, 5 1 350 41
  text "Username", 27, 15 67 50 16
  edit %onick, 28, 65 65 100 21, autohs %onick
  edit %opass, 35, 245 65 100 21, pass autohs %opass
  text "Password", 40, 196 67 47 16
  check "Use dark colors", 43, 15 373 250 15
  box "Own3d", 42, 5 52 350 111
}

On *:DIALOG:DharmaOptions:init:0:{
  did -c DharmaOptions %DharmaOptions.color
  if ($did(DharmaOptions,2).state != 1) {
    did -b DharmaOptions 5
  }
  if (%DharmaOptions.black == 1) { did -c DharmaOptions 5 }
  if (%DharmaOptions.live == 1) { did -c DharmaOptions 6 }
  if (%DharmaOptions.youtube.uploader == 1) { did -c DharmaOptions 29 }
  if (%DharmaOptions.youtube.rating == 1) { did -c DharmaOptions 30 }
  if (%DharmaOptions.youtube.duration == 1) { did -c DharmaOptions 31 }
  if (%DharmaOptions.youtube.preview == 1) { did -c DharmaOptions 32 }
  if (%DharmaOptions.youtube == 1) { did -c DharmaOptions 9 }
  else {
    did -ub DharmaOptions 29
    did -ub DharmaOptions 30
    did -ub DharmaOptions 31
    did -ub DharmaOptions 32
  }
  if (%DharmaOptions.images == 1) { did -c DharmaOptions 11 }
  else {
    did -ub DharmaOptions 20
    did -ub DharmaOptions 33
    did -ub DharmaOptions 34
    did -ub DharmaOptions 19
  }
  if (%DharmaOptions.https == 1) { did -c DharmaOptions 20 }
  if (%DharmaOptions.imgur == 1) { did -c DharmaOptions 33 }
  if (%DharmaOptions.quickmeme == 1) { did -c DharmaOptions 34 }
  if (%DharmaOptions.darkcolors == 1) { did -c DharmaOptions 43 }
  
  if (%DharmaOptions.removelinecolors == 1) { did -c DharmaOptions 36 }

  if %DharmaOptions.OneClickColor == 0 { did -ac DharmaOptions 19 0 - White } | else { did -a DharmaOptions 19 0 - White }
  if %DharmaOptions.OneClickColor == 1 { did -ac DharmaOptions 19 1 - Black } | else { did -a DharmaOptions 19 1 - Black }
  if %DharmaOptions.OneClickColor == 2 { did -ac DharmaOptions 19 2 - Blue } | else { did -a DharmaOptions 19 2 - Blue }
  if %DharmaOptions.OneClickColor == 3 { did -ac DharmaOptions 19 3 - Green } | else { did -a DharmaOptions 19 3 - Green }
  if %DharmaOptions.OneClickColor == 4 { did -ac DharmaOptions 19 4 - Red } | else { did -a DharmaOptions 19 4 - Red }
  if %DharmaOptions.OneClickColor == 5 { did -ac DharmaOptions 19 5 - Maroon } | else { did -a DharmaOptions 19 5 - Maroon }
  if %DharmaOptions.OneClickColor == 6 { did -ac DharmaOptions 19 6 - Purple } | else { did -a DharmaOptions 19 6 - Purple }
  if %DharmaOptions.OneClickColor == 7 { did -ac DharmaOptions 19 7 - Orange } | else { did -a DharmaOptions 19 7 - Orange }
  if %DharmaOptions.OneClickColor == 8 { did -ac DharmaOptions 19 8 - Yellow } | else { did -a DharmaOptions 19 8 - Yellow }
  if %DharmaOptions.OneClickColor == 9 { did -ac DharmaOptions 19 9 - Lime } | else { did -a DharmaOptions 19 9 - Lime }
  if %DharmaOptions.OneClickColor == 10 { did -ac DharmaOptions 19 10 - Teal } | else { did -a DharmaOptions 19 10 - Teal }
  if %DharmaOptions.OneClickColor == 11 { did -ac DharmaOptions 19 11 - Cyan } | else { did -a DharmaOptions 19 11 - Cyan }
  if %DharmaOptions.OneClickColor == 12 { did -ac DharmaOptions 19 12 - Dark Blue } | else { did -a DharmaOptions 19 12 - Dark Blue }
  if %DharmaOptions.OneClickColor == 13 { did -ac DharmaOptions 19 13 - Pink } | else { did -a DharmaOptions 19 13 - Pink }
  if %DharmaOptions.OneClickColor == 14 { did -ac DharmaOptions 19 14 - Grey } | else { did -a DharmaOptions 19 14 - Grey }
  if %DharmaOptions.OneClickColor == 15 { did -ac DharmaOptions 19 15 - Brown } | else { did -a DharmaOptions 19 15 - Brown }
}

On *:DIALOG:DharmaOptions:sclick:19:{
  if $did(DharmaOptions,19).sel == 1 { set %DharmaOptions.OneClickColor 0 }
  elseif $did(DharmaOptions,19).sel == 2 { set %DharmaOptions.OneClickColor 1 }
  elseif $did(DharmaOptions,19).sel == 3 { set %DharmaOptions.OneClickColor 2 }
  elseif $did(DharmaOptions,19).sel == 4 { set %DharmaOptions.OneClickColor 3 }
  elseif $did(DharmaOptions,19).sel == 5 { set %DharmaOptions.OneClickColor 4 }
  elseif $did(DharmaOptions,19).sel == 6 { set %DharmaOptions.OneClickColor 5 }
  elseif $did(DharmaOptions,19).sel == 7 { set %DharmaOptions.OneClickColor 6 }
  elseif $did(DharmaOptions,19).sel == 8 { set %DharmaOptions.OneClickColor 7 }
  elseif $did(DharmaOptions,19).sel == 9 { set %DharmaOptions.OneClickColor 8 }
  elseif $did(DharmaOptions,19).sel == 10 { set %DharmaOptions.OneClickColor 9 }
  elseif $did(DharmaOptions,19).sel == 11 { set %DharmaOptions.OneClickColor 10 }
  elseif $did(DharmaOptions,19).sel == 12 { set %DharmaOptions.OneClickColor 11 }
  elseif $did(DharmaOptions,19).sel == 13 { set %DharmaOptions.OneClickColor 12 }
  elseif $did(DharmaOptions,19).sel == 14 { set %DharmaOptions.OneClickColor 13 }
  elseif $did(DharmaOptions,19).sel == 15 { set %DharmaOptions.OneClickColor 14 }
  elseif $did(DharmaOptions,19).sel == 16 { set %DharmaOptions.OneClickColor 15 }
}

On *:DIALOG:DharmaOptions:sclick:2-5:{
  if ($did(DharmaOptions,2).state == 1) {
    if ($did(DharmaOptions,5).state == 1) {
      if (%DharmaOptions.color == 2) { unload -rs randomcolors.mrc }
      if (%DharmaOptions.color == 3) { unload -rs randomcolors_voiceonly.mrc }
      set %DharmaOptions.black 1
      load -rs scripts\randomcolors_withblack.mrc
    }
    elseif ($did(DharmaOptions,5).state == 0) {
      if (%DharmaOptions.black == 1) { unload -rs randomcolors_withblack.mrc }
      if (%DharmaOptions.color == 3) { unload -rs randomcolors_voiceonly.mrc }
      set %DharmaOptions.black 0
      load -rs scripts\randomcolors.mrc
    }
    set %DharmaOptions.color 2
    did -e DharmaOptions 5
  }
  elseif ($did(DharmaOptions,3).state == 1) {
    if (%DharmaOptions.black == 1) { unload -rs randomcolors_withblack.mrc }
    elseif (%DharmaOptions.color == 2) { unload -rs randomcolors.mrc }
    set %DharmaOptions.color 3
    load -rs scripts\randomcolors_voiceonly.mrc
  }
  else {
    if (%DharmaOptions.black == 1) { unload -rs randomcolors_withblack.mrc }
    elseif (%DharmaOptions.color == 2) { unload -rs randomcolors.mrc }
    elseif (%DharmaOptions.color == 3) { unload -rs randomcolors_voiceonly.mrc }
    set %DharmaOptions.color 4
  }
  if ($did(DharmaOptions,2).state != 1) {
    did -ub DharmaOptions 5
    set %DharmaOptions.black 0
  }
}

On *:DIALOG:DharmaOptions:sclick:6:{
  if ($did(DharmaOptions,6).state == 1) {
    set %DharmaOptions.live 1
    load -rs scripts\live.mrc
  }
  else {
    if (%DharmaOptions.live == 1) { unload -rs live.mrc }
    set %DharmaOptions.live 0
  }
}

On *:DIALOG:DharmaOptions:sclick:9:{
  if ($did(DharmaOptions,9).state == 1) { 
    set %DharmaOptions.youtube 1
    load -rs scripts\youtube.mrc
    did -e DharmaOptions 29
    did -e DharmaOptions 30
    did -e DharmaOptions 31
    did -e DharmaOptions 32
  }
  else {
    if (%DharmaOptions.youtube == 1) { unload -rs youtube.mrc }
    set %DharmaOptions.youtube 0
    set %DharmaOptions.youtube.uploader 0
    set %DharmaOptions.youtube.rating 0
    set %DharmaOptions.youtube.duration 0
    set %DharmaOptions.youtube.preview 0
    did -ub DharmaOptions 29
    did -ub DharmaOptions 30
    did -ub DharmaOptions 31
    did -ub DharmaOptions 32
  }
}

On *:DIALOG:DharmaOptions:sclick:11:{
  if ($did(DharmaOptions,11).state == 1) {
    set %DharmaOptions.images 1
    load -rs scripts\images.mrc
    did -e DharmaOptions 20
    did -e DharmaOptions 33
    did -e DharmaOptions 34
    did -eac DharmaOptions 19 12 - Dark Blue
  }
  else {
    if (%DharmaOptions.images == 1) { unload -rs images.mrc }
    did -ub DharmaOptions 20
    did -ub DharmaOptions 33
    did -ub DharmaOptions 34
    did -ub DharmaOptions 19
    set %DharmaOptions.images 0
    set %DharmaOptions.https 0
    set %DharmaOptions.imgur 0
    set %DharmaOptions.quickmeme 0
    set %DharmaOptions.OneClickColor 12
  }
}

On *:DIALOG:DharmaOptions:sclick:15:{
  $dialog(confirm,confirm)
}

dialog confirm {
  title "Confirm Nick Colors Reset"
  size -1 -1 250 90
  option pixels
  button "Cancel", 1, 100 50 50 30, cancel
  button "Reset the Nick Colors List! Cannot undo!", 2, 10 10 230 30, ok
}

On *:DIALOG:confirm:sclick:2:{
  while ( $cnick(1) != $null ) || ( $cnick(1).modes != $null ) { cnick -r 1 }
  cnick -s0 * 5 &@%
  cnick -s0 *!*@dont.taze.me.bro 4
  cnick -s0 Destiny 4 ~@%+
  echo -a 4 Nick Colors reset.
}

On *:DIALOG:DharmaOptions:sclick:29:{
  if ($did(DharmaOptions,29).state == 1) {
    set %DharmaOptions.youtube.uploader 1
  }
  else {
    set %DharmaOptions.youtube.uploader 0
  }
}

On *:DIALOG:DharmaOptions:sclick:30:{
  if ($did(DharmaOptions,30).state == 1) {
    set %DharmaOptions.youtube.rating 1
  }
  else {
    set %DharmaOptions.youtube.rating 0
  }
}

On *:DIALOG:DharmaOptions:sclick:31:{
  if ($did(DharmaOptions,31).state == 1) {
    set %DharmaOptions.youtube.duration 1
  }
  else {
    set %DharmaOptions.youtube.duration 0
  }
}

On *:DIALOG:DharmaOptions:sclick:32:{
  if ($did(DharmaOptions,32).state == 1) {
    set %DharmaOptions.youtube.preview 1
  }
  else {
    set %DharmaOptions.youtube.preview 0
  }
}

On *:DIALOG:DharmaOptions:sclick:20:{
  if ($did(DharmaOptions,20).state == 1) {
    set %DharmaOptions.https 1
  }
  else {
    set %DharmaOptions.https 0
  }
}

On *:DIALOG:DharmaOptions:sclick:33:{
  if ($did(DharmaOptions,33).state == 1) {
    set %DharmaOptions.imgur 1
  }
  else {
    set %DharmaOptions.imgur 0
  }
}

On *:DIALOG:DharmaOptions:sclick:34:{
  if ($did(DharmaOptions,34).state == 1) {
    set %DharmaOptions.quickmeme 1
  }
  else {
    set %DharmaOptions.quickmeme 0
  }
}

On *:DIALOG:DharmaOptions:sclick:43:{
  if ($did(DharmaOptions,43).state == 1) {
    set %DharmaOptions.darkcolors 1
    color 0 0
    color 1 8355711
    color 2 16728128
    color 3 37632
    color 4 255
    color 5 170
    color 6 16711935
    color 7 32764
    color 8 65535
    color 9 64512
    color 10 11184640
    color 11 16776981
    color 12 16738922
    color 13 16744703
    color 14 4868682
    color 15 24767
  }
  else {
    set %DharmaOptions.darkcolors 0
    color 0 16777215
    color 1 0
    color 2 15335424
    color 3 27136
    color 4 255
    color 5 170
    color 6 10223772
    color 7 32764
    color 8 43690
    color 9 54528
    color 10 6973952
    color 11 14013696
    color 12 16722731
    color 13 16711935
    color 14 5592405
    color 15 16512
  }
}

On *:DIALOG:DharmaOptions:sclick:36:{
  if ($did(DharmaOptions,36).state == 1) {
    set %DharmaOptions.removelinecolors 1
    load -rs scripts\remove_line_colors.mrc
  }
  else {
    set %DharmaOptions.removelinecolors 0
    unload -rs remove_line_colors.mrc
  }
}

On *:DIALOG:DharmaOptions:sclick:37:{
  sockClose own3dserver
  sockOpen own3dserver www.own3d.tv 80
}

ctcp *:version:*:{ .ctcpreply $nick SCRIPTSVERSION DmIRC v5.0 by dharmaturtle.blogspot.com }

on *:SockOpen:own3dserver: {
  sockwrite -nt own3dserver GET /chatcfg/153518 HTTP/1.1
  sockwrite -nt own3dserver Host: http://www.own3d.tv
  sockwrite -nt own3dserver $crlf
} 
on *:SockRead:own3dserver: {
  var %read
  sockRead %read
  if (*<endpoint*>*</endpoint>* iswm %read) {
    set %DharmaOptions.own3d.endpoint $regsubex(%read, .*<endpoint.*>(.*)</endpoint>.*, \1)
  }
  if (*<port*>*</port>* iswm %read) {
    set %DharmaOptions.own3d.port $regsubex(%read, .*<port.*>(.*)</port>.*, \1)
  }
  if (*<channel*>*</channel>* iswm %read) {
    set %DharmaOptions.own3d.channel $regsubex(%read, .*<channel.*>(.*)</channel>.*, $chr(35)\1)
  }
  if (*</chat>* iswm %read) {
    echo -a Own3d Server is now %DharmaOptions.own3d.endpoint connected on port %DharmaOptions.own3d.port
    sockClose own3dserver
    if ( %DharmaOptions.own3d.cid isnum) {
      scid %DharmaOptions.own3d.cid server %DharmaOptions.own3d.endpoint %DharmaOptions.own3d.port %opass -i %onick -j %DharmaOptions.own3d.channel
    }
    else server -m %DharmaOptions.own3d.endpoint %DharmaOptions.own3d.port %opass -i %onick -j %DharmaOptions.own3d.channel

  }
}