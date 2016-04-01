module MenuControllerContracts
  class MenuControllerContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.invariant(ctrl)
    if ctrl.window == nil then raise MenuControllerContractError.new("Controller requires window") end  
    if ctrl.views == nil then raise MenuControllerContractError.new("Controller requires view") end  
    if ctrl.game_state_model == nil then raise MenuControllerContractError.new("Controller requires game model") end  
  end

end 