set mouse=a
set backspace=indent,eol,start
call plug#begin('~/.vim/plugged')
Plug 'psliwka/vim-smoothie'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'sonph/onehalf', { 'rtp': 'vim' }
Plug 'mhinz/vim-startify'
Plug 'dense-analysis/ale'
Plug 'ojroques/vim-oscyank'
Plug 'icedman/vim-textmate'
call plug#end()
"luafile ~/.vim/plugged/vim-textmate/vim-textmate.lua
syntax on
"set ttymouse=xterm2
au BufRead,BufNewFile *.inp set filetype=charmm
au! Syntax charmm source $HOME/.vim/syntax/charmm.vim
":au VimLeave * :!clear
autocmd VimLeave * silent !tput rmcup

if &background ==# "dark"
    set background=dark
    " optionally set a dark-friendly scheme here
else
    set background=light
    " optionally set a light-friendly scheme here
endif

" Configure OSCYank to bypass zellij by writing to $SSH_TTY
let g:oscyank_silent = v:true
let g:oscyank_term = 'default'

" Use custom command that writes directly to SSH_TTY
function! CustomOSCYank(text)
    call system('osc-copy', a:text)
endfunction

" Mappings - yank to system clipboard via OSC52
nmap <leader>c <Plug>OSCYankOperator
nmap <leader>cc <leader>c_
vmap <leader>c <Plug>OSCYankVisual

" Auto-copy all yanks to system clipboard via OSC52
autocmd TextYankPost * call system('osc-copy', getreg('"'))

" 4-space indentation (good for Python, CUDA, Bash)
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent


autocmd FileType charmm setlocal shiftwidth=2 tabstop=2
autocmd FileType charmm setlocal commentstring=!%s
cnoremap w!! w !mkdir -p %:h && tee % > /dev/null
