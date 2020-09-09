func! neuron#add_virtual_titles()
	if !exists('*nvim_buf_set_virtual_text')
		return
	endif
	let l:ns = nvim_create_namespace('neuron')
	call nvim_buf_clear_namespace(0, l:ns, 0, -1)
	let l:re_neuron_link = '\[\[\[\?\([0-9a-zA-Z_-]\+\)\(?cf\)\?\]\]\]\?'
	let l:lnum = -1
	for line in getline(1, "$")
		let l:lnum += 1
		let l:zettel_id = util#get_zettel_in_line(line)
		if empty(l:zettel_id)
			continue
		endif
		let l:title = w:cache_titles[l:zettel_id]
		" TODO: Use
		" nvim_buf_set_extmark({buffer}, {ns_id}, {id}, {line}, {col}, {opts})
		" function instead of nvim_buf_set_virtual_text. Check this link for
		" help https://github.com/neovim/neovim/blob/e628a05b51d4620e91662f857d29f1ac8fc67862/runtime/doc/api.txt#L1935-L1955
		call nvim_buf_set_virtual_text(0, l:ns, l:lnum, [[l:title, g:style_virtual_title]], {})
	endfor
endf

func! neuron#insert_zettel_select(as_folgezettel)
	if a:as_folgezettel
		let l:sink_to_use = 'util#insert_shrink_fzf_folgezettel'
	else
		let l:sink_to_use = 'util#insert_shrink_fzf'
	endif

	call fzf#run(fzf#wrap({
		\ 'options': extend(deepcopy(g:fzf_options),['--prompt','Insert Zettel ID: ']),
		\ 'source': w:list_pair_zettelid_zetteltitle,
		\ 'sink': function(l:sink_to_use),
	\ }))
endf

func! neuron#search_content(query, fullscreen)
	let cmd_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
	let initial_cmd = printf(cmd_fmt, shellescape(a:query))
	let reload_cmd = printf(cmd_fmt, '{q}')
	let spec = {'dir': g:zkdir,
		\ 'options': [
			\ '--phony',
			\ '--query',
			\ a:query,
			\ '--bind',
			\ 'change:reload:'.reload_cmd
		\]
	\}
	call fzf#vim#grep(initial_cmd,1,fzf#vim#with_preview(spec),a:fullscreen)
endf

func! neuron#edit_zettel_select()
	try
		call fzf#run(fzf#wrap({
			\ 'options': extend(deepcopy(g:fzf_options),['--prompt','Edit Zettel: ']),
			\ 'source': w:list_pair_zettelid_zetteltitle,
			\ 'sink': function('util#edit_shrink_fzf'),
		\ }))
	catch /^jq not found/
		call s:warn("Add: let g:path_jq = 'path/to/jq' to your vimrc.")
	catch /^neuron not found/
		call s:warn("Add: let g:path_neuron = 'path/to/neuron' to your vimrc")
	endtry
endf

func! neuron#edit_zettel_last()
	if !exists("w:last")
		call util#handlerr('E6')
		return
	end

	let l:file = w:last
	let w:last = expand('%s')
	exec 'edit '.l:file
endf

func! neuron#insert_zettel_last(as_folgezettel)
	if !exists("w:last")
		call util#handlerr('E6')
		return
	end

	let l:zettelid = fnamemodify(w:last, ':t:r')
	call util#insert(l:zettelid, a:as_folgezettel)
endf

func! neuron#edit_zettel_new() " relying on https://github.com/srid/neuron
	let w:last = expand('%s')
	exec 'edit '.system('neuron -d '.shellescape(g:zkdir).' new "PLACEHOLDER"')
		\ .' | call search("PLACEHOLDER") | norm"_D'
endf

func! neuron#edit_zettel_under_cursor()
	let l:zettel_id = trim(expand('<cword>'), "<>[]")
	if util#is_zettelid_valid(l:zettel_id)
		call neuron#edit_zettel(l:zettel_id)
	else
		let l:zettel_id = trim(expand('<cWORD>'), "<>[]")
		if util#is_zettelid_valid(l:zettel_id)
			call neuron#edit_zettel(l:zettel_id)
		else
			call util#handlerr('E3')
		endif
	endif
endf

func! neuron#edit_zettel(zettel_id)
	let w:last = expand('%s')
	exec 'edit '.s:expand_zettel_id(a:zettel_id)
endf

func! neuron#refresh_cache()
	try
		if !executable(g:path_neuron)
			call util#handlerr('E1')
		endif
		if !executable(g:path_jq)
			call util#handlerr('E2')
		endif
	endtry

	let l:cmd = [g:path_neuron, "-d", g:zkdir, "query", "--uri", "z:zettels"]
	if has('nvim')
		call jobstart(l:cmd, {
			\ 'on_stdout': function('s:refresh_cache_callback'),
			\ 'stdout_buffered': 1
		\ })
	elseif 1 == 2
		" vim 8 async jobs do not work for now
		let l:jobopt = {
			\ 'close_cb': function('s:refresh_cache_callback_vim'),
			\ 'out_mode': 'raw',
			\ 'out_io': 'buffer',
			\ 'out_name': 'neuronzettelsbuffer',
			\ 'err_io': 'out'
		\ }
		if has('patch-8.1.350')
			let l:jobopt['noblock'] = 1
		endif
		call job_start(l:cmd, l:jobopt)
	else
		let l:cmd[2] = shellescape(g:zkdir)
		let l:data = system(join(cmd))
		call s:refresh_cache_callback(l:data)
	endif
endf

" vim 8
func! s:refresh_cache_callback_vim(channel)
	let l:data = getbufline('neuronzettelsbuffer', 2, '$')
	bw bufnr('neuronzettelsbuffer')
	call s:refresh_cache_callback(join(l:data))
endf

" neovim
func s:refresh_cache_callback_nvim(id, data, event)
	call s:refresh_cache_callback(join(a:data))
endf

func! s:refresh_cache_callback(data)
	let l:zettels = json_decode(a:data)["result"]

	let w:cache_titles = {}
	let w:cache_zettels = []
	let w:list_pair_zettelid_zetteltitle = []

	for z in l:zettels
		let w:cache_titles[z['zettelID']] = z['zettelTitle']
		let w:cache_zettels = add(w:cache_zettels, { 'id': z['zettelID'], 'title': z['zettelTitle'], 'path': z['zettelPath'] })
		let w:list_pair_zettelid_zetteltitle = add(w:list_pair_zettelid_zetteltitle, z['zettelID'].":".z['zettelTitle'])
	endfor

 	call neuron#add_virtual_titles()
endf

func! s:expand_zettel_id(zettel_id)
	return g:zkdir . a:zettel_id . g:zextension
endf

func! s:warn(msg)
	echohl WarningMsg
	echo a:msg
	echohl None
	return 0
endf
