local M = {}
local un = require('utils.snippets.nodes')
local us = require('utils.snippets.snips')
local ls = require('luasnip')
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node

M.c = require('snippets.c').syntax

M.snippets = {
  -- Macros
  us.sn({ trig = 'ts', priority = 999 }, t('TILE_SIZE')),
  us.sn({ trig = 'dts' }, {
    t('#define TILE_SIZE '),
    i(0, '16'),
  }),
  -- Indexes
  us.sn({ trig = 'bx' }, t('blockIdx.x')),
  us.sn({ trig = 'by' }, t('blockIdy.y')),
  us.sn({ trig = 'bz' }, t('blockIdz.z')),
  us.sn({ trig = 'tx' }, t('threadIdx.x')),
  us.sn({ trig = 'ty' }, t('threadIdy.y')),
  us.sn({ trig = 'tz' }, t('threadIdz.z')),
  us.sn(
    {
      trig = 'idx1',
      dscr = 'Indexes for 1D grid',
    },
    un.fmtd(
      [[
      const int bw = blockDim.x;
      const int bx = blockIdx.x;
      const int tx = threadIdx.x;
    ]],
      {}
    )
  ),
  us.sn(
    {
      trig = 'idx2',
      dscr = 'Indexes for 2D grid',
    },
    un.fmtd(
      [[
      const int bw = blockDim.x;
      const int bh = blockDim.y;
      const int bx = blockIdx.x;
      const int by = blockIdx.y;
      const int tx = threadIdx.x;
      const int ty = threadIdx.y;
    ]],
      {}
    )
  ),
  us.sn(
    {
      trig = 'idx3',
      dscr = 'Indexes for 3D grid',
    },
    un.fmtd(
      [[
      const int bw = blockDim.x;
      const int bh = blockDim.y;
      const int bd = blockDim.z;
      const int bx = blockIdx.x;
      const int by = blockIdx.y;
      const int bz = blockIdx.z;
      const int tx = threadIdx.x;
      const int ty = threadIdx.y;
      const int tz = threadIdx.z;
    ]],
      {}
    )
  ),
  -- Cuda API functions
  us.sn(
    { trig = 'cma', dscr = 'call cudaMalloc()' },
    un.fmtad('cudaMalloc((void **) &<dev_ptr>, <len> * sizeof(<dtype>));', {
      dev_ptr = i(1, 'dev_ptr'),
      len = i(2, 'len'),
      dtype = i(3, 'float'),
    })
  ),
  us.sn(
    { trig = 'cmc', dscr = 'call cudaMemcpy()' },
    un.fmtad('cudaMemcpy(<dest>, <src>, <len> * sizeof(<dtype>), <kind>);', {
      dest = i(1, 'dest'),
      src = i(2, 'src'),
      len = i(3, 'len'),
      dtype = i(4, 'float'),
      kind = c(5, {
        i(nil, 'cudaMemcpyHostToDevice'),
        i(nil, 'cudaMemcpyDeviceToHost'),
      }),
    })
  ),
  us.sn(
    { trig = 'cmcs', dscr = 'call cudaMemcpyToSymbol()' },
    un.fmtad(
      'cudaMemcpyToSymbol(<dest>, <src>, <len> * sizeof(<dtype>), <offset>, <kind>);',
      {
        dest = i(1, 'dest'),
        src = i(2, 'src'),
        len = i(3, 'len'),
        dtype = i(4, 'float'),
        offset = i(5, '0'),
        kind = c(6, {
          i(nil, 'cudaMemcpyHostToDevice'),
          i(nil, 'cudaMemcpyDeviceToHost'),
        }),
      }
    )
  ),
  us.msn({
    { trig = 'cmf' },
    { trig = 'cf' },
    common = { dscr = 'call cudaFree()' },
  }, un.fmtad('cudaFree(<ptr>);', { ptr = i(1) })),
  -- `dim3` structure
  us.sn(
    { trig = 'dim3' },
    un.fmtad('dim3 <name>(<x>, <y>, <z>);', {
      name = c(1, {
        i(nil, 'dimGrid'),
        i(nil, 'dimBlock'),
      }),
      x = i(2),
      y = i(3),
      z = i(4),
    })
  ),
  us.sn(
    {
      trig = 'kc',
      dscr = 'Kernel call',
    },
    un.fmtd('[kernek_fn]<<<[dim_grid], [dim_blk]>>>([args]);', {
      kernek_fn = i(1, 'KernelFunction'),
      dim_grid = i(2, 'dimGrid'),
      dim_blk = i(3, 'dimBlock'),
      args = i(4),
    }, { delimiters = '[]' })
  ),
}

return M
