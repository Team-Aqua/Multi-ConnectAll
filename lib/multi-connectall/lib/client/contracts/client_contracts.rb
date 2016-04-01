module ClientContracts
  class ClientContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.invariant
    # ensure that the socket is never nil
    # can be used for send/read message as well
  end

end