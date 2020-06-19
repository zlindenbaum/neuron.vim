func! s:neuron_rib_start()
	if g:neuron_rib_job == -1
		let g:neuron_rib_job = jobstart(['neuron', 'rib', '-wS'])
	end
	call s:open_preview_page()
endf

func! s:neuron_rib_stop()
	if g:neuron_rib_job == -1
		echom('Neuron rib is not running.')
	else
		call jobstop(g:neuron_rib_job)
		let g:neuron_rib_job = -1
		echom('Neuron rib job stopped.')
	end
endf

func! s:open_preview_page()
	let l:platform = s:get_platform()
	let l:current_buffer = expand('%:t:r')
	if util#is_current_buf_zettel()
		let l:url = 'http://127.0.0.1:8080/'.l:current_buffer.'.html'
	else
		let l:url = 'http://127.0.0.1:8080/'
	end
	" TODO: Dictionary based selection without l:platform variable (direct func)
	if l:platform == 'linux'
		silent exec ":!xdg-open '". l:url."'"
	elseif l:platform == 'macos'
		silent exec ":!open '". l:url."'"
	end
endf

aug neuron
	exec ':au! BufWipeout '.g:zkdir.'*'.g:zextension.' call s:add_virtual_titles()'
aug END

