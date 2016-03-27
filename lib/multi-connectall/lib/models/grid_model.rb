module Models
  class GridModel

    ##
    # Grid model for in-game processing

    attr_accessor :setValue, :getValue, :column_depth, :grid, :x, :y

    def initialize(x: 7, y: 7)
      @x = x
      @y = y
      @grid = generate_grid
      GridModelContracts.post_generate_grid(self)
      GridModelContracts.invariant(self)
    end

    ##
    # Generates an empty grid for game initialization
    # Inputs: none
    # Outputs: empty grid

    def generate_grid
      GridModelContracts.pre_generate_grid(self)
      grid = []
      (0..@y).each { |y|
        row = []
        (0..@x).each { |x|
          row.push(0)
        }
        grid.push(row)
      }
      return grid
    end

    ## 
    # Returns grid
    # Inputs: none
    # Outputs: current grid

    def getGrid
      @grid
    end

    ##
    # Grabs the column depth of current column
    # Input: column value
    # Output: last empty row in column

    def column_depth(col)
      GridModelContracts.pre_column_depth(self, col-1)
      (0..@y).each { |row|
        if @grid[row][col-1] > 0
          GridModelContracts.post_column_depth(self, @grid[row][col-1])
          return row
        end
      }
      return @y+1
    end

    ##
    # Gets position value
    # Used for grid position calculations
    # Inputs: x, y position
    # Outputs: value

    def getValue(x, y)
      GridModelContracts.pre_get_value(self, x, y)
      GridModelContracts.post_get_value(self, @grid[y][x])
      return @grid[y][x]
    end

    ## 
    # Sets the value at the current position
    # Used for grid position modifiers
    # Helper for add_tile
    # Inputs: x, y position, value
    # Outputs: none

    def setValue(x, y, val)
      GridModelContracts.pre_set_value(self, x, y, val)
      @grid[y][x] = val
      GridModelContracts.post_set_value(self)
    end

    ##
    # Adds a tile at the given row for the player's turn
    # Inputs: x, player
    # Outputs: none

    def add_tile(x, player_num)
      GridModelContracts.pre_add_tile(self, x, player_num)
      for y in (7).downto(0)
        if getValue(x-1, y) == 0
          setValue(x-1, y, player_num)
          return
        end
      end
      GridModelContracts.post_add_tile(self)
    end

    ## 
    # Resets grid
    # Used for 'reset' game state.
    # Inputs: none
    # Outputs: none

    def reset
      @grid = generate_grid
      GridModelContracts.post_reset(self)
    end

    ##
    # Prints grid to console
    # Used for debugging purposes
    # Inputs: none
    # Outputs: none

    def print_grid
      puts ""
      puts ""
      puts ""
      puts ""
      puts ""
      @grid.each do |row|
        print row
        puts ""
      end
    end

  end
end