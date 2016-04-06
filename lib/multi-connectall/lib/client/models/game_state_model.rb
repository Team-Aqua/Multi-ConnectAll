module Models
  class GameStateModel

    ##
    # Generic game state model for game processes.
    # Holds data for game

    attr_accessor :name, :state, :player_turn_state, :grid, :players, :game_mode, :game_type, :num_of_players, :game_mode_logic, :winner, :ai, :num_of_rl_players, :player_role, :turn_count

    def initialize()
      @state = :active
      @winner = nil
      @grid = GridModel.new
      @game_mode = nil
      @game_type = nil
      @game_mode_logic = nil
      @player_turn_state = 0
      @num_of_rl_players = 0
      @players = []
      @player_role = 0
      @ai = nil
      @turn_count = 0
      @name = nil # FIXME: CHANGE THIS LATER // reassoc. to player
    end

    def generate_universal_game_state
      model = Models::UniversalGameStateModel.new
      return model
    end

    ##
    # Changes turn state depending on number of players
    # Inputs: none
    # Outputs: none

    def toggle_player_turn_state
      GameStateModelContracts.invariant(self)
      @player_turn_state = (@player_turn_state + 1) % @players.count
      GameStateModelContracts.invariant(self)
    end

  end
end