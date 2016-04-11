module ClientContracts
  class ClientContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.invariant(socket)
    if socket == nil then raise ClientContractError.new("No socket found") end
  end

end