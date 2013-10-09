alias urlreg return /(\x03\d{1,2}(?:,\d{1,2})?|)(.*?)(((?:(?:https?://)|(?:www\.))(?!\.)\S+\.(?!\.)\S+)|(?:\S+\.(?:com|org|edu|gov|net|tv|uk|cc|xxx|mil|co|us|se|fm|me|de|kr|sv|fr|jp|tk|be|ly|info|biz|us|in|mobi)(?![a-zA-Z])\S*))/ig
on ^*:TEXT:*:*:{
  if ($regex($1-, $urlreg ) = 0 ) && ($network == own3Dch.at) {
    var %message = $regsubex($1-, ^.., )
    var %nick = $iif($chan, $nick($chan, $nick).pnick, $nick)
    %nick = $regsubex( %nick, &@ , & )
    %nick = $regsubex( %nick, ~@ , ~ )
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
    echo -tcrl normal $iif($chan, $v1, $nick) %message
    haltdef
  }
}