-- Example structure:
-- Source: lua/<mod>/*.lua
-- Tests:  tests/<mod>/*.lua
--         tests/*.lua
return {
  ['lua/*.lua|tests/*_spec.lua'] = {
    ['lua/*.lua'] = {
      alternate = {
        'tests/{}_spec.lua',
        'tests/{dirname}_spec.lua', -- module test
        'tests/{dirname|longtail}/{basename}_spec.lua',
        'tests/{dirname|longtail}_spec.lua', -- module test
      },
      type = 'source',
    },
    ['tests/*_spec.lua'] = {
      alternate = {
        -- Guess lua module name from project directory name,
        -- not always correct
        'lua/{project|basename|root}/{}.lua',
        'lua/{project|basename|root}/{}/init.lua', -- module test
        'lua/{}.lua',
        'lua/{}/init.lua', -- module test
      },
      type = 'test',
    },
  },
}
