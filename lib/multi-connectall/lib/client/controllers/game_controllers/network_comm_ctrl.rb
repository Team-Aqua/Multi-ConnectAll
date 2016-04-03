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

    def send_message(message)
      @socket.write(message) if @socket
    end

    def read_message
      @socket.readpartial(4096) if @socket
    end

    def join_game
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
