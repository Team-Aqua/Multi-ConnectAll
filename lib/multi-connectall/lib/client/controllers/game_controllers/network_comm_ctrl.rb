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

    def create_message(header, data = nil)
      if header != :join or header != :update
        throw RuntimeError.new, "Invalid Header Packet"
      end

      packet =  {:header => header, :playerid => @game_state_model.players[0].name, :data => Lala.new}
      packet = OpenStruct.new packet
      return YAML.dump(packet)
    end

    def send_message(message)
      @socket.write(message) if @socket
    end

    def read_message
      @socket.readpartial(4096) if @socket
    end

    def join_game
      @window.client_network_com.send_message(create_message(:join, data = @game_state_model.generate_universal_game_state))
    end

    def send_win
      @window.client_network_com.send_message(['win', @window.game_state_model::player_role].join('|'))  
    end

    def send_tie
      @window.client_network_com.send_message('tie')
    end

    def move(x)
      @window.client_network_com.send_message(['move',@game_state_model::player_role,"#{x}%#{@game_state_model::grid.column_depth(x)}"].join('|'))
    end

  end
end
