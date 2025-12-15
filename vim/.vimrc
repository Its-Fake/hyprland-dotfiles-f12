" Erzwinge Cursor-Formen in Kitty
if &term =~ '^xterm' || &term =~ '^kitty'
    let &t_SI = "\<Esc>[6 q"  " Insert: Beam (Strich)
    let &t_SR = "\<Esc>[4 q"  " Replace: Unterstrich
    let &t_EI = "\<Esc>[2 q"  " Normal: Block
endif

" Fallback: Setze den Cursor beim Starten und Beenden zurück
autocmd VimEnter * silent !echo -ne "\033[2 q"
autocmd VimLeave * silent !echo -ne "\033[6 q"

