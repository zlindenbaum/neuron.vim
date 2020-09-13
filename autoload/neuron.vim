func! neuron#add_virtual_titles()
	if !exists("g:cache_zettels")
		return
	end
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
		let l:title = g:cache_titles[l:zettel_id]
		" TODO: Use
		" nvim_buf_set_extmark({buffer}, {ns_id}, {id}, {line}, {col}, {opts})
		" function instead of nvim_buf_set_virtual_text. Check this link for
		" help https://github.com/neovim/neovim/blob/e628a05b51d4620e91662f857d29f1ac8fc67862/runtime/doc/api.txt#L1935-L1955
		call nvim_buf_set_virtual_text(0, l:ns, l:lnum, [[l:title, g:style_virtual_title]], {})
	endfor

	" on gzn this key will not exist
	let l:backn = len(get(g:cache_backlinks, util#current_zettel(), []))
	if l:backn == 1
		let l:backtext = "1 backlink"
	else
		let l:backtext = l:backn." backlinks"
	endif
	call nvim_buf_set_virtual_text(0, l:ns, 0, [[l:backtext, "DiffChange"]], {})
endf

func! neuron#insert_zettel_select(as_folgezettel)
	if a:as_folgezettel
		let l:sink_to_use = 'util#insert_shrink_fzf_folgezettel'
	else
		let l:sink_to_use = 'util#insert_shrink_fzf'
	endif

	call fzf#run(fzf#wrap({
		\ 'options': util#get_fzf_options(),
		\ 'source': g:list_pair_zettelid_zetteltitle,
		\ 'sink': function(l:sink_to_use),
	\ }, g:neuron_fullscreen_search))
endf

func! neuron#search_content(use_cursor)
	let l:query = ""
	if a:use_cursor
		let l:query = expand("<cword>")
	endif
	call fzf#vim#ag(l:query, g:neuron_fullscreen_search)
endf

func! neuron#edit_zettel_select()
	call fzf#run(fzf#wrap({
		\ 'options': util#get_fzf_options(),
		\ 'source': g:list_pair_zettelid_zetteltitle,
		\ 'sink': function('util#edit_shrink_fzf'),
	\ }, g:neuron_fullscreen_search))
endf

func! neuron#edit_zettel_backlink()
	let l:current_zettel = util#current_zettel()

	let l:list = []
	for id in g:cache_backlinks[l:current_zettel]
		call add(l:list, id.":".g:cache_titles[id])
	endfor

	let l:options = util#get_fzf_options()
	let l:options = l:options + ["--header", "Backlinks to <".l:current_zettel.">"]
	let l:options = l:options + ["--reverse"]
	let l:options = l:options + ["--prompt", "Search backlink: "]

	call fzf#run(fzf#wrap({
		\ 'options': l:options,
		\ 'source': l:list,
		\ 'sink': function('util#edit_shrink_fzf'),
	\ }, g:neuron_fullscreen_search))
endf

func! neuron#edit_zettel_last()
	if empty(g:last_file)
		call util#handlerr('E6')
		return
	end

	exec 'edit '.g:last_file
endf

func! neuron#insert_zettel_last(as_folgezettel)
	if empty(g:last_file)
		call util#handlerr('E6')
		return
	end

	let l:zettelid = fnamemodify(g:last_file, ':t:r')
	call util#insert(l:zettelid, a:as_folgezettel)
endf

func! neuron#edit_zettel_new()
	exec 'edit '.system('neuron -d '.shellescape(g:zkdir).' new')
endf

func! neuron#edit_zettel_new_from_cword()
	let l:title = expand("<cword>")
	exec 'edit '.system('neuron -d '.shellescape(g:zkdir).' new "'.l:title.'"')
endf

func! neuron#edit_zettel_new_from_visual()
	" title from visual selection
	let l:vs = split(util#get_visual_selection(), "\n")
	let l:title = l:vs[0]

	" let l:content = l:vs[1:]
	exec 'edit '.system('neuron -d '.shellescape(g:zkdir).' new "'.l:title.'"')
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
	exec 'edit '.g:zkdir.a:zettel_id.g:zextension
endf

func! neuron#refresh_cache()
	try
		if !executable(g:path_neuron)
			call util#handlerr('E1')
		endif
	endtry

	let l:cmd = [g:path_neuron, "-d", g:zkdir, "query", "--uri", "z:zettels"]
	if has('nvim')
		call jobstart(l:cmd, {
			\ 'on_stdout': function('s:refresh_cache_callback_nvim'),
			\ 'stdout_buffered': 1
		\ })
	elseif has('job')
		let l:jobopt = {
			\ 'exit_cb': function('s:refresh_cache_callback_vim'),
			\ 'out_io': 'file',
			\ 'out_name': '/tmp/neuronzettelsbuffer',
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
func! s:refresh_cache_callback_vim(channel, x)
	let l:data = readfile("/tmp/neuronzettelsbuffer")
	call job_start("rm /tmp/neuronzettelsbuffer")
	call s:refresh_cache_callback(join(l:data))
endf

" neovim
func s:refresh_cache_callback_nvim(id, data, event)
	call s:refresh_cache_callback(join(a:data))
endf

func! s:refresh_cache_callback(data)
	let l:zettels = json_decode(a:data)["result"]

	call sort(l:zettels, function('util#zettel_date_sorter'))

	let g:cache_titles = {}
	let g:cache_zettels = []
	let g:list_pair_zettelid_zetteltitle = []
	let g:cache_backlinks = {}

	for z in l:zettels
		let g:cache_titles[z['zettelID']] = z['zettelTitle']
		call add(g:cache_zettels, { 'id': z['zettelID'], 'title': z['zettelTitle'], 'path': z['zettelPath'] })
		call add(g:list_pair_zettelid_zetteltitle, z['zettelID'].":".substitute(z['zettelTitle'], ':', '-', ''))
		let g:cache_backlinks[z['zettelID']] = []
	endfor

	for z in l:zettels
		for l in z['zettelQueries']
			if l[0] == 'ZettelQuery_ZettelByID'
				call add(g:cache_backlinks[l[1][0]], z['zettelID'])
			endif
		endfor
	endfor

 	call neuron#add_virtual_titles()
endf

let g:last_file = ""
let g:current_file = ""
let g:did_init = 0
func! neuron#on_enter()
	let g:last_file = g:current_file
	let g:current_file = expand("%s")

	if g:did_init
		return
	endif
	let g:did_init = 1
	call neuron#refresh_cache()
endf

let g:must_refresh_on_write = 0
func! neuron#on_write()
	if g:must_refresh_on_write
		call neuron#refresh_cache()
	else
		call neuron#add_virtual_titles()
	end
endf
