module DBContracts
  class DBContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.invariant(database)
    if database == nil then raise DBContractError.new("No database connected.") end
  end

end