module Models
  class AIPlayer < Player
    attr_accessor :ai_level
    
    ## 
    # Generic AI implementation for player
    # Generates using same player structure, but references AI for decisions

    def initialize(player_num, player_color, ai, name)
      super(player_num, player_color, name)
      @ai = ai
    end

    def make_move
      PlayerModelContracts.invariant(self)
      PlayerModelContracts.has_ai(self)
      move = @ai.choose_location
      yield move, @player_num, @player_color, 1.0
      @move = nil
      return true
    end


  end
end