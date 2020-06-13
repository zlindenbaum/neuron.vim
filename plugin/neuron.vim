" =============================================================================
" File:        neuron.vim
" Description: Take zettelkasten notes using neuron in Vim.
" Author:      ihsan <ihsanl at pm dot me>
" Created At:  1590326456
" License:     MIT License
" =============================================================================

" TODO @1591217335: Run neuron rib
"                   let job_id = jobstart('neuron rib -wS', {'detach':1})

" TODO @1591217503: Stop when leaving buffer
"                   jobstop(job_id)

" TODO @1591217616: Mappings should be non-destructive check
"                   https://github.com/reedes/vim-wheel how he uses mappings
"                   with <Plug>function shape.

" Configuration {{{1

let g:zkdir = get(g:, 'zkdir', $HOME.'/zettelkasten/')
let g:zexte = get(g:, 'zexte', '.md')
let g:fzf_options = get(g:, 'fzf_options', '-d"title: " --with-nth 2 --prompt "Zettelkasten: "')
let g:style_virtual_title = get(g:, 'style_virtual_title', 'Comment')

" }}}
" Variables {{{1

let s:re_neuron_link = '<\([0-9a-z]\{8}\)>'

" }}}
" Util Functions {{{1

func! IsCurrentBufZettel()
	if expand('%:p') =~ g:zkdir.'.*'.g:zexte
		return v:true
	else
		return v:false
	end
endf

func! GetPlatform() abort
	if has('win32') || has('win64')
		return 'win'
	elseif has('mac') || has('macvim')
		return 'macos'
	else
		return 'linux'
	endif
endf

func! GetTitleOfZettel(ZettelID)
	let l:second_line = readfile(ExpandZettelID(a:ZettelID))[1]
	return split(l:second_line, 'title: ')[0]
endf

func! ExpandZettelID(ZettelID)
	return g:zkdir . a:ZettelID . g:zexte
endf

func! ZettelOpen(ZettelID)
	exec 'edit '.ExpandZettelID(a:ZettelID)
endf

func! ZettelSearch() "opens the zettel after search.
	call fzf#vim#grep("rg 'title:' --column", 1,
			\ fzf#vim#with_preview({'dir':g:zkdir, 'options': g:fzf_options}))
endf

func! ZettelOpenUnderCursor()
	call ZettelOpen(expand('<cword>'))
endf

func! ZettelNew() " relying on https://github.com/srid/neuron
	exec 'e '.system('neuron new "PLACEHOLDER"').' |norm jfP"_D'
endf

func! Insert(thing)
	put =a:thing
endf

func! ShrinkFZF(output)
	call Insert('<'.split(a:output, g:zexte)[0].'>')
endf

func! ZettelSearchInsert()
	call fzf#vim#grep("rg 'title:' --column", 1,
			\ fzf#vim#with_preview({
				\ 'dir':g:zkdir, 'sink': 'ShrinkFZF ', 'options': g:fzf_options
			\ }))
endf

func! LastModifiedFile(dir, extension)
	return system('ls -t '.a:dir.'*'.a:extension.' | head -1')
endf

func! ZettelLast()
	return LastModifiedFile(g:zkdir, g:zexte)
endf

func! ZettelLastInsert()
	call Insert('<'.fnamemodify(ZettelLast(), ':t:r').'>')
endf

func! ZettelOpenLast()
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
" Virtual Titles {{{1

func! AddVirtualTitles()
	if !exists('*nvim_buf_set_virtual_text')
		return
	endif
	call nvim_buf_clear_namespace(0, 0, 0, line('$'))
	let l:lnum = 0
	for line in readfile(expand("%:p"))
		let l:line_with_zettel_id = matchlist(line, s:re_neuron_link)
		if(!empty(l:line_with_zettel_id))
			let l:zettel_id = l:line_with_zettel_id[1]
			let l:title = GetTitleOfZettel(l:zettel_id)
			call nvim_buf_set_virtual_text(0,0,
						\ l:lnum, [[l:title, g:style_virtual_title]],{})
		endif
		let l:lnum += 1
	endfor
endf

aug neuron
	exec ':au! BufWinEnter '.g:zkdir.'*'.g:zexte.' call AddVirtualTitles()'
aug END

" }}}

" : vim: set fdm=marker :
