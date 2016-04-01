module RulesContracts
  class RulesContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  # handles rules, otto_rules, classic_rules
  def self.invariant(game_state_model)
    if game_state_model.game_mode_logic == nil then raise RulesContractError.new("Game Requires Logical Rules") end
    if game_state_model.state == nil then raise RulesContractError.new("Game state should not be nil") end   
    if game_state_model.grid == nil then raise RulesContractError.new("Grid should not be nil") end   
    if game_state_model.player_turn_state == nil or game_state_model.player_turn_state > 2 or game_state_model.player_turn_state < 0 then raise RulesContractError.new("Bad number of players") end  
    if game_state_model.players.count <= 0 then raise RulesContractError.new("Bad number of players") end
  end

  def self.otto_model(game_state_model)
    if game_state_model::game_type != :otto then raise RulesContractError.new("Invalid game mode selected.") end
  end

  def self.classic_model(game_state_model)
    if game_state_model::game_type != :classic then raise RulesContractError.new("Invalid game mode selected.") end
  end

end