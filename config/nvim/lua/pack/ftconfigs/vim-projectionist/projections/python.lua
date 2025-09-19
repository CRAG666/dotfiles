return {
  ['pytest.ini|Pipfile|pyproject.toml|requirements.txt|setup.cfg|setup.py|tox.ini|*.py'] = {
    ['*.py'] = {
      alternate = {
        -- Test file in `tests` subdir
        'tests/test_{basename}.py',
        'tests/{dirname}/test_{basename}.py',
        -- Test file in parallel `test` dir, e.g.
        -- Source: <proj_name>/<mod>/<submod>/*.py
        -- Tests:  tests/<mod>/<submod>/test_*.py
        'tests/{dirname|tail}/test_{basename}.py',
        -- Test file for module, e.g.
        -- Source: <mod>/<submod>/*.py
        -- Tests:  <mod>/test_<submod>.py
        --         tests/<mod>/test_<submod>.py
        'tests/{dirname|dirname}/test_{dirname|basename}.py',
        'tests/{dirname|tail|dirname}/test_{dirname|basename}.py',
      },
      type = 'source',
    },
    ['tests/**/test_*.py'] = {
      alternate = {
        '{}.py', -- source file in parent dir
        '{}/__init__.py', -- module test
        -- Source file in parallel `src` dir
        'src/{}.py',
        'src/{}/__init__.py',
        -- Guess source file containing dir (project dir)
        -- using base of project fullpath, not always correct.
        -- Required struct:
        -- Source: [PROJECT]/<proj_name>/<mod>/<submod>/*.py
        -- Tests:  [PROJECT]/tests/<mod>/<submod>/test_*.py
        -- where [PROJECT] ends with <proj_name>
        '{project|basename}/{}.py',
        '{project|basename}/{}/__init__.py',
      },
      type = 'test',
    },
  },
}
