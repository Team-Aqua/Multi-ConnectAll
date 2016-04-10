module Models
  class Player

    ##
    # Model for player

    include AbstractInterface
    attr_accessor :player_num, :player_color, :player_type, :score, :set_move, :make_move, :name, :ai, :move

    def initialize(player_num, player_color, name)
      @player_num  = player_num
      @player_color = player_color
      @name = name
      @score = 0
      @move = nil
      @ai = nil
    end

    ##
    # Increments win
    # Used for winkeeping after game ends
    # Inputs: none
    # Outputs: none

    def increment_win_score
      PlayerModelContracts.invariant(self)
      @score = @score + 1
    end

    ##
    # Decides move for player
    # Used for game processes
    # Inputs: none
    # Outputs: none

    def set_move(x)
      PlayerModelContracts.invariant(self)
      @move = x
    end

  end
end