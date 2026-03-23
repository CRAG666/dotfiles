local key = require('utils.keymap')

local function load()
  vim.opt.runtimepath:prepend(vim.fn.expand('~/Git/code_runner.nvim'))
  local preview_cmd = '/bin/zathura'
  require('code_runner').setup({
    mode = 'better_term',
    better_term = {
      number = 0,
    },
    filetype = {
      v = 'v run',
      tex = function(...)
        local tectonic = require('code_runner.hooks.tectonic')
        require('code_runner.hooks.ui').select({
          Project = function()
            tectonic.build()
          end,
          ['Project + logs'] = function()
            tectonic.build('--synctex --keep-logs')
          end,
          Single = function()
            tectonic.single('--synctex --keep-logs -Zsearch-path=/latex')
          end,
        })
      end,
      quarto = function(...)
        local quarto = require('code_runner.hooks.utils').create_job_runner({
          label = 'Quarto',
          stop_command = 'QuartoStop',
        })
        local root = vim.fn.expand('%:p')
        quarto.start(
          ('quarto preview %s --no-browser --port 4444'):format(root)
        )
        vim.defer_fn(function()
          vim.fn.jobstart(
            { 'xdg-open', 'http://localhost:4444' },
            { detach = true }
          )
        end, 10000)
      end,
      markdown = function(...)
        local hr_preview_pdf = require('code_runner.hooks.preview_pdf')
        require('code_runner.hooks.ui').select({
          Latex = function()
            hr_preview_pdf.run({
              command = 'pandoc',
              args = { '$fileName', '-o', '$tmpFile', '-t pdf' },
              preview_cmd = preview_cmd,
            })
          end,
          Beamer = function()
            hr_preview_pdf.run({
              command = 'pandoc',
              args = { '$fileName', '-o', '$tmpFile', '-t beamer' },
              preview_cmd = preview_cmd,
            })
          end,
          Eisvogel = function()
            hr_preview_pdf.run({
              command = 'bash',
              args = { './build.sh' },
              preview_cmd = preview_cmd,
              overwrite_output = '.',
            })
          end,
        })
      end,
      c = function(...)
        local c_base = {
          'cd $dir &&',
          'gcc $fileName -o',
          '/tmp/$fileNameWithoutExt',
        }
        local c_exec = {
          '&& /tmp/$fileNameWithoutExt &&',
          'rm /tmp/$fileNameWithoutExt',
        }
        vim.ui.input({ prompt = 'Add more args:' }, function(input)
          c_base[4] = input
          require('code_runner.commands').run_from_fn(
            vim.list_extend(c_base, c_exec)
          )
        end)
      end,
      cpp = function(...)
        local cpp_base = {
          [[cd '$dir' &&]],
          'g++ $fileName -o',
          '/tmp/$fileNameWithoutExt',
        }
        local cpp_exec = {
          '&& /tmp/$fileNameWithoutExt &&',
          'rm /tmp/$fileNameWithoutExt',
        }
        vim.ui.input({ prompt = 'Add more args:' }, function(input)
          cpp_base[4] = input
          vim.print(vim.tbl_extend('force', cpp_base, cpp_exec))
          require('code_runner.commands').run_from_fn(
            vim.list_extend(cpp_base, cpp_exec)
          )
        end)
      end,
      python = "python -u '$dir/$fileName'",
      sh = 'bash',
      typescriptreact = 'yarn dev$end',
    },
    project_path = vim.fn.expand('~/.config/nvim/project_manager.json'),
  })
  require('plugin.term').setup()
end

key.map_lazy('code_runner', load, 'n', '<leader>e', function()
  require('code_runner').run_code()
end, { desc = 'Execute code' })
