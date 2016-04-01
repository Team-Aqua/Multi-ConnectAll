module ClientNetworkCommunicationsCtrlContracts
  class ClientNetworkCommunicationsContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.invariant
    # has network connection
    # ensure that there's always a server online
    # ensure Game state is not nil
    # 
  end

  def self.pre_receive_data
    # valid input serialized string
  end

  def self.validate_deserialized_received_data
    # valid deserialized data
  end

  def self.pre_serialize_state
    # valid state to serialize
  end

  def self.post_serialize_state
    # valid serialized data
  end


end

module ServerNetworkCommunicationsCtrlContracts
  class ServerNetworkCommunicationsCtrlContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.invariant
    # has network connection
    # clients are alive to comm with
  end

  def self.pre_receive_data
    # valid input serialized string
  end

  def self.validate_deserialized_received_data
    # valid deserialized data
  end

  def self.pre_serialize_state
    # valid state to serialize
  end

  def self.post_serialize_state
    # valid serialized data
  end

  def self.pre_handle_connection(socket, server)
    # ensure that socket is not nil
    # ensure that server is not nil
  end

end



module ServerCtrlContracts
  class ServerCtrlContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.invariant
    # ensure that there's always a server online
    # ensure has a NetworkCommunications Ctrl
    # ensure has a DB Ctrl
    # ensure DB is present
  end

  def self.pre_initialise(host, port)
    # ensure that host and port are valid values for importing
  end

  def self.post_initialise(host, port)
    # ensure that the end values and the received values are the same
    # ensure that all data is passed through correctly
  end

  def self.pre_shutdown(server, players)
    # ensure player score data is saved
  end

  def self.post_shutdown(server, players)
    # ensure cleanup active games
    # ensure that all players are alerted to server shutdown (Throw error?)
  end

  def self.pre_instantiate_game_action(entry, game, socket)
    # ensure that the game is still running
    # ensure that all received values are valid WRT current game
  end

end

module ServerMgmtModelContracts
  class ServerMgmtModelContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.invariant
    # data is valid e.g. Player Queues, Game Rooms, Player scores.
  end
end



module DBCtrlContracts
  class DBCtrlContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.invariant
    # ensure DB is accessible 
    # ServerModelData is accessible
    # Sychronized
  end

  def self.pre_db_pull
    # ensure data present
  end

  def self.post_db_pull
    # ensure valid data
  end

  def self.pre_db_push
    # ensure data valid
    # ensure data untainted
    # ensure sanitized
  end

  def self.post_db_push
    # ensure data is in the DB
  end
end