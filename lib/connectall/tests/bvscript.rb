require_relative "ancillaries/abstractInterface"
require_relative "controllers/game_logic/rules"
require_relative "controllers/game_logic/classic_rules"
require_relative "controllers/game_logic/otto_rules"
require_relative "models/game_state_model"
require_relative "models/grid_model"

model = Models::GameStateModel.new
rules = GameLogic::ClassicRules.new(model)
rulesOtto = GameLogic::OttoRules.new(model)

##
# Script for generating tests for grid win conditions. 
# Offers more verbose options.

binary_grid = [ # extra weight for 0's
      [ [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,1] ],
      [ [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,1] ],
      [ [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,1] ],
      [ [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,1] ],
      [ [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,1] ],
      [ [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,1] ],
      [ [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,1] ],
      [ [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1], [0,1] ]
    ]

trinary_grid = [ # extra weight for 0's
      [ [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,1,2] ],
      [ [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,1,2] ],
      [ [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,1,2] ],
      [ [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,1,2] ],
      [ [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,1,2] ],
      [ [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,1,2] ],
      [ [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,1,2] ],
      [ [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,0,1,2], [0,1,2] ]
    ]

for i in 0..1000 # how many iterations performed - 3000 for verbose_tests
  @grid = []
  (0..7).each { |y|
    row = []
    (0..7).each { |x|
      row.push(binary_grid[y][x].sample);
    }
    @grid.push(row)
  }

  puts "    rules.grid = ["
  @grid.each do |row|
    print "      "
    print row
    puts ","
  end
  puts "    ]"

  rules.grid = @grid
  if rules.win
    puts "    assert rules.win"
  else 
    puts "    assert !rules.win"
  end
  puts ""
end

for i in 0..1000 # how many iterations performed - 3000 for verbose_tests
  @grid = []
  (0..7).each { |y|
    row = []
    (0..7).each { |x|
      row.push(trinary_grid[y][x].sample);
    }
    @grid.push(row)
  }

  puts "    rulesOtto.grid = ["
  @grid.each do |row|
    print "      "
    print row
    puts ","
  end
  puts "    ]"

  rulesOtto.grid = @grid
  if rulesOtto.win
    puts "    assert rulesOtto.win"
  else 
    puts "    assert !rulesOtto.win"
  end
  puts ""
end
