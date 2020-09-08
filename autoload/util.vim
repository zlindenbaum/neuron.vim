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

func! util#insert(zettelid, as_folgezettel)
	if a:as_folgezettel
		let l:formatted = "[[[".a:zettelid."]]]"
	else
		let l:formatted = "[[".a:zettelid."]]"
	endif

	let l:word_under = expand('<cword>')
	if !empty(l:word_under) && empty(trim(l:word_under, "[]<>"))
		" erase things like '[[]]' before adding
		execute "normal! diwi".l:formatted
	else
		execute "normal! a".l:formatted
	endif

endf

func! util#cache_exists()
	if !exists('g:cache_zettels')
		return 0
	elseif empty(g:cache_zettels)
		return 0
	elseif type(g:cache_zettels) != 4 " dictionary
		return 0
	else
		return 1
	end
endf

func! util#get_list_pair_zettelid_zetteltitle()
	let l:final = []
	if util#cache_exists()
		for i in keys(g:cache_zettels)
			call add(l:final, i.':'.g:cache_zettels[i]['zettelTitle'])
		endfor
		return l:final
	else
		call util#handlerr('E0')
	end
endf

func! util#is_zettelid_valid(zettelid)
	if empty(a:zettelid)
		return 0
	end
	if !util#cache_exists()
		call neuron#refresh_cache()
	endif
	if index(keys(g:cache_zettels), util#deform_zettelid(a:zettelid)) >= 0
		return 1
	else
		return 0
	end
endf

func! util#get_zettel_in_line(line)
	for i in keys(g:cache_zettels)
		let l:matched = matchstr(a:line, i)
		if !empty(l:matched)
			return l:matched
		end
	endfor
	return ""
endf

func! util#deform_zettelid(zettelid)
	if a:zettelid =~ "\[\[\[\?.*\]\]\]\?"
		return substitute(a:zettelid, '\[\[\[\?\([0-9a-zA-Z_-]\+\)\(?cf\)\?\]\]\]\?', '\1', 'g')
	else
		return a:zettelid
	end
endf

func! util#insert_shrink_fzf(line)
	call util#insert(util#get_zettel_in_line(a:line), 0)
endf

func! util#insert_shrink_fzf_folgezettel(line)
	call util#insert(util#get_zettel_in_line(a:line), 1)
endf

func! util#edit_shrink_fzf(line)
	call neuron#edit_zettel(util#get_zettel_in_line(a:line))
endf

func! util#remove_orphans(title)
	if util#cache_exists()
		let l:count = 0
		let l:targetdir = '/tmp/orphan-zettels/'
		call mkdir(l:targetdir, 'p')
		for i in keys(g:cache_zettels)
			if g:cache_zettels[i]['zettelTitle'] == a:title
				call system("mv ".g:zkdir.g:cache_zettels[i]['zettelPath']." ".l:targetdir)
				let l:count += 1
			end
		endfor
		echom l:count.' orphan zettels are moved to '.l:targetdir.'.'
		echom 'You can manually delete '.l:targetdir.' directory.'
	else
		call util#handlerr('E0')
	end
endf

func! util#handlerr(errcode)
	let l:neuron_errors = deepcopy(g:neuron_errors)
	let l:err = l:neuron_errors[a:errcode]
	let l:errmsg='neuron: '.a:errcode.': '.l:err['problem']
	if len(l:err['suggestions']) > 0
		let l:errmsg .= '! suggestion(s): '.
			\ join(l:err['suggestions'], ' or ')
	end
	echoerr l:errmsg
endf
