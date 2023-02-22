# oatjumper

small neovim plugin to jump to the next character in a specified list of characters meant to represent word separators.

the default configuration is
```
config = {
    separators = { ' ', '_', "-", "/", "\\" },
    keymaps = {
        forward = "<C-l>",
        backward = "<C-h>",
    },
}

```

after installed with your plugin manager of choice, simply add
```
require('oatjump').setup({})
```
