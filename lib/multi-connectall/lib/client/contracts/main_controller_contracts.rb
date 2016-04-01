module MainControllerContracts
  class MainControllerContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.invariant(window)
    if window.game_state_model == nil then raise MainControllerContractError.new("window requires a game state model") end
    if window.controllers[:menu] == nil then raise MainControllerContractError.new("window requires a menu controller") end      
    if window.controllers[:game] == nil then raise MainControllerContractError.new("window requires a game controller") end      
  end

end