# fzf_writer.nvim

Incorporating fzf into telescope using plenary's job writer functionality.

## Requires

`fzf` and `rg` to both be installed.

More can be added later.

## Exports

`fzf_writer.grep`
- `require('telescope').extensions.fzf_writer.grep()`
- similar to `live_grep`, but more async-ish

`fzf_writer.files`
- `require('telescope').extensions.fzf_writer.files()`
- similar to `find_files`, but more async-ish

## Configuration

```lua
require('telescope').setup {
    extensions = {
        fzf_writer = {
            minimum_grep_characters = 2,
            minimum_files_characters = 2,
        }
    }
}
```

## TODO

Could probably still make this more async by doing a better job with some of the matching strategy / filtering and maybe not using rg for files. Idk, it was just a thought so I made this.
