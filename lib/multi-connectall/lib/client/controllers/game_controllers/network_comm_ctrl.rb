require 'mysql'
require 'ostruct' 
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
      # if header != :join or header != :update
      #   throw RuntimeError.new, "Invalid Header Packet"
      # end

      packet =  {:header => header, :playerid => @game_state_model::name, :data => data}
      packet = OpenStruct.new packet
      return YAML.dump(packet)
    end

    def send_message(message)
      @socket.write(message) if @socket
    end

    def read_message
      data = @socket.readpartial(4096) if @socket
      return YAML.load(data)
    end

    def join_game
      @window.client_network_com.send_message(create_message(:join, data = @game_state_model.generate_universal_game_state))
    end

    def login
      ugs = @game_state_model.generate_universal_game_state
      @window.client_network_com.send_message(create_message(:login, ugs))
    end

    def init_login(name)
      # puts "#{['init', name].join('|')}"
      send_message(['init', name].join('|'))  
    end

    def join_queue(mode)
      if mode == 'classic'
        ugs = @game_state_model.generate_universal_game_state
        ugs.game_mode = :classic
        @window.client_network_com.send_message(create_message(:join, ugs))
      elsif mode == 'otto'
        ugs = @game_state_model.generate_universal_game_state
        ugs.game_mode = :otto
        @window.client_network_com.send_message(create_message(:join, ugs))
      end
    end

    def send_update
      ugs = @game_state_model.generate_universal_game_state
      ugs.game_state = :updated
      ugs.last_move_x = @game_state_model::players[@game_state_model::player_role].move
      ugs.last_move_y = @game_state_model::grid.column_depth(ugs.last_move_x)
      @window.client_network_com.send_message(create_message(:update, ugs))
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

    def move(x, ugs)
      @window.client_network_com.send_message(['move',@game_state_model::player_role,"#{x}%#{@game_state_model::grid.column_depth(x)}"].join('|'))
    end

  end
end
