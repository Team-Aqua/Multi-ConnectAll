require_relative 'controllers/db_ctrl'
require_relative 'models/server_model'

require_relative '../ancillaries/m_contract_error'
require_relative 'contracts/server_contracts'
require_relative 'contracts/db_contracts'

require 'celluloid/io'
require 'celluloid/autostart'
require 'Mysql2'
require 'mysql'

class Server
  include Celluloid::IO
  finalizer :shutdown

  def initialize(host, port)
    ServerContracts.pre_initialise(host, port)
    puts "Starting Server at #{host}:#{port}."
    @server = TCPServer.new(host, port)
    @players = {}
    @savedplayers = {}
    @games = {}
    @count = 1
    @db_ctrl = Controllers::DBCtrl.new(host, port)
    ServerContracts.post_initialise(@server)
    async.run
  end

  ###
  # shutdown
  # Server shutdown process

  def shutdown
    ServerContracts.pre_shutdown(@server)
    @server.close if @server
  end

  ###
  # run 
  # Server processing to ensure constant processing of clients

  def run
    loop { async.handle_connection(@server.accept) }
  end

  def handle_connection(socket)
    ServerContracts.pre_handle_connection(socket, @server)
    _, port, host = socket.peeraddr
    user = "#{host}:#{port}"
    puts "#{user} has joined the server."

    loop do
      data = socket.readpartial(4096)
      data = data.split('|')
      if data && !data.empty?
        begin
          case data[0]

            ###
            # load_stats
            # run when user requests w/l/t stats for specific user

            when 'load_stats'
              results = @db_ctrl.get_total_stats(data[1])
              socket.write(results)

            ###
            # leaderboards
            # run when user requests leaderboard stats

            when 'leaderboards'
              results_top = @db_ctrl.get_top_overall_players
              results_classic = @db_ctrl.get_top_classic_players
              results_otto = @db_ctrl.get_top_otto_players
              results_total = [results_top, results_classic, results_otto].join('|')
              socket.write(results_total)

            ###
            # init
            # run when user id is added to database

            when 'init'
              @db_ctrl.insert_user_row_ignore(data[1])

            ###
            # classic
            # run when user requests ready mode
            # can be overloaded to include additional queue data
            # in further iterations

            when 'classic'
              socket.write("ready")

            ###
            # otto
            # run when user requests ready mode
            # can be overloaded to include additional queue data
            # in further iterations

            when 'otto'
              socket.write("ready")

            ###
            # join
            # run when user enters 'waiting for player' in menu
            # loads player into queue

            when 'join'
              socket.write("setup|#{@players.size % 2}")
              @players[user] = ["Temp", nil, "green"]

            ###
            # setup
            # run when queue 'OK's' a two-player match
            # sets up game structure, passes to player
            
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

            ###
            # setup_save
            # used when player selects 'load game' from player
            # attempts to load a game from database; if not, 
            # joins the match that the other player readied from 'save game'

            when 'setup_save'
              @players[user] = [data[1], nil, nil]
              results = @db_ctrl.get_saved_game(data[1])
              if results != nil
                resultdata = results.split("|") 
                @games[@count] = { player_1: resultdata[0],
                     player_2: resultdata[1],
                     player_1_color: resultdata[2],
                     player_2_color: resultdata[3],
                     player_1_score: 0,
                     player_2_score: 0,
                     saved_game: resultdata[4],
                     game_type: resultdata[6],
                     last_turn: resultdata[5],
                     tiles: [] }
              end
              if @players.size % 2 == 0
                @players.each do |player, data|
                  if player != user && data[1] == nil
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
                                @games[game][:game_type],
                                @games[game][:last_turn],
                                @games[game][:saved_game]].join('|')
                    socket.write(response)
                  end
                end
                @count += 1
              else
                socket.write("waiting")
              end

            ###
            # load_save
            # loads save data in game controller
            # requested on game startup

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
                            @games[game][:game_type],
                            @games[game][:last_turn],
                            @games[game][:saved_game]].join('|')
                socket.write(response)
              else
                response = "waiting"
                socket.write(response)
              end

            ###
            # load
            # loads game data in game controller
            # requested on game startup

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

            ###
            # wait
            # responds when user is waiting for updates
            # if update is available, is written to user
            # if not, waiting is responded to user

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

            ###
            # win
            # logs win for player
            # dependent on game_type

            when 'win'
              # puts "win: #{data[1]} || #{data[2]}"
              if data[2] == 'classic'
                @db_ctrl.increment_classic_win(data[1])
              elsif data[2] == 'otto'
                 @db_ctrl.increment_otto_wins(data[1])
              end 

            ###
            # tie
            # logs ties for player
            # dependent on game_type

            when 'tie'
              # puts "tie: #{data[1]} || #{data[2]}"
              if data[2] == 'classic'
                @db_ctrl.increment_classic_ties(data[1])
              elsif data[2] == 'otto'
                 @db_ctrl.increment_otto_ties(data[1])
              end 

            ###
            # loss
            # logs loss for player
            # dependent on game_type

            when 'loss'
              # puts "loss: #{data[1]} || #{data[2]}"
              if data[2] == 'classic'
                @db_ctrl.increment_classic_loss(data[1])
              elsif data[2] == 'otto'
                 @db_ctrl.increment_otto_loss(data[1])
              end 

            ###
            # skip
            # logs player skip action
            # attributed as a game action

            when 'skip'
              game = @players[user][1]
              if @games[game][:player_1] == @players[user][0]
                role = "A"
              else
                role = "B"
              end
              entry = role + "%S%" + @games[game][:tiles].length.to_s
              if !@games[game][:tiles].include?("A%S%" + @games[game][:tiles].length.to_s) && !@games[game][:tiles].include?("B%S%" + @games[game][:tiles].length.to_s)
                instantiate_game_action(entry, game, socket)
              end

            ###
            # concede
            # logs player concede action
            # attributed as a game action

            when 'concede'
              game = @players[user][1]
              if @games[game][:player_1] == @players[user][0]
                role = "A"
              else
                role = "B"
              end
              entry = role + "%C%" + @games[game][:tiles].length.to_s
              if !@games[game][:tiles].include?("A%C%" + @games[game][:tiles].length.to_s) && !@games[game][:tiles].include?("B%C%" + @games[game][:tiles].length.to_s)
                instantiate_game_action(entry, game, socket)
              end

            ###
            # save
            # logs game state, users in game
            # alerts other user that game is in 'saved' mode

            when 'save'
              game = @players[user][1]
              if @games[game][:player_1] == @players[user][0]
                role = "A"
                player = @games[game][:player_1]
              else
                role = "B"
                player = @games[game][:player_2]
              end
              entry = role + "%V%" + @games[game][:tiles].length.to_s
              @db_ctrl.insert_saved_game(player, [data[2], data[3], data[4], data[5], data[6], data[7], data[8]].join("|"))
              if !@games[game][:tiles].include?("A%V%" + @games[game][:tiles].length.to_s) && !@games[game][:tiles].include?("B%V%" + @games[game][:tiles].length.to_s)
                instantiate_game_action(entry, game, socket)
              end

            ### 
            # move
            # logs last standard movement action

            when 'move'
              move = data[2]
              game = @players[user][1]
              if @games[game][:player_1] == @players[user][0]
                role = "A"
              else
                role = "B"
              end
              entry = role + "%" + move.to_s
              if !@games[game][:tiles].include?("A%" + move.to_s) && !@games[game][:tiles].include?("B%" + move.to_s)
                instantiate_game_action(entry, game, socket)
              end

            ###
            # unknown
            # debugger

            else
              puts "ERROR, bad data received: #{data[0]}"
          end
        rescue
      end
    end
  end
  rescue EOFError
    # System handling for player leaving game
    # Clears player data to prevent synch issues
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

### 
# reconstruct_grid
# Helper function to debug grid passed in system.

def reconstruct_grid(gridipt)
  gridData = gridipt.split("&")
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

### 
# print_grid
# Helper function to debug grid passed in system

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

###
# instantiate_game_action
# Refactored process for handling game actions

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
  socket.write(response)
end

### 
# Initialisation of server based on initial data passed

server = ARGV[0] || "127.0.0.1"
port = ARGV[1] || 8080

supervisor = Server.supervise(server, port.to_i)
trap("INT") do
  supervisor.terminate
  exit
end

sleep
