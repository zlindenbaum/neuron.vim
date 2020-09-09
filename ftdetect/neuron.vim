let g:zextension = get(g:, 'zextension', '.md')
let g:zkdir = get(g:, 'zkdir', $HOME.'/zettelkasten/')

" search for neuron.dhall
let s:current = expand("%:p")
let s:dir = fnamemodify(s:current, ":h:r")
while s:dir != "/"
	if filereadable(s:dir."/neuron.dhall")
		let g:zkdir = s:dir."/"
		break
	endif
	let s:dir = fnamemodify(s:dir, ":h:r")
endwhile

if exists('b:did_ftdetect') | finish | endif
aug neuron
	exec ':au! BufEnter '.g:zkdir.'*'.g:zextension.' call s:set_filetype()'
	exec ':au! BufWritePost '.g:zkdir.'*'.g:zextension.' call neuron#add_virtual_titles()'
aug END
let b:did_ftdetect = 1

func! s:set_filetype()
	" TODO: Activate markdown and neuron filetype at the same time.
	" exec ':au! BufRead,BufNewFile '.g:zkdir.'*'.g:zextension.' setf=neuron'
	" runtime! ftplugin/markdown.vim
	" runtime! ftplugin/markdown_*.vim ftplugin/markdown/*.vim
	call neuron#refresh_cache()
endf
