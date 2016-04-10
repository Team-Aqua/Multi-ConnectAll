module Models
  class GameStateModel

    ##
    # Generic game state model for game processes.
    # Holds data for game

    attr_accessor :name, :state, :player_turn_state, :grid, :players, :game_mode, :game_type, :num_of_players,
    :game_mode_logic, :winner, :ai, :num_of_rl_players, :player_role, :turn_count, :current_universal_game_state_model

    def initialize()
      @state = :active
      @winner = nil
      @grid = GridModel.new
      @game_mode = nil
      @game_type = nil
      @game_mode_logic = nil
      @player_turn_state = 0
      @num_of_rl_players = 0
      @players = Array.new
      # @players
      @player_role = 0
      @ai = nil
      @turn_count = 0
      @name = nil # FIXME: CHANGE THIS LATER // reassoc. to player

      @last_move = nil

      @current_universal_game_state_model = nil
    end

    def setup_players_state
      @players[0] = @current_universal_game_state_model.user1_data
      @players[1] = @current_universal_game_state_model.user2_data
    end

    def load_game_state
      # @state = :active
      @winner = @current_universal_game_state_model.winner
      # @grid = GridModel.new
      # @game_mode = nil
      
      # @game_mode_logic = nil
      # @player_turn_state = 0
      # @num_of_rl_players = 0
      # @turn_count = 0
      # @name = nil # FIXME: CHANGE THIS LATER // reassoc. to player
      if @player_role == 0 and @current_universal_game_state_model.user1_state == :turn
        puts "LLAA: 1"
        @player_turn_state = 0
      end
      if @player_role == 0 and @current_universal_game_state_model.user1_state == :waiting
        @player_turn_state = 1
        puts "LLAA: 2"
      end
      if @player_role == 1 and @current_universal_game_state_model.user2_state == :turn
        @player_turn_state = 1
        puts "LLAA: 3"
      end
      if @player_role == 1 and @current_universal_game_state_model.user2_state == :waiting
        @player_turn_state = 0
        puts "LLAA: 4"
      end

      @last_move = @current_universal_game_state_model.last_move
    end

    def generate_universal_game_state
      model = Models::UniversalGameStateModel.new
      model.grid = @grid
      model.last_move = @last_move
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