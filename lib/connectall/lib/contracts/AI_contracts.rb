module AIModelContracts
  class AIModelContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.valid_block(grid_model, select_val)
    if (select_val < 0 or select_val > grid_model.x) then raise AIModelContractError.new("Bad AI input") end
  end

end
