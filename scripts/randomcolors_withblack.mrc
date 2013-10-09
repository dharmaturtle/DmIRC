; Array courtesy of BillGreen!
on *:start: {
  if ( %DharmaOptions.removelinecolors == 1 ) {
    unload -rs remove_line_colors.mrc
    load -rs scripts\remove_line_colors.mrc
  }
  unload -rs linkprocessing.mrc
  load -rs scripts\linkprocessing.mrc
  hmake array 14
  hadd -m array 1 1
  hadd -m array 2 2
  hadd -m array 3 3
  hadd -m array 4 6
  hadd -m array 5 7
  hadd -m array 6 8
  hadd -m array 7 9
  hadd -m array 8 10
  hadd -m array 9 11
  hadd -m array 10 12
  hadd -m array 11 13
  hadd -m array 12 14
  hadd -m array 13 15
}

on ^*:TEXT:*:#: {
  if (!$cnick($nick)) {
    var %random = $rand(1,13)
    cnick -m0 $wildsite $hget(array,%random)
  }
}

on *:EXIT: {
  ; clear the used memory
  hfree array
}

on *:UNLOAD: {
  hfree array
}