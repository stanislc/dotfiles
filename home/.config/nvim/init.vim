call plug#begin()

Plug 'tribela/transparent.nvim'
Plug 'psliwka/vim-smoothie'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'sonph/onehalf', { 'rtp': 'vim' }
Plug 'mhinz/vim-startify'
Plug 'dense-analysis/ale'
Plug 'ojroques/vim-oscyank'
Plug 'psliwka/termcolors.nvim'

call plug#end()

set mouse=a
set backspace=indent,eol,start
set notermguicolors

syntax on
autocmd VimLeave * silent !tput rmcup

let g:oscyank_silent = v:true
let g:oscyank_term = 'default'

function! CustomOSCYank(text)
    call system('osc-copy', a:text)
endfunction

nmap <leader>c <Plug>OSCYankOperator
nmap <leader>cc <leader>c_
vmap <leader>c <Plug>OSCYankVisual

autocmd TextYankPost * call system('osc-copy', getreg('"'))

set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent

autocmd FileType charmm setlocal shiftwidth=2 tabstop=2
autocmd FileType charmm setlocal commentstring=!%s
cnoremap w!! w !mkdir -p %:h && tee % > /dev/null
