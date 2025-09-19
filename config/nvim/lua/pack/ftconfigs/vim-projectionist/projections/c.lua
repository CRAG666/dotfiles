return {
  ['*.{c,h}'] = {
    ['*.c'] = {
      alternate = '{}.h',
      type = 'source',
    },
    ['*.h'] = {
      alternate = '{}.c',
      type = 'header',
    },
  },
}
