require 'mysql'
module Controllers
  class NetworkCommunicationCtrl
    include Celluloid::IO

    def initialize(server, port, window)
      @window = window
      @game_state_model = @window.game_state_model
      begin
        @socket = TCPSocket.new(server, port)
      rescue
        $error_message = "Cannot find game server."
      end
    end

    ##
    # Generic processing of server message
    # Valid only if socket passed is valid

    def send_message(message)
      @socket.write(message) if @socket
    end

    ##
    # Reads message from socket
    # Valid only if server passed is valid

    def read_message
      @socket.readpartial(4096) if @socket
    end

    ##
    # Logic for joining game
    # Finds player role - whether they are first or second player

    def join_game
      ClientContracts.invariant(@socket)
      @window.client_network_com.send_message("join")
      data = @window.client_network_com.read_message
      data = data.split('|')
      if data && !data.empty?
        if data[0] == "setup"
          if data[1] == "0"
            @window.game_state_model::player_role = 0
          else 
            @window.game_state_model::player_role = 1
          end
        end
      end
      ClientContracts.invariant(@socket)
    end

    ##
    # Logic for initialisation of player on server

    def init_login(name)
      ClientContracts.invariant(@socket)
      send_message(['init', name].join('|'))  
      ClientContracts.invariant(@socket)
    end

    ##
    # Logic for joining specific queue
    # Either joining classic or otto queue

    def join_queue(mode)
      ClientContracts.invariant(@socket)
      if mode == 'classic'
        send_message("classic")
      elsif mode == 'otto'
        send_message("otto")
      end
      ClientContracts.invariant(@socket)
    end

    ##
    # Sends win information to server
    # Clarifies game_type

    def send_win
      ClientContracts.invariant(@socket)
      if @window.game_state_model::game_type == :classic
        send_message(['win', @window.game_state_model::players[@window.game_state_model::player_role].name, 'classic'].join('|'))  
      elsif @window.game_state_model::game_type == :otto
        send_message(['win', @window.game_state_model::players[@window.game_state_model::player_role].name, 'otto'].join('|'))  
      end
      ClientContracts.invariant(@socket)
    end

    ##
    # Sends loss information to server
    # Clarifies game_type

    def send_loss
      ClientContracts.invariant(@socket)
      if @window.game_state_model::game_type == :classic
        send_message(['loss', @window.game_state_model::players[@window.game_state_model::player_role].name, 'classic'].join('|'))  
      elsif @window.game_state_model::game_type == :otto
        send_message(['loss', @window.game_state_model::players[@window.game_state_model::player_role].name, 'otto'].join('|'))  
      end
      ClientContracts.invariant(@socket)
    end

    ##
    # Process for receiving leaderboard information
    # Passes key, waits for response

    def receive_leaderboards
      ClientContracts.invariant(@socket)
      send_message('leaderboards')  
      return read_message
    end

    ##
    # Sends tie information to server
    # Clarifies game_type

    def send_tie
      ClientContracts.invariant(@socket)
      if @window.game_state_model::game_type == :classic
        send_message(['tie', @window.game_state_model::players[@window.game_state_model::player_role].name, 'classic'].join('|'))  
      elsif @window.game_state_model::game_type == :otto
        send_message(['tie', @window.game_state_model::players[@window.game_state_model::player_role].name, 'otto'].join('|'))  
      end
      ClientContracts.invariant(@socket)
    end

    ##
    # Sends move information to server
    # Clarifies game_type

    def move(x)
      ClientContracts.invariant(@socket)
      send_message(['move',@game_state_model::player_role,"#{x}%#{@game_state_model::grid.column_depth(x)}"].join('|'))
      ClientContracts.invariant(@socket)
    end

  end
end
