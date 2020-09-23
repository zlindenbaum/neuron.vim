let g:neuron_extension = get(g:, 'neuron_extension', '.md')
let g:neuron_dir = get(g:, 'neuron_dir', fnamemodify(expand("%:p"), ":h")."/")

"fallback to using getcwd if the above gives us a relative path
if g:neuron_dir == './'
  let g:neuron_dir = getcwd() . "/"
endif

if !filereadable(g:neuron_dir."neuron.dhall")
    " if there is no neuron.dhall file in current dir then it is not a zettelkasten
	finish
endif

if exists('b:did_ftdetect') | finish | endif
aug neuron
	exec ':au! BufRead '.g:neuron_dir.'*'.g:neuron_extension.' call neuron#add_virtual_titles()'
	exec ':au! BufEnter '.g:neuron_dir.'*'.g:neuron_extension.' call neuron#on_enter()'
	exec ':au! BufWrite '.g:neuron_dir.'*'.g:neuron_extension.' call neuron#on_write()'
aug END
let b:did_ftdetect = 1
