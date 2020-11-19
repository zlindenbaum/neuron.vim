let g:neuron_extension = get(g:, 'neuron_extension', '.md')

" if there is no neuron.dhall file in current dir then it is not a zettelkasten
if !filereadable(g:neuron_dir."neuron.dhall")
	finish
endif

if exists('b:did_ftdetect') | finish | endif
aug neuron
	exec ':au! BufRead '.fnameescape(g:neuron_dir).'*'.fnameescape(g:neuron_extension).' call neuron#add_virtual_titles()'
	exec ':au! BufEnter '.fnameescape(g:neuron_dir).'*'.fnameescape(g:neuron_extension).' call neuron#on_enter()'
	exec ':au! BufWrite '.fnameescape(g:neuron_dir).'*'.fnameescape(g:neuron_extension).' call neuron#on_write()'
aug END
let b:did_ftdetect = 1
