require_relative 'controllers//db_ctrl'
require_relative 'controllers/server_ctrl'
require_relative 'controllers/server_network_com_ctrl'

require_relative 'models/server_model'
require_relative '../shared/universal_game_state_model'

require 'celluloid/io'
require 'celluloid/autostart'

require_relative 'server_helpers'

class Server
  include Celluloid::IO
  finalizer :shutdown

  def initialize(host, port)
    puts "Starting Server at #{host}:#{port}."
    @server = TCPServer.new(host, port)
    
    @server_model = Models::ServerModel.new
    @db_ctrl = Controllers::DBCtrl.new
    @network_comm_ctrl = Controllers::ServerNetworkCommunicationCtrl

    async.run
  end

  def shutdown
    @server.close if @server
  end

  def run
    loop { async.handle_connection(@server.accept) }
  end

  def extract_universal_game_state

  end

  def handle_connection(socket)
    _, port, host = socket.peeraddr
    user = "#{host}:#{port}"
    puts "#{user} has joined the server."
    loop do 
        data = socket.readpartial(4096)
        if data && !data.empty?
            # model = extract_universal_game_state
            unpack = YAML.load(data)
        end
        socket.write 
    end
    # loop do
    #   data = socket.readpartial(4096)
    #   # puts "#{data}"
    #   data = data.split('|')
    #   if data && !data.empty?
    #     begin
    #       case data[0]
    #         when 'join'
    #           # puts "writing : #{@players.size % 2}"
    #           socket.write("setup|#{@players.size % 2}")
    #           @players[user] = ["Temp", nil, "green"]
    #         when 'setup'
    #           @players[user] = [data[1], nil, data[2]]
    #           # puts "playersize: #{@players.size}, player: #{@players[user]}, data: #{data[2]}"
    #           if @players.size % 2 == 0
    #             @players.each do |player, data|
    #               # puts "#{player} || #{data}"
    #               if player != user && data[1] == nil
    #                 @games[@count] = { player_1: data[0],
    #                                    player_2: @players[user][0],
    #                                    player_1_color: data[2],
    #                                    player_2_color: @players[user][2],
    #                                    player_1_score: 0,
    #                                    player_2_score: 0,
    #                                    tiles: [] }
    #                 @players[player][1] = @count
    #                 @players[user][1] = @count
    #                 @count += 1
    #                 game = @players[user][1]
    #                 response = ["load",
    #                             @games[game][:player_1],
    #                             @games[game][:player_2],
    #                             @games[game][:player_1_color],
    #                             @games[game][:player_2_color],
    #                             @games[game][:player_1_score],
    #                             @games[game][:player_2_score],
    #                             @games[game][:tiles]].join('|')
    #                 socket.write(response)
    #               end
    #             end
    #           else
    #             socket.write("waiting")
    #           end
    #         when 'load'
    #           if @players[user][1] != nil
    #             game = @players[user][1]
    #             response = ["load",
    #                         @games[game][:player_1],
    #                         @games[game][:player_2],
    #                         @games[game][:player_1_color],
    #                         @games[game][:player_2_color],
    #                         @games[game][:player_1_score],
    #                         @games[game][:player_2_score],
    #                         @games[game][:tiles]].join('|')
    #             socket.write(response)
    #           else
    #             response = "waiting"
    #             socket.write(response)
    #           end
    #         when 'wait'
    #           if @players[user][1] != nil
    #             game = @players[user][1]
    #             response = ["game",
    #                         @games[game][:player_1],
    #                         @games[game][:player_2],
    #                         @games[game][:player_1_color],
    #                         @games[game][:player_2_color],
    #                         @games[game][:player_1_score],
    #                         @games[game][:player_2_score],
    #                         @games[game][:tiles]].join('|')
    #             socket.write(response)
    #           else
    #             response = "waiting"
    #             socket.write(response)
    #           end
    #         when 'win'
    #         when 'tie'
    #         when 'skip'
    #           # data[1] holds player_role
    #           game = @players[user][1]
    #           if @games[game][:player_1] == @players[user][0]
    #             role = "A"
    #           else
    #             role = "B"
    #           end
    #           entry = role + "%S%" + @games[game][:tiles].length.to_s
    #           # puts "Skip: #{entry}"
    #           if !@games[game][:tiles].include?("A%S%" + @games[game][:tiles].length.to_s) && !@games[game][:tiles].include?("B%S%" + @games[game][:tiles].length.to_s)
    #             instantiate_game_action(entry, game, socket)
    #           end
    #           # instantiate_game_action(entry, game, socket)
    #           # instantiate_game_action("CLR", game, socket)
    #         when 'concede'
    #           # data[1] holds player_role
    #           game = @players[user][1]
    #           if @games[game][:player_1] == @players[user][0]
    #             role = "A"
    #           else
    #             role = "B"
    #           end
    #           entry = role + "%C%" + @games[game][:tiles].length.to_s
    #           # puts "Concede: #{entry}"
    #           if !@games[game][:tiles].include?("A%C%" + @games[game][:tiles].length.to_s) && !@games[game][:tiles].include?("B%C%" + @games[game][:tiles].length.to_s)
    #             instantiate_game_action(entry, game, socket)
    #           end
    #           # instantiate_game_action(entry, game, socket)
    #           # instantiate_game_action("CLR", game, socket)
    #         when 'move'
    #           move = data[2] #.to_i
    #           game = @players[user][1]
    #           puts "game: #{@players[user][0]}"
    #           if @games[game][:player_1] == @players[user][0]
    #             role = "A"
    #           else
    #             role = "B"
    #           end
    #           entry = role + "%" + move.to_s
    #           if !@games[game][:tiles].include?("A%" + move.to_s) && !@games[game][:tiles].include?("B%" + move.to_s)
    #             instantiate_game_action(entry, game, socket)
    #           end
    #         else
    #           puts "Unknown: #{data[0]}"
    #       end
    #     rescue
    #   end
  rescue EOFError
    puts "#{user} has left server."
    socket.close
  end
end

server = ARGV[0] || "127.0.0.1"
port = ARGV[1] || 1234

supervisor = Server.supervise(server, port.to_i)
trap("INT") do
  supervisor.terminate
  exit
end
sleep
