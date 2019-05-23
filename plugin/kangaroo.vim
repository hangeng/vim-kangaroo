let w:cur_pos = -1

function! s:push()
	if !exists('w:positions')
		let w:positions = []
        let w:cur_pos = -1
	endif

    if w:cur_pos <= len(w:positions)
        let w:positions = w:positions[ : w:cur_pos]
    endif

	let pos = [bufnr("%"), winsaveview()]
	if len(w:positions) == 0 || w:positions[-1][0] != pos[0] || w:positions[-1][1]["lnum"] != pos[1]["lnum"]
		call add(w:positions, pos)
	    let w:cur_pos = len(w:positions) - 1
    endif
    " echo "push"
endfunction

function! s:pop()
	if !exists('w:positions') || len(w:positions) == 0 
		echohl ErrorMsg | echo "jump stack empty" | echohl None
		return
	endif
	let [bufnr, pos] = remove(w:positions, -1)
	if bufnr != bufnr("%")
		execute "edit #" . bufnr
	endif
	call winrestview(pos)
    " echo "pop"
endfunction


function! s:backward()
	if !exists('w:positions') || len(w:positions) == 0 || w:cur_pos == -1
		echohl ErrorMsg | echo "jump stack underflow" | echohl None
		return
	endif

    " if current cusor postion is same as the position of w:cur_pos
	let pos = [bufnr("%"), winsaveview()]
	if w:positions[w:cur_pos][0] != pos[0] || w:positions[w:cur_pos][1]["lnum"] != pos[1]["lnum"]
    	let [bufnr, pos] = w:positions[w:cur_pos]
    else
        if (w:cur_pos == 0)
            echohl ErrorMsg | echo "jump stack overflow" | echohl None
            return
        endif
        let w:cur_pos -= 1
	    let [bufnr, pos] = w:positions[w:cur_pos]
    endif
    if bufnr != bufnr("%")
        execute "edit #" . bufnr
    endif
    call winrestview(pos)
    " exe 'normal! zz'
    " echo "backward"
endfunction

function! s:forward()
	if !exists('w:positions') || w:cur_pos >= len(w:positions)
		echohl ErrorMsg | echo "jump stack overflow" | echohl None
		return
	endif

    " if current cusor postion is same as the position of w:cur_pos
	let pos = [bufnr("%"), winsaveview()]
	if w:positions[w:cur_pos][0] != pos[0] || w:positions[w:cur_pos][1]["lnum"] != pos[1]["lnum"]
    	let [bufnr, pos] = w:positions[w:cur_pos]
    else
        if (w:cur_pos+1 >= len(w:positions))
            echohl ErrorMsg | echo "jump stack overflow" | echohl None
            return
        endif
        let w:cur_pos += 1
	    let [bufnr, pos] = w:positions[w:cur_pos]
    endif
	if bufnr != bufnr("%")
		execute "edit #" . bufnr
	endif
	call winrestview(pos)
    " exe 'normal! zz'
    " echo "forward"
endfunction

function! s:clear()
	if !exists('w:positions')
		echohl ErrorMsg | echo "stack empty" | echohl None
		return
	endif
    let w:cur_pos = -1
    let w:positions=[]
    echohl ErrorMsg | echo "clear stack" | echohl None
endfunction


command! KangarooPush call s:push()
command! KangarooPop call s:pop()
command! KangarooBackward call s:backward()
command! KangarooForward call s:forward()
command! KangarooClear call s:clear()

noremap <silent> <Plug>KangarooPush :<C-U>KangarooPush<CR>
noremap <silent> <Plug>KangarooPop :<C-U>KangarooPop<CR>
noremap <silent> <Plug>KangarooForward :<C-U>KangarooForward<CR>
noremap <silent> <Plug>KangarooBackward :<C-U>KangarooBackward<CR>
noremap <silent> <Plug>KangarooClear :<C-U>KangarooClear<CR>

if !exists("g:kangaroo_no_mappings") || !g:kangaroo_no_mappings
	nmap <silent> aa <Plug>KangarooPush
	nmap <silent> pp <Plug>KangarooPop
	nmap <silent> bb <Plug>KangarooBackward
	nmap <silent> ff <Plug>KangarooForward
	nmap <silent> cc <Plug>KangarooClear
endif

