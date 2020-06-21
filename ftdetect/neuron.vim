if exists('b:did_ftplugin') | finish | endif
aug neuron
	au BufRead,BufNewFile * call s:set_filetype()
aug END
let b:did_ftplugin = 1

func! s:set_filetype()
	" TODO: Activate markdown and neuron filetype at the same time.
	" exec ':au! BufRead,BufNewFile '.g:zkdir.'*'.g:zextension.' setf=neuron'
	" runtime! ftplugin/markdown.vim
	" runtime! ftplugin/markdown_*.vim ftplugin/markdown/*.vim
	call s:add_virtual_titles()
endf

func! s:add_virtual_titles()
	let l:re_neuron_link = '<\([0-9a-zA-Z_-]\+\)>' " TODO: Get ids from cache.
	if !exists('*nvim_buf_set_virtual_text')
		finish
	endif
	call nvim_buf_clear_namespace(0, 0, 0, line('$'))
	let l:lnum = 0
	for line in readfile(expand("%:p"))
		let l:line_with_zettel_id = matchlist(line, l:re_neuron_link)
		if(!empty(l:line_with_zettel_id))
			let l:zettel_id = l:line_with_zettel_id[1]
			let l:title = neuron#get_zettel_title(l:zettel_id)
			call nvim_buf_set_virtual_text(0,0,
				\ l:lnum, [[l:title, g:style_virtual_title]],{})
		endif
		let l:lnum += 1
	endfor
endf
