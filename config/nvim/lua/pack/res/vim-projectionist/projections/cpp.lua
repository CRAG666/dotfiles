return {
  ['*.{cc,cpp,h,hh,hpp}'] = {
    ['*.h'] = {
      alternate = { '{}.cpp', '{}.cc' },
      type = 'header',
    },
    ['*.cc'] = {
      alternate = { '{}.hh', '{}.h' },
      type = 'source',
    },
    ['*.hh'] = {
      alternate = '{}.cc',
      type = 'header',
    },
    ['*.cpp'] = {
      alternate = { '{}.hpp', '{}.h' },
      type = 'source',
    },
    ['*.hpp'] = {
      alternate = '{}.cpp',
      type = 'header',
    },
  },
}
