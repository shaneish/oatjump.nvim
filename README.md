# oatjumper

small neovim plugin to jump to the next character in a specified list of characters meant to represent word separators.

**tl;dr** it lets u move across rows by "words" bruh

the default configuration is
```lua
config = {
    separators = { " ", "_", "-", ".", "/", "\\", "\t" },
    keymaps = {
        forward = "<C-l>",
        backward = "<C-h>",
    },
}
```

after installed with your plugin manager of choice, simply add the following to your `init.lua`
```lua
require('oatjump').setup()
```
