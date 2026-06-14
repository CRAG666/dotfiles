return {
  ['pom.xml'] = {
    ['src/test/*Test.java'] = {
      type = 'test',
      alternate = {
        'src/main/{}.java',
      },
    },
    ['src/main/*.java'] = {
      type = 'source',
      alternate = {
        'src/test/{}Test.java',
      },
    },
  },
}
