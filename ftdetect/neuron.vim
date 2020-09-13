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
	exec ':au! BufEnter '.g:zkdir.'*'.g:zextension.' call s:init()'
	exec ':au! BufAdd '.g:zkdir.'*'.g:zextension.' call neuron#add_virtual_titles()'
	exec ':au! BufWrite '.g:zkdir.'*'.g:zextension.' call neuron#on_write()'
aug END
let b:did_ftdetect = 1

let w:did_init = 0
func! s:init()
	" TODO: Activate markdown and neuron filetype at the same time.
	" exec ':au! BufRead,BufNewFile '.g:zkdir.'*'.g:zextension.' setf=neuron'
	" runtime! ftplugin/markdown.vim
	" runtime! ftplugin/markdown_*.vim ftplugin/markdown/*.vim
	if w:did_init
		return
	endif
	let w:did_init = 1
	call neuron#refresh_cache()
endf
