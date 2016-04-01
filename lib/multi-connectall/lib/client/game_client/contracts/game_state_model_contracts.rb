module GameStateModelContracts
  class GameStateModelContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.invariant(model)
    if model.state == :won and model.winner == nil then raise GameStateModelContractError.new("Game State won, but no winner declared") end
    if model.grid == nil then raise GameStateModelContractError.new("No grid.") end

    if model.state != :creation and model.game_mode == nil then raise GameStateModelContractError.new("Active game requires game mode") end
    if model.state != :creation and model.game_type == nil then raise GameStateModelContractError.new("Active game requires game type") end
    if model.state != :creation and model.game_mode_logic == nil then raise GameStateModelContractError.new("Active game requires game logic") end

    if model.player_turn_state + 1 > model.players.count then raise GameStateModelContractError.new("turn state larger than player num") end
    if model.player_turn_state  <  0 then raise GameStateModelContractError.new("Illegal turn state: Must be greater or equal to 0") end
  end
end