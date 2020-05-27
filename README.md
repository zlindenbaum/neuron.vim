# neuron.vim

Manage your Zettelkasten with the help of
[neuron](https://github.com/srid/neuron) in {n}vim.

## Requirements
- [neuron](https://github.com/srid/neuron)
- [fzf](https://github.com/junegunn/fzf.vim)
- [ripgrep](https://github.com/BurntSushi/ripgrep)

## Installation
### Using [vim-plug](https://github.com/junegunn/vim-plug)

add following to your ~/.vimrc

requirements:
```vim
Plug 'junegunn/fzf.vim'
Plug 'BurntSushi/ripgrep'
```
actual plugin:
```vim
Plug 'ihsanturk/neuron.vim'
```

## Mappings
```vim
nm <m-z>           :call ZettelSearch()<cr>
nm <LocalLeader>zn :call ZettelNew()<cr>
nm <LocalLeader>zi :call ZettelSearchInsert()<cr>
nm <LocalLeader>zl :call ZettelLastInsert()<cr>
nm <LocalLeader>zo :call ZettelOpenUnderCursor()<cr>
nm <LocalLeader>zu :call ZettelOpenLast()<cr>
```
