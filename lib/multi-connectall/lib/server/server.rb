require_relative 'controllers/db_ctrl'
require_relative 'controllers/server_ctrl'
require_relative 'controllers/server_network_com_ctrl'

require_relative 'models/server_model'
require_relative '../client/models/grid_model'
require_relative '../shared/universal_game_state_model'
require_relative '../client/contracts/grid_model_contracts'
require_relative '../ancillaries/m_contract_error'

require 'celluloid/io'
require 'celluloid/autostart'
require 'Mysql2'
require 'mysql'
require 'yaml'
require 'ostruct'

require_relative 'server_helpers'

class Server
  include Celluloid::IO
  finalizer :shutdown

  def initialize(host, port)
    puts "Starting Server at #{host}:#{port}."
    @server = TCPServer.new(host, port)
    
    @server_model = Models::ServerModel.new
    # @db_ctrl = Controllers::DBCtrl.new
    @network_comm_ctrl = Controllers::ServerNetworkCommunicationCtrl

    @db_ctrl = Controllers::DBCtrl.new(host, port)
    # @database = Mysql2::Client.new(:host => host, :port => port)
    
    async.run
  end

  def shutdown
    @server.close if @server
  end

  def run
    loop do 
      async.handle_connection(@server.accept)
      # async.handle_classic_queue()
      # async.handle_otto_queue()
      # async.handle_active_games()
    end
  end

  def handle_classic_queue()
    if @server_model::queues[:classic].size >= 2
      # create_match
      player1 = @server_model::queues[:classic].pop
      player2 = @server_model::queues[:classic].pop
      game_model = Models::UniversalGameStateModel.new
      
      game_model.game_state = :initialized
      game_model.game_mode = :classic
      game_model.user1 = player1
      game_model.user2 = player2
      game_model.user1_state = :turn
      game_model.user2_state = :waiting

      @server_model::active_games.insert(0, game_model)

      puts @server_model::active_games

    end
  end


  def handle_otto_queue()
    if @server_model::queues[:otto].size > 2
      # create_match
      player1 = @server_model::queues[:otto].pop
      player2 = @server_model::queues[:otto].pop
      game_model = Models::UniversalGameStateModel.new
      
      game_model.game_state = :initialized
      game_model.game_mode = :otto
      game_model.user1 = player1
      game_model.user2 = player2
      game_model.user1_state = :turn
      game_model.user2_state = :waiting

      @server_model::active_games.insert(0, game_model)

      puts @server_model::active_games

    end
  end

  def handle_active_games()
    @server_model.active_games.each do |game|
      if game.game_state == :updated
        game.game_state = :active
        
        if game.user1_state == :turn 
          game.user1_state = :waiting
          game.user2_state = :turn
          #send gamestate to client2
          send_message(@server_model.online_users[game.user2], create_message(:update, game))
        end

        if game.user2_state == :turn 
          game.user1_state == :turn
          game.user2_state == :waiting
          #send gamestate to client1
          send_message(@server_model.online_users[game.user2], create_message(:update, game))
        end

      end

      if game.game_state == :initialized
        sleep(0.25) #magic stall makes things work
        puts "Sending Initialized Game States to #{game.user1} and #{game.user2}"
        game.assigned_role = 0
        puts "socket #{@server_model.online_users[game.user1]}"
        @server_model.online_users[game.user1].write(create_message(:initialze, game))
        game.assigned_role = 1
        @server_model.online_users[game.user2].write(create_message(:initialze, game))
        puts "send"
      end
    end
  end

  def create_message(header, data = nil)
    # if header != :join or header != :update
    #   throw RuntimeError.new, "Invalid Header Packet"
    # end
    packet =  {:header => header, :playerid => "server", :data => data}
    packet = OpenStruct.new packet
    return YAML.dump(packet)
  end

  def send_message(socket, message)
    puts socket
    socket.write(message) if @socket
  end

  def login(socket, packet)
    # if @server_model::online_users.include?(packet.playerid) then socket.close(); end FIX ME IMPLEMENT THIS
    
    @server_model::online_users[packet.playerid] = socket
    puts "Online Users: #{@server_model::online_users.keys}"
  end

  def join_game(socket, packet)
    puts packet.game_mode
    @server_model::queues[packet.data.game_mode].insert(0, packet.playerid)
    puts "#{packet.data.game_mode.to_s} Game Queue #{@server_model::queues[packet.data.game_mode]}"
    # socket.write(create_message(:ack))
  end

  def handle_connection(socket)
    _, port, host = socket.peeraddr
    user = "#{host}:#{port}"
    puts "#{user} has joined the server."
    puts socket

    loop do 
      data = socket.readpartial(4096)
      if data && !data.empty?

        # begin
        #   case data[0]
        #     when 'load_stats'
        #       results = @db_ctrl.get_total_stats(data[1])
        #       puts "results!: #{results}"
        #       socket.write(results)
        #     when 'leaderboards'
        #       results_top = @db_ctrl.get_top_overall_players
        #       results_classic = @db_ctrl.get_top_classic_players
        #       results_otto = @db_ctrl.get_top_otto_players
        #       results_total = [results_top, results_classic, results_otto].join('|')
        #       socket.write(results_total)
        #     when 'init'
        #       @db_ctrl.insert_user_row_ignore(data[1])
        #     when 'classic'
        #       socket.write("ready")
        #     when 'otto'
        #       socket.write("ready")
        #     when 'join'
        #       # puts "writing : #{@players.size % 2}"
        #       socket.write("setup|#{@players.size % 2}")
        #       @players[user] = ["Temp", nil, "green"]
        #     when 'setup'
        #       @players[user] = [data[1], nil, data[2]]
        #       # puts "playersize: #{@players.size}, player: #{@players[user]}, data: #{data[2]}"
        #       if @players.size % 2 == 0
        #         @players.each do |player, data|
        #           # puts "#{player} || #{data}"
        #           if player != user && data[1] == nil
        #             @games[@count] = { player_1: data[0],
        #                                player_2: @players[user][0],
        #                                player_1_color: data[2],
        #                                player_2_color: @players[user][2],
        #                                player_1_score: 0,
        #                                player_2_score: 0,
        #                                tiles: [] }
        #             @players[player][1] = @count
        #             @players[user][1] = @count
        #             @count += 1
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
        #           end
        #         end
        #       else
        #         socket.write("waiting")
        #       end
        #     when 'load'
        #       if @players[user][1] != nil
        #         game = @players[user][1]
        #         response = ["load",
        #                     @games[game][:player_1],
        #                     @games[game][:player_2],
        #                     @games[game][:player_1_color],
        #                     @games[game][:player_2_color],
        #                     @games[game][:player_1_score],
        #                     @games[game][:player_2_score],
        #                     @games[game][:tiles]].join('|')
        #         socket.write(response)
        #       else
        #         response = "waiting"
        #         socket.write(response)
        #       end
        #     when 'wait'
        #       if @players[user][1] != nil
        #         game = @players[user][1]
        #         response = ["game",
        #                     @games[game][:player_1],
        #                     @games[game][:player_2],
        #                     @games[game][:player_1_color],
        #                     @games[game][:player_2_color],
        #                     @games[game][:player_1_score],
        #                     @games[game][:player_2_score],
        #                     @games[game][:tiles]].join('|')
        #         socket.write(response)
        #       else
        #         response = "waiting"
        #         socket.write(response)
        #       end
        #     when 'win'
        #       puts "win: #{data[1]} :: on #{data[2]}"
        #       if data[2] == 'classic'
        #         @db_ctrl.increment_classic_win(data[1])
        #       elsif data[2] == 'otto'
        #          @db_ctrl.increment_otto_win(data[1])
        #       end 
        #     when 'tie'
        #       puts "tie: #{data[1]} :: on #{data[2]}"
        #       if data[2] == 'classic'
        #         @db_ctrl.increment_classic_tie(data[1])
        #       elsif data[2] == 'otto'
        #          @db_ctrl.increment_otto_tie(data[1])
        #       end 
        #     when 'loss'
        #       puts "loss: #{data[1]} :: on #{data[2]}"
        #       if data[2] == 'classic'
        #         @db_ctrl.increment_classic_loss(data[1])
        #       elsif data[2] == 'otto'
        #          @db_ctrl.increment_otto_loss(data[1])
        #       end 
        #     when 'skip'
        #       # data[1] holds player_role
        #       game = @players[user][1]
        #       if @games[game][:player_1] == @players[user][0]
        #         role = "A"
        #       else
        #         role = "B"
        #       end
        #       entry = role + "%S%" + @games[game][:tiles].length.to_s
        #       # puts "Skip: #{entry}"
        #       if !@games[game][:tiles].include?("A%S%" + @games[game][:tiles].length.to_s) && !@games[game][:tiles].include?("B%S%" + @games[game][:tiles].length.to_s)
        #         instantiate_game_action(entry, game, socket)
        #       end
        #       # instantiate_game_action(entry, game, socket)
        #       # instantiate_game_action("CLR", game, socket)
        #     when 'concede'
        #       # data[1] holds player_role
        #       game = @players[user][1]
        #       if @games[game][:player_1] == @players[user][0]
        #         role = "A"
        #       else
        #         role = "B"
        #       end
        #       entry = role + "%C%" + @games[game][:tiles].length.to_s
        #       # puts "Concede: #{entry}"
        #       if !@games[game][:tiles].include?("A%C%" + @games[game][:tiles].length.to_s) && !@games[game][:tiles].include?("B%C%" + @games[game][:tiles].length.to_s)
        #         instantiate_game_action(entry, game, socket)
        #       end
        #     when 'loadsave'
        #       #puts "saved: #{data[1]}"
        #       result = @db_ctrl.get_saved_game(data[1])
        #       #puts "result: #{result}"
        #       socket.write(result)
        #     when 'save'
        #       # data[1] holds player_role
        #       # puts "Self_name: #{data[1]}, p1_name: #{data[2]}, p2_name: #{data[3]}, grid: #{data[4]}, turn_state: #{data[5]}"
        #       players = data[2]
        #       realplayers = data[3]
        #       grid = data[4]
        #       # fixed_grid = reconstruct_grid(grid)
        #       # print_grid(fixed_grid)
        #       player_turn_state = data[5]
        #       game = @players[user][1]
        #       if @games[game][:player_1] == @players[user][0]
        #         role = "A"
        #         player = @games[game][:player_1]
        #       else
        #         role = "B"
        #         player = @games[game][:player_2]
        #       end
        #       entry = role + "%V%" + @games[game][:tiles].length.to_s
        #       @db_ctrl.insert_saved_game(player, [data[2], data[3], data[4], data[5]].join("|"))
        #       if !@games[game][:tiles].include?("A%V%" + @games[game][:tiles].length.to_s) && !@games[game][:tiles].include?("B%V%" + @games[game][:tiles].length.to_s)
        #         instantiate_game_action(entry, game, socket)
        #       end
        #     when 'move'
        #       puts "move activated!"
        #       move = data[2] #.to_i
        #       game = @players[user][1]
        #       puts "game: #{@players[user][0]}"
        #       if @games[game][:player_1] == @players[user][0]
        #         role = "A"
        #       else
        #         role = "B"
        #       end
        #       entry = role + "%" + move.to_s
        #       if !@games[game][:tiles].include?("A%" + move.to_s) && !@games[game][:tiles].include?("B%" + move.to_s)
        #         instantiate_game_action(entry, game, socket)
        #       end
        #     else
        #       puts "Unknown: #{data[0]}"
        #   end
        # rescue

        packet = YAML.load(data)
        # puts packet
        if packet.header == :login
          login(socket, packet)
        elsif packet.header == :join
          join_game(socket, packet)
          handle_classic_queue()
          handle_otto_queue
          handle_active_games
        elsif packet.header == :update
          update_game(socket, packet)
          handle_active_games()
        end
        
      end
      socket.write(create_message(:heartbeat))
    end

    # loop do
    #   data = socket.readpartial(4096)
    #   # puts "#{data}"
    #   data = data.split('|')
    #   if data && !data.empty?
    #     begin
    #       case data[0]
    #         when 'classic'
    #           socket.write("ready")
    #         when 'otto'
    #           socket.write("ready")
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
    #           puts "win: #{data[1]}"
    #         when 'tie'
    #           puts "tie: #{data[1]}"
    #         when 'loss'
    #           puts "loss: #{data[1]}"
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
    #         when 'save'
    #           # data[1] holds player_role
    #           game = @players[user][1]
    #           if @games[game][:player_1] == @players[user][0]
    #             role = "A"
    #           else
    #             role = "B"
    #           end
    #           entry = role + "%V%" + @games[game][:tiles].length.to_s
    #           # puts "Concede: #{entry}"
    #           if !@games[game][:tiles].include?("A%V%" + @games[game][:tiles].length.to_s) && !@games[game][:tiles].include?("B%V%" + @games[game][:tiles].length.to_s)
    #             instantiate_game_action(entry, game, socket)
    #           end
    #           # instantiate_game_action(entry, game, socket)
    #           # instantiate_game_action("CLR", game, socket)
    #         when 'move'
    #           puts "move activated!"
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
    # end
    
  rescue EOFError
    puts "#{user} has left server."
    socket.close
  end
end

def reconstruct_grid(gridipt)
  gridData = gridipt.split("&")
  puts "GridData: #{gridData}"
  grid = []
  (0..7).each { |y|
    row = []
    (0..7).each { |x|
          row.push(gridData[(y * 8) + x].to_i)
        }
        grid.push(row)
      }
  return grid
end

def print_grid(grid)
  puts ""
  puts ""
  puts ""
  puts ""
  puts ""
  grid.each do |row|
    print row
    puts ""
  end
end

def instantiate_game_action(entry, game, socket)
  @games[game][:tiles] << entry
  response = ["game",
    @games[game][:player_1],
    @games[game][:player_2],
    @games[game][:player_1_color],
    @games[game][:player_2_color],
    @games[game][:player_1_score],
    @games[game][:player_2_score],
    @games[game][:tiles]].join('|')
  # puts "Move Response: #{response}"
  socket.write(response)
end

server = ARGV[0] || "127.0.0.1"
port = ARGV[1] || 1234

supervisor = Server.supervise(server, port.to_i)
trap("INT") do
  supervisor.terminate
  exit
end
sleep
