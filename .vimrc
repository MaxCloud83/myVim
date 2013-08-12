syntax on

highlight LineNr ctermfg=darkyellow
highlight NonText ctermfg=darkgrey
highlight Folded ctermfg=blue
highlight SpecialKey cterm=underline ctermfg=darkgrey
highlight Search ctermfg=lightyellow
highlight Pmenu ctermfg=8
highlight PmenuSel ctermfg=1
highlight PmenuSbar ctermfg=0

let g:neocomplcache_enable_at_startup = 1
autocmd VimEnter * NERDTree

highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=white
match ZenkakuSpace /　/
set ts=4
set shiftwidth=4
set softtabstop=4
"set expandtab
set termencoding=utf-8
set list
set listchars=tab:>_,extends:<,trail:_
set nocompatible
set number
set hlsearch

inoremap <expr> _  smartchr#loop(' = ', '=', ' == ')

" 文字コード指定htmlファイルはcp932
function! s:html()
  set encoding=utf-8
  set fileencodings=cp932,utf-8
endfunction

" 文字コードの自動認識
" pmファイルなど
function! s:pm()
  if &encoding !=# 'utf-8'
    set encoding=japan
    set fileencoding=japan
  endif
  if has('iconv')
    let s:enc_euc = 'euc-jp'
    let s:enc_jis = 'iso-2022-jp'
    " iconvがeucJP-msに対応しているかをチェック
    if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
      let s:enc_euc = 'eucjp-ms'
      let s:enc_jis = 'iso-2022-jp-3'
    " iconvがJISX0213に対応しているかをチェック
    elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
      let s:enc_euc = 'euc-jisx0213'
      let s:enc_jis = 'iso-2022-jp-3'
    endif
    " fileencodingsを構築
    if &encoding ==# 'utf-8'
      let s:fileencodings_default = &fileencodings
      let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
      let &fileencodings = &fileencodings .','. s:fileencodings_default
      unlet s:fileencodings_default
    else
      let &fileencodings = &fileencodings .','. s:enc_jis
      set fileencodings+=utf-8,ucs-2le,ucs-2
      if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
        set fileencodings+=cp932
        set fileencodings-=euc-jp
        set fileencodings-=euc-jisx0213
        set fileencodings-=eucjp-ms
        let &encoding = s:enc_euc
        let &fileencoding = s:enc_euc
      else
        let &fileencodings = &fileencodings .','. s:enc_euc
      endif
    endif
    " 定数を処分
    unlet s:enc_euc
    unlet s:enc_jis
  endif
  " 日本語を含まない場合は fileencoding に encoding を使うようにする
  if has('autocmd')
    function! AU_ReCheck_FENC()
      if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
        let &fileencoding=&encoding
      endif
    endfunction
    autocmd BufReadPost * call AU_ReCheck_FENC()
  endif
endfunction

" ファイルのsuffixで文字コードの判断をすす
let suffix=expand("%:e")
if (match(suffix, 'html\|sub') == 0)
  call s:html()
else
  call s:pm()
endif

" 改行コードの自動認識
set fileformats=unix,dos,mac
" □とか○の文字があってもカーソル位置がずれないようにする
if exists('&ambiwidth')
  set ambiwidth=double
endif

set laststatus=2
"ステータスラインに文字コードと改行文字を表示する
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P

" ,< HTML comment
map ,< :s/^\(.*\)$/<!-- \1 -->/<CR><Esc>:nohlsearch<CR>

nmap <Esc><Esc> :nohlsearch<CR><Esc>

" 関数名リスト
" TODO: 全局変数と関数コメントも?
nnoremap <silent> <F8> :TlistToggle<CR>
map <F5> :!/usr/bin/ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
let Tlist_Exit_OnlyWindow = 1     " exit if taglist is last window open
let Tlist_Ctags_Cmd = '/usr/bin/ctags'
let Tlist_Exit_OnlyWindow = 1     " exit if taglist is last window open
let Tlist_Show_One_File = 1       " Only show tags for current buffer
let Tlist_Enable_Fold_Column = 0  " no fold column (only showing one file)
let tlist_sql_settings = 'sql;P:package;t:table'

" apache 再起動
map res :!sudo /etc/init.d/httpd restart<CR>

" paste the latest yank to command line use Ctrl+R 

"echo expand("%")

" File Status
"set laststatus=2
"highlight statusline cterm=bold ctermfg=black ctermbg=white
"set statusline=%{((&fenc==\"\")?\"\":\"\ \|\ \".&fenc)}\ \|

"    :tag getUser => Jump to getUser method
"    :tn (or tnext) => go to next search result
"    :tp (or tprev) => to to previous search result
"    :ts (or tselect) => List the current tags
"    => Go back to last tag location
"    +Left click => Go to definition of a method

