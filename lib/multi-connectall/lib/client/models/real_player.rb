module Models
  class RealPlayer < Player

    ##
    # RealPlayer is alternate from AI 
    # Controls real user's actions, on their turn

    def initialize(player_num, player_color, name)
      super(player_num, player_color, name)
      @move = nil
    end

    ##
    # When player makes a move, return whether or not move was valid
    # Inputs: none
    # Outputs: boolean

    def make_move
      PlayerModelContracts.invariant(self)
      if @move == nil
        return false
      else
        yield @move, @player_num, @player_color, 0.0
        @move = nil
        return true
      end
    end

  end
end