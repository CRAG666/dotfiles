local fs = require('utils.fs')

---@return string: path to the cache dir
local function get_cache_dir()
  return vim.fs.joinpath(vim.fn.stdpath('cache') --[[@as string]], 'jupytext')
end

---@param ipynb string path to the ipynb file
---@return string: path to the dir
local function get_output_basename(ipynb)
  return vim.fs.joinpath(
    get_cache_dir(),
    (vim.fn.fnamemodify(ipynb, ':r'):gsub('%%', '%%%%'):gsub('/', '%%'))
  )
end

---@param ipynb string path to the ipynb file
---@return string: path to the markdown file coorresponding to the ipynb
local function get_md(ipynb)
  return get_output_basename(ipynb) .. '.md'
end

---@param ipynb string path to the ipynb file
---@return string: path to the sha256sum of the ipynb file
local function get_sha(ipynb)
  return get_output_basename(ipynb) .. '.sha'
end

---Write sha256sum for the ipynb file
---@param ipynb string path to the ipynb file
---@return nil
local function write_sha(ipynb)
  if vim.fn.executable('sha256sum') == 0 or fs.is_empty(ipynb) then
    return
  end
  vim.system({ 'sha256sum', ipynb }, {}, function(obj)
    fs.write_file(get_sha(ipynb), vim.trim(obj.stdout))
  end)
end

---Callback for BufWriteCmd and FileWriteCmd event on an ipynb buffer
---@param args table
---@return nil
local function write_cb(args)
  local fname = vim.fn.fnamemodify(args.match, ':p')
  if fname == vim.api.nvim_buf_get_name(args.buf) then
    vim.bo[args.buf].mod = false
  end

  -- Write destination is a markdown file, no special handling needed
  local ext = vim.fn.fnamemodify(fname, ':e')
  if ext == 'md' or ext == 'markdown' or ext == 'rmd' or ext == 'qmd' then
    vim.cmd.write({
      vim.fn.fnameescape(fname),
      mods = { silent = true },
      bang = vim.v.cmdbang == 1,
    })
    return
  end

  local md = get_md(fname)
  vim.cmd.write({
    vim.fn.fnameescape(md),
    mods = { silent = true, keepalt = true },
    bang = true,
  })
  vim.system({
    'jupytext',
    '--update',
    '--from=md',
    '--to=ipynb',
    '--output',
    fname,
    md,
  }, {}, function(obj)
    if obj.code == 0 then
      write_sha(fname)
      return
    end
    -- If error, the notebook is possibly non-existent or is empty or
    -- corrupted, try without `--update` to fix it
    vim.system(
      {
        'jupytext',
        '--from=md',
        '--to=ipynb',
        '--output',
        fname,
        md,
      },
      {},
      vim.schedule_wrap(function(obj2)
        if obj2.code == 0 then
          write_sha(fname)
          return
        end
        vim.notify(
          '[jupytext] error writing to notebook: ' .. obj2.stderr,
          vim.log.levels.ERROR
        )
      end)
    )
  end)
end

