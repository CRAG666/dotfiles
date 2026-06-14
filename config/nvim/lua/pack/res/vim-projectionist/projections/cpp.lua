return {
  ['*.{cc,cpp,h,hh,hpp}'] = {
    ['*.h'] = {
      -- Also add '{}.c' here because all '.h' files are recognized as cpp
      -- header in nvim
      alternate = { '{}.cpp', '{}.cc', '{}.c' },
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
