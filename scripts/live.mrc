on *:TEXT:*:#: {
  if ($network == rizon) && ( $nick isop $chan ) {
    if %liveBracket isin $1- {
      splay -wq [live].wav
    }
  }
}
