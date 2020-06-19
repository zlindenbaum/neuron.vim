func! util#get_platform() abort
	if has('win32') || has('win64')
		return 'win'
	elseif has('mac') || has('macvim')
		return 'macos'
	else
		return 'linux'
	endif
endf

func! util#is_current_buf_zettel()
	" TODO: Use filetypes instead with au commands and ftdetect/ folder.
	if expand('%:p') =~ g:zkdir.'.*'.g:zextension
		return v:true
	else
		return v:false
	end
endf

func! util#insert(thing)
	put =a:thing
endf

func! util#get_list_pair_zettelid_zetteltitle()
	let l:final = []
	for i in keys(g:cache_zettels)
		" call add(l:final, g:cache_zettels[i]['path'].':'.g:cache_zettels[i]['title'])
		call add(l:final, i.':'.g:cache_zettels[i]['title'])
	endfor
	return l:final
endf

func! util#is_zettel_valid(zettelid)
	" call neuron#refresh_cache()
	if index(keys(g:cache_zettels), a:zettelid) >= 0
		return v:true
	else
		return v:false
endf

func! util#filter_zettels_in_line(line, ...)
	let l:found = []
	let l:n = get(a:, 1, -1)
	" call neuron#refresh_cache()
	for i in keys(g:cache_zettels)
		let l:matched = matchstr(a:line, i)
		" if l:matched != ''
		if !empty(l:matched)
			call add(l:found, l:matched) 
		end
	endfor
	if l:n < 0
		return l:found
	else
		return l:found[l:n]
	end
endf

" (line, [nth])
func! util#get_formatted_zettelid(line, ...)
	let l:n = get(a:, 1, 0)
	let l:found = util#filter_zettels_in_line(a:line)
	if len(l:found) > l:n
		let l:decided = l:found[l:n]
		if l:decided =~ "<.*>"
			return l:decided
		else
			return '<'.l:decided.'>'
		end
	else
		throw "Error: Can't find any zettel id in this line!"
	end
endf

"                 ==========  // I stayed here \\  ==========                 "

func! util#insert_shrink_fzf(line)
	call util#insert(util#get_formatted_zettelid(a:line, 0))
endf

"                 ==========  \\ I stayed here //  ==========                 "

func! util#edit_shrink_fzf(line)
	call neuron#edit_zettel(util#filter_zettels_in_line(a:line, 0))
endf

" OLD_NAME: LastModifiedFile(dir, extension)
func! util#get_file_modified_last(dir, extension)
	return system('ls -t '.a:dir.'*'.a:extension.' | head -1')
endf
