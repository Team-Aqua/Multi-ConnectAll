module ServerContracts
  class ServerContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.invariant
    # ensure that there's always a server online
    # run after initialisation
  end

  def self.pre_initialise(host, port)
    # ensure that host and port are valid values for importing
  end

  def self.post_initialise(host, port)
    # ensure that the end values and the received values are the same
    # ensure that all data is passed through correctly
  end

  def self.pre_shutdown(server, players)
    # ensure that all players are alerted to server shutdown (Throw error?)
  end

  def self.pre_handle_connection(socket, server)
    if socket == nil then raise ServerContractError.new("No socket selected.") end
    if server == nil then raise ServerContractError.new("No server selected.") end
    # ensure that socket is not nil
    # ensure that server is not nil
  end

  def self.pre_instantiate_game_action(entry, game, socket)
    # ensure that the game is still running
    # ensure that all received values are valid WRT current game
  end

end