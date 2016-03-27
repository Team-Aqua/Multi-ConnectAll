module GameLogic
  class OttoAI < AI
    attr_accessor :choose_location, :gridModel, :grid
    ##
    # OTTO AI implementation
    # 

    def initialize(model, ai_level)
      @model = model
      @gridModel = @model::grid
      @grid = @gridModel.getGrid
      @position = nil
      @ai_level = ai_level
    end

    ##
    # Chooses the location for AI position
    # Inputs: none
    # Outputs: x position

    def choose_location
      # Ai returns random depending on dificulty.
      if (@ai_level.level/7) < Random.rand()
        return get_random_value
      end
      
      # Check if AI can win.
      @position = check_vertical(2, 1)
      if @position != nil
        return  @position
      end
      
      @position = check_horizontal(2, 1)
      if @position != nil
        return  @position
      end
      
      @position = check_diagonal(2, 1)
      if @position != nil
        return  @position
      end
      
      # Check if Player can win.
      @position = check_vertical(1, 2)
      if @position != nil
        return  @position
      end
      
      @position = check_horizontal(1, 2)
      if @position != nil
        return  @position
      end
      
      @position = check_diagonal(1, 2)
      if @position != nil
        return  @position
      end
      
      # No Better Choice
      return get_random_value
    end

    def get_random_value()
      rando = Random.new
      return rando.rand(1..8)
    end

    def check_vertical(player1Number, player2Number)
      (0..7).each {|x|
        y = @gridModel.column_depth(x+1)
        if y <= 5
          if @grid[y][x] == player2Number and @grid[y+1][x] == player2Number and @grid[y+2][x] == player1Number
            return x+1
          end
        end
      }
      
      return nil
    end

    def check_horizontal(player1Number, player2Number)
      (0..7).each {|x|
        y = @gridModel.column_depth(x+1) - 1
        if x < 5
          if @grid[y][x+1] == player2Number and @grid[y][x+2] == player2Number and @grid[y][x+3] == player1Number
            return x+1
          end
        end
        
        if x < 6 and x > 0
          if @grid[y][x-1] == player1Number and @grid[y][x+1] == player2Number and @grid[y][x+2] == player1Number
            return x+1
          end
        end
        
        if x < 7 and x > 1
          if @grid[y][x-2] == player1Number and @grid[y][x-1] == player2Number and @grid[y][x+1] == player1Number
            return x+1
          end
        end
        
        if x > 2
          if @grid[y][x-3] == player1Number and @grid[y][x-2] == player2Number and @grid[y][x-1] == player2Number
            return x+1
          end
        end
      }
      
      return nil
    end

    def check_diagonal(player1Number, player2Number)
      (0..7).each {|x|
        y = @gridModel.column_depth(x+1)
        
        if y > 3 and x < 5
          if @grid[y - 2][x + 1] == player2Number and @grid[y - 3][x + 2] == player2Number and @grid[y - 4][x + 3] == player1Number
            return x+1
          end
        end
        
        if y < 6 and x < 5
          if @grid[y][x + 1] == player2Number and @grid[y + 1][x + 2] == player2Number and @grid[y + 2][x + 3] == player1Number
            return x+1
          end
        end
        
        if y > 2 and y < 8 and x < 6 and x > 0
          if @grid[y][x - 1] == player1Number and @grid[y - 2][x + 1] == player2Number and @grid[y - 3][x + 2] == player1Number
            return x+1
          end
        end
        
        if y > 1 and y < 7 and x < 6 and x > 1
          if @grid[y - 2][x - 1] == player1Number and @grid[y][x + 1] == player2Number and @grid[y + 1][x + 2] == player1Number
            return x+1
          end
        end
        
        if y > 1 and y < 7 and x < 7 and x > 1
          if @grid[y + 1][x - 2] == player1Number and @grid[y][x - 1] == player2Number and @grid[y - 2][x + 1] == player1Number
            return x+1
          end
        end
        
        if y > 2 and y < 8 and x < 7 and x > 1
          if @grid[y - 3][x - 2] == player1Number and @grid[y - 2][x - 1] == player2Number and @grid[y][x + 1] == player1Number
            return x+1
          end
        end
        
        if y <= 5 and x >= 3
          if @grid[y + 2][x - 3] == player1Number and @grid[y + 1][x - 2] == player2Number and @grid[y][x - 1] == player2Number
            return x+1
          end
        end
        
        if y > 3 and x >= 3
          if @grid[y - 4][x - 3] == player1Number and @grid[y - 3][x - 2] == player2Number and @grid[y-2][x - 1] == player2Number
            return x+1
          end
        end
      }
      
      return nil
    end

  end
end
