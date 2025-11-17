return {
  ['*.go'] = {
    ['*.go'] = {
      alternate = '{}_test.go',
      type = 'source',
    },
    ['*_test.go'] = {
      alternate = '{}.go',
      type = 'test',
    },
  },
}
