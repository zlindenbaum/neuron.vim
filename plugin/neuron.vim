" =============================================================================
" File:        neuron.vim
" Description: Take zettelkasten notes using neuron in Vim.
" Author:      ihsan <ihsanl at pm dot me>
" Created At:  1590326456
" License:     MIT License
" =============================================================================

let g:zkdir = '${HOME}/zettelkasten/'
let g:zexte = '.md'
let g:fzf_options = '-d"title: " --with-nth 2 --prompt "Zettelkasten: "'

" Prototypes {{{1

" Functions {{{2

" [ ] ZettelSearch -> Opens selected.
" [X] ZettelLastInsert -> Insert last edited.
" [X] ZettelSearchInsert -> Insert selected.
" [X] ZettelNew -> Open & startinsert title.
" [X] ZettelSearchTitles -> Opens selected.
" [X] ZettelOpen(zettelID)
" [X] ZettelOpenUnderCursor

" }}}
" Commands {{{2

" ZettelOpenUnderCursor
" ZettelOpen

" }}}

" }}}
" Functions {{{1

func ExpandZettelID(ZettelID)
	return g:zkdir . a:ZettelID . g:zexte
endf

func ZettelOpen(ZettelID)
	exec 'edit '.ExpandZettelID(a:ZettelID)
endf

func ZettelSearch() "opens the zettel after search.
	call fzf#vim#grep("rg 'title:' --column", 1,
			\ fzf#vim#with_preview({'dir':g:zkdir, 'options': g:fzf_options}))
endf

func ZettelOpenUnderCursor()
	call ZettelOpen(expand('<cword>'))
endf

func ZettelNew() " relying on https://github.com/srid/neuron
	exec 'e '.system('neuron new "PLACEHOLDER"').' |norm jfP"_D'
endf

func Insert(thing)
	put =a:thing
endf

func ShrinkFZF(output)
	call Insert(split(a:output, g:zexte)[0])
endf

func ZettelSearchInsert()
	call fzf#vim#grep("rg 'title:' --column", 1,
			\ fzf#vim#with_preview({
				\ 'dir':g:zkdir, 'sink': 'ShrinkFZF ', 'options': g:fzf_options
			\ }))
endf

func LastModifiedFile(dir, extension)
	return system('ls -t '.a:dir.'*'.a:extension.' | head -1')
endf

func ZettelLast()
	return LastModifiedFile(g:zkdir, g:zexte)
endf

func ZettelLastInsert()
	call Insert('<'.fnamemodify(ZettelLast(), ':t:r').'>')
endf

func ZettelOpenLast()
	exec 'e '.ZettelLast()
endf

" }}}
" Commands {{{1

command! -nargs=* ShrinkFZF call ShrinkFZF(<q-args>)

" }}}
" Mappings {{{1

nm <m-z>           :call ZettelSearch()<cr>
nm <LocalLeader>zn :call ZettelNew()<cr>
nm <LocalLeader>zi :call ZettelSearchInsert()<cr>
nm <LocalLeader>zl :call ZettelLastInsert()<cr>
nm <LocalLeader>zo :call ZettelOpenUnderCursor()<cr>
nm <LocalLeader>zu :call ZettelOpenLast()<cr>

" }}}

" : vim: set fdm=marker :
