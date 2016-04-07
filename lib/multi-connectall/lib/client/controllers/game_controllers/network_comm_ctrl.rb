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

    def init_login(name)
      # puts "#{['init', name].join('|')}"
      send_message(['init', name].join('|'))  
    end

    def join_queue(mode)
      if mode == 'classic'
        send_message("classic")
      elsif mode == 'otto'
        send_message("otto")
      end
    end

    def send_win
      if @window.game_state_model::game_type == :classic
        send_message(['win', @window.game_state_model::players[@window.game_state_model::player_role].name, 'classic'].join('|'))  
      elsif @window.game_state_model::game_type == :otto
        send_message(['win', @window.game_state_model::players[@window.game_state_model::player_role].name, 'otto'].join('|'))  
      end
    end

    def send_loss
      if @window.game_state_model::game_type == :classic
        send_message(['loss', @window.game_state_model::players[@window.game_state_model::player_role].name, 'classic'].join('|'))  
      elsif @window.game_state_model::game_type == :otto
        send_message(['loss', @window.game_state_model::players[@window.game_state_model::player_role].name, 'otto'].join('|'))  
      end
    end

    def receive_leaderboards
      send_message('leaderboards')  
      return read_message
    end


    def send_tie
      if @window.game_state_model::game_type == :classic
        send_message(['tie', @window.game_state_model::players[@window.game_state_model::player_role].name, 'classic'].join('|'))  
      elsif @window.game_state_model::game_type == :otto
        send_message(['tie', @window.game_state_model::players[@window.game_state_model::player_role].name, 'otto'].join('|'))  
      end
    end

    def move(x)
      send_message(['move',@game_state_model::player_role,"#{x}%#{@game_state_model::grid.column_depth(x)}"].join('|'))
    end

  end
end
