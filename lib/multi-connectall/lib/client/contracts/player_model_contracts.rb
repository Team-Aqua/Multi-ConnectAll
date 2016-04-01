module PlayerModelContracts
  class PlayerModelContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.invariant(model)
    if model.player_num < 0 then raise PlayerModelContractError.new("player_num must be positive") end
    if model.score < 0 then raise PlayerModelContractError.new("players score must be positive") end
    if model.player_num == nil then raise PlayerModelContractError.new("players requires an assigned number") end
    if model.player_color == nil then raise PlayerModelContractError.new("player requires an assigned color") end
  end

  def self.has_ai(model)
    if model.ai == nil then raise PlayerModelContractError.new("Player requires an AI assignment") end
  end
  
end