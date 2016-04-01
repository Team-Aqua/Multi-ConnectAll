module GameLogic
  class OttoRules < Rules
    attr_accessor :game_state_model, :grid

    ## 
    # Game rules for classic mode
    # Win condition: correct tile placement for player (OTTO/TOOT), in any space.
    # Dev: bitboard interaction for CPU

    def initialize(game_state_model)
      @game_state_model = game_state_model
      @grid = @game_state_model::grid.getGrid
      @winner = nil
    end

    ## 
    # Checks if player has won for any vertical
    # Inputs: none
    # Outputs: boolean

    def check_vertical
      RulesContracts.otto_model(@game_state_model)
      (0..7).each { |y|
        (0..7).each { |x|
          if y < 5 and @grid[y][x] == 2
            if @grid[y + 1][x] == 1 and @grid[y + 2][x] == 1 and @grid[y + 3][x] == 2
              @winner = 1
              return true
            end
          elsif y < 5 and @grid[y][x] == 1
            if @grid[y + 1][x] == 2 and @grid[y + 2][x] == 2 and @grid[y + 3][x] == 1
              @winner = 0
              return true
            end
          end  
        }
      }
      return false
    end

    ## 
    # Checks if player has won for any horizontal
    # Inputs: none
    # Outputs: boolean

    def check_horizontal
      RulesContracts.otto_model(@game_state_model)
      (0..7).each { |y|
        (0..7).each { |x|
          if x < 5 and @grid[y][x] == 2
            if @grid[y][x + 1] == 1 and @grid[y][x + 2] == 1 and @grid[y][x + 3] == 2
              @winner = 1
              return true
            end
          elsif x < 5 and @grid[y][x] == 1
            if @grid[y][x + 1] == 2 and @grid[y][x + 2] == 2 and @grid[y][x + 3] == 1
              @winner = 0
              return true
            end
          end   
        }
      }
      return false
    end

    ## 
    # Checks if player has won for any diagonal
    # Inputs: none
    # Outputs: boolean

    def check_diagonal
      RulesContracts.otto_model(@game_state_model)
      (0..7).each { |y|
        (0..7).each { |x|
          if x <= 4 and y <= 4 
            
            if @grid[y][x] == 2 and @grid[y + 1][x + 1] == 1 and @grid[y + 2][x + 2] == 1 and @grid[y + 3][x + 3] == 2
              @winner = 1
              return true
            elsif @grid[y][x] == 1 and @grid[y + 1][x + 1] == 2 and @grid[y + 2][x + 2] == 2 and @grid[y + 3][x + 3] == 1
              @winner = 0
              return true
            end 

         end
         if x >= 3 and y <= 4

            if @grid[y][x] == 2 and @grid[y + 1][x - 1] == 1 and @grid[y + 2][x - 2] == 1 and @grid[y + 3][x - 3] == 2
              @winner = 1
              return true
            elsif @grid[y][x] == 1 and @grid[y + 1][x - 1] == 2 and @grid[y + 2][x - 2] == 2 and @grid[y + 3][x - 3] == 1
              @winner = 0
              return true
            end

          end
          if x <= 4 and y >= 3
            
            if @grid[y][x] == 2 and @grid[y - 1][x + 1] == 1 and @grid[y - 2][x + 2] == 1 and @grid[y - 3][x + 3] == 2
              @winner = 1
              return true
            elsif @grid[y][x] == 1 and @grid[y - 1][x + 1] == 2 and @grid[y - 2][x + 2] == 2 and @grid[y - 3][x + 3] == 1
              @winner = 0
              return true
            end 

          end
          if x >= 3 and y >= 3
            
            if @grid[y][x] == 2 and @grid[y - 1][x - 1] == 1 and @grid[y - 2][x - 2] == 1 and @grid[y - 3][x - 3] == 2
              @winner = 1
              return true
            elsif @grid[y][x] == 1 and @grid[y - 1][x - 1] == 2 and @grid[y - 2][x - 2] == 2 and @grid[y - 3][x - 3] == 1
              @winner = 0
              return true
            end 
          
          end  
        }
      }
      return false
    end
  end 
end