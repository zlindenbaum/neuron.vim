# neuron.vim
Manage your [Zettelkasten](https://neuron.zettel.page/2011401.html) with the
help of [neuron](https://github.com/srid/neuron) in {n}vim.

(This is an actively maintaned fork of [`ihsanturk/neuron.vim`](https://github.com/ihsanturk/neuron.vim) that works with newer versions of `neuron` and changes basically everything, with extra features, commands and different options.)

![usage-photo](screenshot.png)

## Requirements

- [neuron](https://github.com/srid/neuron)
- [fzf](https://github.com/junegunn/fzf.vim)
- [ag](https://github.com/mizuno-as/silversearcher-ag) if you intend to use the content search command.

## Installation
### Using [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'junegunn/fzf.vim'
Plug 'fiatjaf/neuron.vim'
```

## Usage

  1. Open a zettel with `vim` or `nvim`. On `nvim` it should
    a. Show a virtual floating text on the first line saying how many backlinks it has.
    b. Show a virtual title for each linked zettel in the body.
  2. Type `gzZ` to show a list of backlinks. Selecting one will navigate to it.
  3. Type `gzz` to show a list of all zettels, you can search their titles. Selecting one will navigate to it.
  4. Type `gzi` to show the same `gzz` list. Selecting one will insert a link to it right in front of the your cursor. `gzI` instead will insert a folgezettel link (`[[[...]]]`).
  5. If you put your cursor on top of a link to another zettel and press `gzo` you'll navigate to that.
  6. `gzl` will insert a link to the previous zettel you visited. `gzL` will do the same but with a folgezettel.
  7. To go back after editing another zettel type `gzu`.
  8. Typing `gzu` repeatedly multiple times will cycle between the two last visited zettels.
  9. If you want to go back multiple times in the history of visited zettels, use `gzU` (and `gzP` will go forward).
 10. To create a new blank zettel, type `gzn`.
 11. If you type `gzN` you will create a new zettel using the current word under the cursor as its title. If you're in visual selection mode `gzN` will instead use the selected text (only the first line if there are more than one selected). `gzN` will always replace the selected text or current word with a link to the newly-created zettel.
 12. `gzs` works like `gzz`, but instead it searches the content of the zettels, not only the title. For this it calls the external command `ag`.
