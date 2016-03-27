module GameLogic
  class Rules

    ## 
    # Abstract implementation for rules
    # Implements generic checks and win conditions

    include AbstractInterface

    ##
    # Checks if a player has won given rules, or has tied
    # Inputs: none
    # Outputs: none

    def check_for_winner
      RulesContracts.invariant(@game_state_model)

      @grid = @game_state_model::grid.getGrid
      if win
        @game_state_model::state = :win
        @game_state_model::winner = @winner
      elsif tie
         @game_state_model::state = :tie
      else
        @game_state_model::state = :active
      end
      
      RulesContracts.invariant(@game_state_model)
    end

    ##
    # Checks if a player has won with respect to vertical, horizontal, diagonal wins
    # Specific implementation of all three, in their respective classes (otto_rules, classic_rules)
    # Inputs: none
    # Outputs: boolean

    def win
      RulesContracts.invariant(@game_state_model)
      # puts "vertical: #{check_vertical} || horizontal: #{check_horizontal} || diagonal: #{check_diagonal}"
      return ( check_vertical || check_horizontal || check_diagonal )
    end

    ##
    # Given the grid model, checks if every space is filled
    # If so, then the board has reached a 'tie' state and no winners are declared.
    # Inputs: none
    # Outputs: boolean

    def tie
      RulesContracts.invariant(@game_state_model)
      (0..7).each { |col|
         if (@game_state_model::grid.column_depth(col) > 0)
            return false
         end
      }
      return true
    end
  end
end