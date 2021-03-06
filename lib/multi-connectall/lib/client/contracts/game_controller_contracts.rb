module GameControllerContracts
  class GameControllerContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.invariant(controller)
    if controller.window == nil then raise GameControllerContractError.new("GameCtrl must have a window") end
    if controller.game_state_model == nil then raise GameControllerContractError.new("GameCtrl must have a model") end
    if controller.window == nil then raise GameControllerContractError.new("GameCtrl must have a view") end
    # ensure that there is a client to communicate with
  end

  def self.pre_send_sync_message(controller)
    # ensure that there is a client to communicate with
  end

  def self.pre_read_message(controller)
    # ensure that there is a client to communicate with
  end

  def self.pre_toggle_multiplayer_controls(controller)
    # ensure that there is a player state to check toggles
  end
  
  def self.post_reset_match(controller)
    if controller.game_state_model.state != :active then raise GameControllerContractError.new("Game State corrupted") end
  end

  def self.pre_button_click(controller, x)
    if x > controller.game_state_model.grid.x + 1 or x < 0 then raise GameControllerContractError.new("Button click does not correspond to a column on the grid") end
  end
end