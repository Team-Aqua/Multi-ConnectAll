require_relative 'controllers/db_ctrl'
require_relative 'controllers/server_ctrl'
require_relative 'controllers/server_network_com_ctrl'

require_relative 'models/server_model'
require_relative '../shared/universal_game_state_model'

require 'celluloid/io'
require 'celluloid/autostart'
require 'Mysql2'
require 'mysql'

require_relative 'server_helpers'

class Server
  include Celluloid::IO
  finalizer :shutdown

  def initialize(host, port)
    puts "Starting Server at #{host}:#{port}."
    @server = TCPServer.new(host, port)
    @players = {}
    @savedplayers = {}
    @games = {}
    @count = 1
    @load_ready = false

    @db_ctrl = Controllers::DBCtrl.new(host, port)
    # @database = Mysql2::Client.new(:host => host, :port => port)
    
    async.run
  end

  def shutdown
    @server.close if @server
  end

  def run
    loop { async.handle_connection(@server.accept) }
  end

  def handle_connection(socket)
    _, port, host = socket.peeraddr
    user = "#{host}:#{port}"
    puts "#{user} has joined the server."

    loop do
      data = socket.readpartial(4096)
      # puts "#{data}"
      data = data.split('|')
      if data && !data.empty?
        begin
          case data[0]
            when 'load_stats'
              results = @db_ctrl.get_total_stats(data[1])
              # puts "results!: #{results}"
              socket.write(results)
            when 'leaderboards'
              results_top = @db_ctrl.get_top_overall_players
              results_classic = @db_ctrl.get_top_classic_players
              results_otto = @db_ctrl.get_top_otto_players
              results_total = [results_top, results_classic, results_otto].join('|')
              socket.write(results_total)
            when 'init'
              @db_ctrl.insert_user_row_ignore(data[1])
            when 'classic'
              socket.write("ready")
            when 'otto'
              socket.write("ready")
            when 'join'
              # puts "writing : #{@players.size % 2}"
              socket.write("setup|#{@players.size % 2}")
              @players[user] = ["Temp", nil, "green"]
            when 'setup'
              @players[user] = [data[1], nil, data[2]]
              if @players.size % 2 == 0
                @players.each do |player, data|
                  # puts "#{player} || #{data}"
                  if player != user && data[1] == nil # is second player only
                    @games[@count] = { player_1: data[0],
                                       player_2: @players[user][0],
                                       player_1_color: data[2],
                                       player_2_color: @players[user][2],
                                       player_1_score: 0,
                                       player_2_score: 0,
                                       tiles: [] }
                    @players[player][1] = @count
                    @players[user][1] = @count
                    @count += 1
                    game = @players[user][1]
                    response = ["load",
                                @games[game][:player_1],
                                @games[game][:player_2],
                                @games[game][:player_1_color],
                                @games[game][:player_2_color],
                                @games[game][:player_1_score],
                                @games[game][:player_2_score],
                                @games[game][:tiles]].join('|')
                    socket.write(response)
                  end
                end
              else
                socket.write("waiting")
              end
            when 'setup_save'
              puts "yoko kano"
              # puts "setupsave: data[1]: #{data[1]}"
              @players[user] = [data[1], nil, nil]
              results = @db_ctrl.get_saved_game(data[1])
              puts results
              if results != nil
                resultdata = results.split("|") 
                @games[@count] = { player_1: resultdata[0],
                     player_2: resultdata[1],
                     player_1_color: resultdata[2],
                     player_2_color: resultdata[3],
                     player_1_score: 0,
                     player_2_score: 0,
                     saved_game: resultdata[4],
                     tiles: [] }
              end
              if @players.size % 2 == 0
                @players.each do |player, data|
                  # puts "#{player} || #{data}"
                  if player != user && data[1] == nil
                    # @games[@count] = { player_1: data[0],
                    #                    player_2: @players[user][0],
                    #                    player_1:_color: data[2],
                    #                    player_2_color: @players[user][2],
                    #                    player_1_score: 0,
                    #                    player_2_score: 0,
                    #                    tiles: [] }
                    if @games[game][:player_1] == nil
                      puts "continues"
                      socket.write("waiting")
                    else 
                    puts "breaks @ #{@games[game][:player_1]}"
                    @players[player][1] = @count
                    @players[user][1] = @count
                    game = @players[user][1]
                      response = ["loadsave",
                                  @games[game][:player_1],
                                  @games[game][:player_2],
                                  @games[game][:player_1_color],
                                  @games[game][:player_2_color],
                                  @games[game][:player_1_score],
                                  @games[game][:player_2_score],
                                  @games[game][:saved_game]].join('|')
                      # puts "DATA: #{game} || #{}"
                      # puts "WRITING: #{response}"
                      socket.write(response)
                    end
                  end
                end
                @count += 1
              else
                socket.write("waiting")
              end
            when 'load_save'
              if @players[user][1] != nil
                game = @players[user][1]
                response = ["loadsave",
                            @games[game][:player_1],
                            @games[game][:player_2],
                            @games[game][:player_1_color],
                            @games[game][:player_2_color],
                            @games[game][:player_1_score],
                            @games[game][:player_2_score],
                            @games[game][:saved_game]].join('|')
                socket.write(response)
              else
                response = "waiting"
                socket.write(response)
              end
            when 'load'
              if @players[user][1] != nil
                game = @players[user][1]
                response = ["load",
                            @games[game][:player_1],
                            @games[game][:player_2],
                            @games[game][:player_1_color],
                            @games[game][:player_2_color],
                            @games[game][:player_1_score],
                            @games[game][:player_2_score],
                            @games[game][:tiles]].join('|')
                socket.write(response)
              else
                response = "waiting"
                socket.write(response)
              end
            when 'wait'
              if @players[user][1] != nil
                game = @players[user][1]
                response = ["game",
                            @games[game][:player_1],
                            @games[game][:player_2],
                            @games[game][:player_1_color],
                            @games[game][:player_2_color],
                            @games[game][:player_1_score],
                            @games[game][:player_2_score],
                            @games[game][:tiles]].join('|')
                socket.write(response)
              else
                response = "waiting"
                socket.write(response)
              end
            when 'win'
              # puts "win: #{data[1]} :: on #{data[2]}"
              if data[2] == 'classic'
                @db_ctrl.increment_classic_win(data[1])
              elsif data[2] == 'otto'
                 @db_ctrl.increment_otto_win(data[1])
              end 
            when 'tie'
              # puts "tie: #{data[1]} :: on #{data[2]}"
              if data[2] == 'classic'
                @db_ctrl.increment_classic_tie(data[1])
              elsif data[2] == 'otto'
                 @db_ctrl.increment_otto_tie(data[1])
              end 
            when 'loss'
              # puts "loss: #{data[1]} :: on #{data[2]}"
              if data[2] == 'classic'
                @db_ctrl.increment_classic_loss(data[1])
              elsif data[2] == 'otto'
                 @db_ctrl.increment_otto_loss(data[1])
              end 
            when 'skip'
              # data[1] holds player_role
              game = @players[user][1]
              if @games[game][:player_1] == @players[user][0]
                role = "A"
              else
                role = "B"
              end
              entry = role + "%S%" + @games[game][:tiles].length.to_s
              # puts "Skip: #{entry}"
              if !@games[game][:tiles].include?("A%S%" + @games[game][:tiles].length.to_s) && !@games[game][:tiles].include?("B%S%" + @games[game][:tiles].length.to_s)
                instantiate_game_action(entry, game, socket)
              end
              # instantiate_game_action(entry, game, socket)
              # instantiate_game_action("CLR", game, socket)
            when 'concede'
              # data[1] holds player_role
              game = @players[user][1]
              if @games[game][:player_1] == @players[user][0]
                role = "A"
              else
                role = "B"
              end
              entry = role + "%C%" + @games[game][:tiles].length.to_s
              # puts "Concede: #{entry}"
              if !@games[game][:tiles].include?("A%C%" + @games[game][:tiles].length.to_s) && !@games[game][:tiles].include?("B%C%" + @games[game][:tiles].length.to_s)
                instantiate_game_action(entry, game, socket)
              end
            when 'save'
              players = data[2]
              realplayers = data[3]
              grid = data[4]
              # fixed_grid = reconstruct_grid(grid)
              # print_grid(fixed_grid)
              player_turn_state = data[5]
              game = @players[user][1]
              if @games[game][:player_1] == @players[user][0]
                role = "A"
                player = @games[game][:player_1]
              else
                role = "B"
                player @games[game][:player_2]
              end
              entry = role + "%V%" + @games[game][:tiles].length.to_s
              @db_ctrl.insert_saved_game(player, [data[2], data[3], data[4], data[5], data[6], data[7]].join("|"))
              if !@games[game][:tiles].include?("A%V%" + @games[game][:tiles].length.to_s) && !@games[game][:tiles].include?("B%V%" + @games[game][:tiles].length.to_s)
                instantiate_game_action(entry, game, socket)
              end
            when 'move'
              move = data[2] #.to_i
              game = @players[user][1]
              puts "game: #{@players[user][0]}"
              if @games[game][:player_1] == @players[user][0]
                role = "A"
              else
                role = "B"
              end
              entry = role + "%" + move.to_s
              if !@games[game][:tiles].include?("A%" + move.to_s) && !@games[game][:tiles].include?("B%" + move.to_s)
                instantiate_game_action(entry, game, socket)
              end
            else
              puts "Unknown: #{data[0]}"
          end
        rescue
      end
    end
  end
  rescue EOFError
    puts "#{user} has left server."
    game = @players[user][1]
    @games.delete(game)
    @players.each do |host, data|
      if data[1] == game
        @players[host][1] = nil
      end
    end
    @players.delete(user)
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
