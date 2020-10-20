func! rpc#open_preview_page()
	let l:opener = {'linux': 'xdg-open', 'macos': 'open'}
	let l:platform = util#get_platform()
	let l:current_zettel = expand('%:t:r')
	if util#is_current_buf_zettel()
		let l:url = 'http://127.0.0.1:8080/'.l:current_zettel.'.html'
	else
		let l:url = 'http://127.0.0.1:8080/'
	end
		silent exec ":!".l:opener[l:platform]." '".l:url."'"
endf
