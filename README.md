# quasi-filemark.vim

### what is this
quasi-filemark.vim is vimscript for simulation of filemark, such as 'A.

### setup
in your .vimrc:
    let g:quasi-filemark = {
        \   'm' : '/etc/my.cnf', 
        \   'v' : '~/.vimrc',
        \}
and when you type 'gnm', then your vim loads '/etc/my.cnf'.
