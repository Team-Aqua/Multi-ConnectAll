require 'celluloid/io'
require 'celluloid/autostart'

require_relative 'server_helpers'

class Server
  include Celluloid::IO
  finalizer :shutdown

  def initialize(host, port)
    puts "Starting Server at #{host}:#{port}."
    @server = TCPServer.new(host, port)
    @players = {}
    @games = {}
    @count = 1

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
            when 'join'
              puts "writing : #{@players.size % 2}"
              socket.write("setup|#{@players.size % 2}")
            when 'setup'
              @players[user] = [data[1], nil]
              puts "playersize: #{@players[user]}"
              if @players.size % 2 == 0
                @players.each do |player, data|
                  puts "#{player} || #{data}"
                  if player != user && data[1] == nil
                    @games[@count] = { player_1: data[0],
                                       player_2: @players[user][0],
                                       player_1_score: 0,
                                       player_2_score: 0,
                                       tiles: [] }
                    @players[player][1] = @count
                    @players[user][1] = @count
                    @count += 1
                    game = @players[user][1]
                    response = ["game",
                                @games[game][:player_1],
                                @games[game][:player_2],
                                @games[game][:player_1_score],
                                @games[game][:player_2_score],
                                @games[game][:tiles]].join('|')
                    puts "Response: #{response}"
                  end
                end
              end
            when 'wait'
              if @players[user][1] != nil
                game = @players[user][1]
                response = ["game",
                            @games[game][:player_1],
                            @games[game][:player_2],
                            @games[game][:player_1_score],
                            @games[game][:player_2_score],
                            @games[game][:tiles]].join('|')
                socket.write(response)
              else
                response = "waiting"
                socket.write(response)
              end
            when 'win'
            when 'tie'
            when 'move'
              puts "Data: #{data}"
              move = data[2] #.to_i
              game = @players[user][1]
              if @games[game][:player_1] == @players[user][0]
                color = "A"
              else
                color = "B"
              end
              entry = color + "%" + move.to_s
              if !@games[game][:tiles].include?("A" + move.to_s) && !@games[game][:tiles].include?("B" + move.to_s)
                @games[game][:tiles] << entry
              # @games[game][:tiles] = entry
                #score_update = check_squares(@games[game][:tiles])
                #if color == "A"
                #  @games[game][:orange_score] += score_update
                #else
                #  @games[game][:blue_score] += score_update
                #end
              # end
                response = ["game",
                  @games[game][:player_1],
                  @games[game][:player_2],
                  @games[game][:player_1_score],
                  @games[game][:player_2_score],
                  @games[game][:tiles]].join('|')
                puts "Move Response: #{response}"
                socket.write(response)
              end
            else
              puts "Unknown: #{data[0]}"
          end
        rescue
      end
    end

      # if data && !data.empty?
      #   begin
      #     case data[0]
      #     when 'join'
      #       @players[user] = [data[1], nil]
      #       if @players.size % 2 == 0
      #         @players.each do |player, data|
      #           if player != user && data[1] == nil
      #             @games[@count] = { orange: data[0],
      #                                blue: @players[user][0],
      #                                orange_score: 0,
      #                                blue_score: 0,
      #                                tiles: [] }
      #             @players[player][1] = @count
      #             @players[user][1] = @count
      #             @count += 1
      #           end
      #         end
      #       end
      #     when 'move'
      #       move = data[2].to_i * 8 + data[1].to_i
      #       game = @players[user][1]
      #       if @games[game][:orange] == @players[user][0]
      #         color = "O"
      #       else
      #         color = "B"
      #       end
      #       entry = color + move.to_s
      #       if !@games[game][:tiles].include?("O" + move.to_s) && !@games[game][:tiles].include?("B" + move.to_s)
      #         @games[game][:tiles] << entry
      #         score_update = check_squares(@games[game][:tiles])
      #         if color == "O"
      #           @games[game][:orange_score] += score_update
      #         else
      #           @games[game][:blue_score] += score_update
      #         end
      #       end
      #       response = ["game",
      #                   @games[game][:orange],
      #                   @games[game][:blue],
      #                   @games[game][:orange_score],
      #                   @games[game][:blue_score],
      #                   @games[game][:tiles]].join('|')
      #       socket.write(response)
      #     when 'wait'
      #       if @players[user][1] != nil
      #         game = @players[user][1]
      #         response = ["game",
      #                     @games[game][:orange],
      #                     @games[game][:blue],
      #                     @games[game][:orange_score],
      #                     @games[game][:blue_score],
      #                     @games[game][:tiles]].join('|')
      #         socket.write(response)
      #       else
      #         response = "waiting"
      #         socket.write(response)
      #       end
      #     end
      #   rescue
      #   end
      # end

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

server = ARGV[0] || "127.0.0.1"
port = ARGV[1] || 1234

supervisor = Server.supervise(server, port.to_i)
trap("INT") do
  supervisor.terminate
  exit
end

sleep
