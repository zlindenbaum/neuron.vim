" command! -nargs=* ShrinkFZF call s:shrink_fzf(<q-args>)
" OLD_NAME: ZettelSearchInsert()
func! neuron#insert_zettel_select()
	let l:fzf_options_tmp = deepcopy(g:fzf_options)
	call extend(l:fzf_options_tmp, ['--prompt', 'Insert Zettel ID: '])
	" call neuron#refresh_cache()
	return fzf#run(fzf#wrap({
		\ 'options': l:fzf_options_tmp,
		\ 'source': util#get_list_pair_zettelid_zetteltitle(),
		\ 'sink': function('util#insert_shrink_fzf'),
	\ }))
endf

" OLD_NAME: ZettelSearch() "opens the zettel after search.
func! neuron#edit_zettel_select()
	let l:fzf_options_tmp = deepcopy(g:fzf_options)
	call extend(l:fzf_options_tmp, ['--prompt', 'Edit Zettel: '])
	" call neuron#refresh_cache()
	call fzf#run(fzf#wrap({
		\ 'options': l:fzf_options_tmp,
		\ 'source': util#get_list_pair_zettelid_zetteltitle(),
		\ 'sink': function('util#edit_shrink_fzf'),
	\ }))
endf

" OLD_NAME: ZettelOpenLast()
func! neuron#edit_zettel_last()
	exec 'e '.s:get_zettel_last()
endf

" OLD_NAME: ZettelLastInsert()
func! neuron#insert_zettel_last()
	call util#insert(
		\ util#get_formatted_zettelid(fnamemodify(s:get_zettel_last(), ':t:r')))
	" call util#insert('<'.fnamemodify(s:get_zettel_last(), ':t:r').'>')
endf

" OLD_NAME: ZettelNew() " relying on https://github.com/srid/neuron
func! neuron#edit_zettel_new() " relying on https://github.com/srid/neuron
	exec 'e '.system('neuron new "PLACEHOLDER"')
		\ .' | call search("PLACEHOLDER") | norm"_D'
	startinsert!
	call neuron#refresh_cache()
endf

" OLD_NAME: ZettelOpenUnderCursor()
func! neuron#edit_zettel_under_cursor()
	let l:zettel_id = expand('<cword>')
	if util#is_zettel_valid(l:zettel_id)
		call neuron#edit_zettel(l:zettel_id)
	else
		echom "No such zettel!"
	end
endf

" OLD_NAME: GetTitleOfZettel(ZettelID)
func! neuron#get_zettel_title(zettel_id)
	" call neuron#refresh_cache()
	return g:cache_zettels[a:zettel_id]['title']
endf

" TODO: Remove jq dependency find vimscript native solution.
func! neuron#refresh_cache()
	let g:cache_zettels = json_decode(s:run(
		\ "query --uri 'z:zettels'|jq 'reduce .result[] as $i ({}; .[$i.id]=$i)'"
		\ ))
endf

" OLD_NAME: ZettelOpen(zettel_id)
func! neuron#edit_zettel(zettel_id)
	exec 'edit '.s:expand_zettel_id(a:zettel_id)
endf

func! s:run(cmd)
	return system('neuron '.a:cmd)
endf

func! s:expand_zettel_id(zettel_id)
	return g:zkdir . a:zettel_id . g:zextension
endf

" OLD_NAME: ZettelLast()
func! s:get_zettel_last()
	return util#get_file_modified_last(g:zkdir, g:zextension)
endf
