module ServerContracts
  class ServerContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.pre_initialise(host, port)
    if host == nil then raise ServerContractError.new("No host selected.") end
    if port == nil then raise ServerContractError.new("No port selected.") end
  end

  def self.post_initialise(server)
    if server == nil then raise ServerContractError.new("No server generated.") end
  end

  def self.pre_shutdown(server)
    if server == nil then raise ServerContractError.new("No server available for shutdown.") end
  end

  def self.pre_handle_connection(socket, server)
    if socket == nil then raise ServerContractError.new("No socket selected.") end
    if server == nil then raise ServerContractError.new("No server selected.") end
  end

  def self.pre_instantiate_game_action(entry, game, socket)
    if game == nil then raise ServerContractError.new("No game available for game action.") end
    if entry == nil then raise ServerContractError.new("No socket available for game action.") end
    if server == nil then raise ServerContractError.new("No server available for game action.") end
  end

end