local Job = require('plenary.job')

local conf = require('telescope.config').values
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')

local flatten = vim.tbl_flatten

local minimum_grep_characters = 2
local minimum_files_characters = 0

local use_highlighter = true

return require('telescope').register_extension {
  setup = function(user_conf)
    if user_conf.minimum_grep_characters then
      minimum_grep_characters = user_conf.minimum_grep_characters
    end

    if user_conf.minimum_files_characters then
      minimum_files_characters = user_conf.minimum_files_characters
    end

    if user_conf.use_highlighter ~= nil then
      use_highlighter = user_conf.use_highlighter
    end
  end,

  exports = {
    grep = function(opts)
      opts = opts or {}

      local live_grepper = finders._new {
        fn_command = function(_, prompt)
          if not prompt or prompt == "" then
            return nil
          end

          if #prompt < minimum_grep_characters then
            return nil
          end

          local rg_args = flatten { conf.vimgrep_arguments, "." }
          table.remove(rg_args, 1)

          return {
            writer = Job:new {
              command = 'rg',
              args = rg_args,
            },

            command = 'fzf',
            args = {'--filter', prompt},
          }
        end,

        entry_maker = make_entry.gen_from_vimgrep(opts),
      }

      pickers.new(opts, {
        prompt_title = 'Fzf Writer: Grep',
        finder = live_grepper,
        previewer = conf.grep_previewer(opts),
        sorter = use_highlighter and sorters.highlighter_only(opts) or nil,
      }):find()
    end,

    staged_grep = function(opts)
      opts = opts or {}

      local fzf_separator = opts.fzf_separator or "|"

      local live_grepper = finders._new {
        fn_command = function(_, prompt)
          if #prompt < minimum_grep_characters then
            return nil
          end

          local rg_prompt, fzf_prompt
          if string.find(prompt, fzf_separator, 1, true) then
            rg_prompt  = string.sub(prompt, 1, string.find(prompt, fzf_separator, 1, true) - 1)
            fzf_prompt = string.sub(prompt, string.find(prompt, fzf_separator, 1, true) + #fzf_separator, #prompt)
          else
            rg_prompt = prompt
            fzf_prompt = ""
          end

          local rg_args = flatten { conf.vimgrep_arguments, rg_prompt, "." }
          table.remove(rg_args, 1)

          return {
            writer = Job:new {
              command = 'rg',
              args = rg_args,
            },

            command = 'fzf',
            args = {'--filter', fzf_prompt},
          }
        end,

        entry_maker = make_entry.gen_from_vimgrep(opts),
      }

      pickers.new(opts, {
        prompt_title = 'Fzf Writer: Grep',
        finder = live_grepper,
        previewer = conf.grep_previewer(opts),
        sorter = use_highlighter and sorters.highlighter_only(opts) or nil,
      }):find()
    end,

    files = function(opts)
      opts = opts or {}

      local _ = make_entry.gen_from_vimgrep(opts)
      local live_grepper = finders._new {
        fn_command = function(self, prompt)
          if #prompt < minimum_files_characters then
            return nil
          end

          return {
            writer = Job:new {
              command = 'rg',
              args = {"--files"},
            },

            command = 'fzf',
            args = {'--filter', prompt}
          }
        end,

        entry_maker = make_entry.gen_from_file(opts),
      }

      pickers.new(opts, {
        prompt_title = 'Fzf Writer: Files',
        finder = live_grepper,
        previewer = conf.grep_previewer(opts),
        sorter = use_highlighter and sorters.highlighter_only(opts) or nil ,
      }):find()
    end,
  },
}