---Convert a `.ipynb` notebook buffer into a proper markdown buffer
---@param buf integer?
---@return nil
local function jupytext_convert(buf)
  buf = vim._resolve_bufnr(buf)

  -- If filetype if markdown, the buf is already converted, so early return
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].ft == 'markdown' then
    return
  end

  local ipynb = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
  local cache_dir = get_cache_dir()

  -- If jupytext is not installed, load the original buffer
  if vim.fn.executable('jupytext') == 0 then
    vim.cmd.edit(vim.fn.fnameescape(ipynb))
    vim.cmd.filetype('detect')
    return
  end

  if not vim.uv.fs_stat(cache_dir) and not vim.uv.fs_mkdir(cache_dir, 511) then
    vim.notify(
      '[jupytext] cannot create cache dir ' .. cache_dir,
      vim.log.levels.ERROR
    )
    return
  end

  local md = get_md(ipynb)
  local sha = get_sha(ipynb)

  -- Get current and previous sha256sum of the notebook file
  local sha_prev = fs.read_file(sha)
  local sha_current = vim.fn.executable('sha256sum') == 1
    and vim.trim(vim.system({ 'sha256sum', ipynb }):wait().stdout)

  -- Remove stale cache
  if not sha_prev or not sha_current or sha_prev ~= sha_current then
    vim.fn.delete(md)
  end

  -- Convert ipynb file to markdown file using jupytext
  -- Don't convert if the notebook does not exist or is empty
  if not fs.is_empty(ipynb) and not vim.uv.fs_stat(md) then
    local obj = vim
      .system({
        'jupytext',
        '--to=md',
        '--format-options',
        'notebook_metadata_filter=-all',
        '--output',
        md,
        ipynb,
      })
      :wait()

    if obj.code == 0 then
      write_sha(ipynb)
    else
      vim.schedule(function()
        vim.notify(
          '[jupytext] error converting notebook: ' .. obj.stderr,
          vim.log.levels.ERROR
        )
      end)
    end
  end

  -- Markdown file not found, load original notebook
  if not vim.uv.fs_stat(md) then
    vim.cmd.edit(vim.fn.fnameescape(ipynb))
    vim.cmd.filetype('detect')
    -- Three possible cases if the markdown file is missing:
    -- 1. the notebook does not exist (empty)
    -- 2. the notebook exists but is empty (empty)
    -- 3. the notebook is corrupted (not empty)
    --
    -- In case 1 & 2, we still want to set the current filetype to markdown
    -- and update the notebook on write using the FileWriteCmd/BufWriteCmd
    -- callback
    --
    -- In case 3, we want to load the underlying json and fix the corrupted
    -- notebook without setting the filetype and register the
    -- FileWriteCmd/BufWriteCmd callback
    if not fs.is_empty(ipynb) then
      return
    end
  else
    local undolevels
    -- Only set clear undo history on the first time loading the buffer
    -- This is to prevent losing undo history when nvim reloads the buffer
    -- from file when it detects the file has been changed outside of nvim,
    -- either by jupytext, another nvim session, or other code editors, see
    -- `:h autoread` and `:h timestamp`
    if vim.bo[buf].ft ~= 'markdown' then
      undolevels = vim.bo[buf].undolevels
      vim.bo[buf].undolevels = -1
    end
    vim.cmd.read({
      args = { vim.fn.fnameescape(md) },
      mods = { silent = true, keepalt = true },
    })
    vim.cmd.delete({
      reg = '_',
      range = { 1 },
      mods = { emsg_silent = true },
    })
    if undolevels then
      vim.bo[buf].undolevels = undolevels
    end
  end

  -- Original buffer can be deleted in the previous code after we read the
  -- markdown file, e.g. when the jupyter notebook buffer is a temporary
  -- preview buffer with 'bufhidden' set to 'delete' or 'wipe'
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  -- Setting 'buftype' to 'acwrite' to indicate that the buffer will always be
  -- written with BufWriteCmd, this also disable auto-reloading when the
  -- jupyter notebook is changed outside of nvim
  --
  -- If 'buftype' is not set, when we unfocus the current nvim session with
  -- unsaved changes in the notebook buffer, nvim saves the buffer automatically
  -- (see the autosave augroup in `lua/core/autocmds`), then write the changes
  -- to the notebook file asynchronously, resulting in a newer timestamp in the
  -- notebook file than the buffer; when we refocus the nvim session,
  -- nvim detects the newer timestamp in the notebook file and reloads the
  -- buffer from the notebook file, removing extmarks and other buffer-local
  -- settings -- which is not what we want, see `:h timestamp`, `:h autoread`
  --
  -- To avoid this we can either block until the write to the notebook is finished
  -- in BufWriteCmd/FileWriteCmd, or set 'buftype' to 'acwrite' to disable
  -- auto-reloading when the notebook file is changed outside of nvim
  vim.bo[buf].bt = 'acwrite'
  vim.bo[buf].ft = 'markdown'
  vim.api.nvim_create_autocmd({ 'BufWriteCmd', 'FileWriteCmd' }, {
    group = vim.api.nvim_create_augroup('my.jupytext.buf.' .. buf, {}),
    buffer = buf,
    callback = write_cb,
  })
end

---@param buf integer?
local function setup(buf)
  if vim.g.loaded_jupytext ~= nil then
    return
  end
  vim.g.loaded_jupytext = true

  buf = vim._resolve_bufnr(buf)
  if vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':e') == 'ipynb' then
    jupytext_convert(buf)
  end

  vim.api.nvim_create_autocmd('BufReadCmd', {
    group = vim.api.nvim_create_augroup('my.jupytext', {}),
    pattern = '*.ipynb',
    callback = function(args)
      jupytext_convert(args.buf)
    end,
  })
end

return { setup = setup }
