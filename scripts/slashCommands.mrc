Alias nowplaying {
  sockClose nowplaying
  sockOpen nowplaying audioscrobbler.com 80
} 
on *:SockOpen:nowplaying: {
  sockwrite -nt nowplaying GET /2.0/?method=user.getrecenttracks&user=StevenBonnellII&api_key=b25b959554ed76058ac220b7b2e0a026 HTTP/2.0
  sockwrite -nt nowplaying Host: audioscrobbler.com
  sockwrite -nt nowplaying $crlf
} 
on *:SockRead:nowplaying: {
  var %read
  sockRead %read
  if (*track nowplaying="true"* iswm %read) {
    set %nowplaying 1
  }
  if (*<artist*>*</artist>* iswm %read) {
    set %artist $regsubex(%read, .*<artist.*>(.*)</artist>.*, \1)
  }
  if (*<name>*</name>* iswm %read) && ( %nowplaying == 1 ) {
    set %title $regsubex(%read, .*<name>(.*)</name>.*, \1)
    echo 6 -a %artist - %title $+( |, $chr(32), $chr(3), 12, $chr(31), www.last.fm/user/StevenBonnellII , $chr(3), $chr(31) )
    sockClose nowplaying
    set %nowplaying 0
  }
  if (*<track>* iswm %read) {
    echo 6 -a Destiny isn't playing a song or it's not scrobbled to LastFM.
    sockClose nowplaying
  }
}

; ----------------

Alias live {
  sockClose live
  sockOpen live api.own3d.tv 80
} 
on *:SockOpen:live: {
  sockwrite -nt live GET /liveCheck.php?live_id=153518 HTTP/1.1
  sockwrite -nt live Host: api.own3d.tv
  sockwrite -nt live $crlf
} 
on *:SockRead:live: {
  var %read
  sockRead %read

  if (*<isLive>true</isLive>* iswm %read) {
    set %live 1
  }

  if (*<liveViewers>*</liveViewers>* iswm %read) {
    set %viewers $regsubex(%read, <liveViewers>([\d]*)</liveViewers>, \1)
  }

  if (*<liveDuration>*</liveDuration>* iswm %read) {
    set %durationraw $regsubex(%read, .*<liveDuration>([\d]*)</liveDuration>.*,\1)
    set %duration $duration( %durationraw , 2 )
  }

  if (*</liveEvent>* iswm %read) {
    if ( %live == 1 ) {
      if ( %durationraw < 300) {
        echo 9 -a Destiny has been live for %duration with %viewers viewers.
      }
      else {
        sockClose teamliquid
        sockOpen teamliquid www.teamliquid.net 80
      }
      set %live 0
      sockClose live
    }
    else {
      echo 4 -a Stream is offline.
      sockClose live
    }
  }
}

on *:SockOpen:teamliquid: {
  sockwrite -nt teamliquid GET /video/streams/?xml=1&filter=live HTTP/1.0
  sockwrite -nt teamliquid Host: www.teamliquid.net
  sockwrite -nt teamliquid Accept-Encoding: gzip
  sockwrite -nt teamliquid User-Agent: mIRC scripts by dharmaturtle (skype ID)
  sockwrite -nt teamliquid $crlf
} 
on *:SockRead:teamliquid: {
  var %read
  sockRead %read
  if (*owner="Destiny"* iswm %read) {
    echo 9 -a Destiny has been live for %duration with %viewers viewers and is listed on TL as playing $regsubex(%read, .*type="(.*?)".*, \1)
    sockClose teamliquid
  }
}
