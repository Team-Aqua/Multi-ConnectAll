module Controllers
  class GameCtrl
    attr_accessor :view, :window, :game_state_model, :alert_view, :state

    ## 
    # Main controller for game interactions
    # Uses the game_state_model as reference to 
    # identify actions and processes to take.

    def initialize(window, game_state_model)
      @window = window
      @game_state_model = game_state_model
      @view = Views::GameView.new(@window, self, @game_state_model)
      @menu_click_sound = Gosu::Sample.new(@window, "assets/sounds/menu_click.mp3")
      @win_sound = Gosu::Sample.new(@window, "assets/sounds/cheer_win.mp3")
      @alert_view = nil
      @player_moved = false
      GameControllerContracts.invariant(self)
    end

    ## 
    # Resets match, clears open alertviews
    # Forces model resets before resetting game.
    # Inputs: none
    # Outputs: none

    def reset_match
      GameControllerContracts.invariant(self)
      @menu_click_sound.play(0.7, 1, false)
      @game_state_model::state = :active
      @game_state_model::grid.reset
      @game_state_model::player_turn_state = 0
      @view::control.build_red_grid
      alert_close
      GameControllerContracts.post_reset_match(self)
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def button_down(key)
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @view.draw
      if @alert_view != nil
        @alert_view.draw
      end
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def update
      @view.update
      if @alert_view != nil
        @alert_view.update
      else
        if @player_moved == false
          @player_moved = @game_state_model::players[@game_state_model::player_turn_state].make_move{ |x, player_num, player_color, delay|
            @view::control.disable_control_on_player
            @view::grid.animate_tile_drop(x, player_color, delay) {
              @view::control.enable_control_on_player
              @game_state_model::grid.add_tile(x, player_num);
              check_winner_winner;  
              @view::control.disable_control_on_AI;
              @game_state_model.toggle_player_turn_state;
              # Server interaction
              # puts "Height: #{@game_state_model::grid.column_depth(x)}"
              @window.client.send_message(['move',@game_state_model::player_role,"#{x}%#{@game_state_model::grid.column_depth(x)}"].join('|'))
              @view::control.check_available; 
              @player_moved = false; 
              }
            }
        end
      end
      begin
      @window.client.send_message('wait')
      if data = @window.client.read_message ## maybe put interaction somewhere else
        #puts "Data Read: #{data}"
        data = data.split('|')
        if data && !data.empty?
          if data[0] == "game"
            position = data.last
            # puts "Position: #{position} |||"
            position = position.split('%')
            # first el: A/B , second el: X , third el: Y
            # puts position
            puts "val: #{position[0]} || #{game_state_model::player_role} || #{position[1]}"
            if (position[0] == 'A' and @game_state_model::player_role == 1) or (position[0] == 'B' and @game_state_model::player_role == 0)
              ypos = @game_state_model::grid.column_depth(position[1].to_i)
              puts "val: #{ypos} || relative position: #{position[2]}"
              if ypos > position[2].to_i and @player_moved == false
                @player_moved = true;
                xpos = position[1].to_i
                @game_state_model::players[@game_state_model::player_turn_state].set_move(xpos)
                @player_moved = @game_state_model::players[@game_state_model::player_turn_state].make_move{ |xpos, player_num, player_color, delay|
                  @view::control.disable_control_on_player
                  @view::grid.animate_tile_drop(xpos, player_color, delay) {
                    @view::control.enable_control_on_player
                    @game_state_model::grid.add_tile(xpos, player_num);
                    check_winner_winner;  
                    @view::control.disable_control_on_AI;
                    @game_state_model.toggle_player_turn_state;
                    # Server interaction
                    # puts "Height: #{@game_state_model::grid.column_depth(x)}"
                    @view::control.check_available; 
                    @player_moved = false; 
                    }
                  }
              end 
            end
          end
        end
      end
      rescue
      end
            # puts data
            # data = data.split('|')
            # if data && !data.empty?
            #   if data[0] == "waiting"
            #     @state = :waiting
            #     @orange = "Player 1"
            #     @blue = "Player 2"
            #     @orange_score = 0
            #     @blue_score = 0
            #     @move = false
            #     @turn = false
            #     @board.tiles = []
            #     @board.square_animations = []
            #   elsif data[0] == "game"
            #     if @state != :gameover
            #       @state = :running
            #       @orange = data[1]
            #       @blue = data[2]
            #       @orange_score = data[3]
            #       @blue_score = data[4]
            #       if !data[5].nil?
            #         @board.tiles = []
            #         data[5..-1].each do |tile|
            #           @board.tiles << tile
            #         end
            #       end
            #     end
            #     if (@orange_score.to_i >= 150 || @blue_score.to_i >= 150) &&
            #        (@orange_score.to_i - @blue_score.to_i).abs > 15
            #       @turn = false
            #       @state = :gameover
            #       if @timer == nil
            #         @timer = Timer.new
            #       else
            #         @timer.update
            #         if @timer.seconds > 15
            #           close
            #         end
            #       end
            #     else
            #       if (@board.tiles.size % 2 == 0 && @orange == NAME) || (@board.tiles.size % 2 != 0 && @blue == NAME)
            #         @turn = true
            #       else
            #         @turn = false
            #       end
            #     end
            #   end
            # end
    end

    ##
    # Checks for winner given game state, or for tie
    # If winner or tie is present, handles processes
    # Inputs: none
    # Outputs: none

    def check_winner_winner
      @game_state_model::game_mode_logic.check_for_winner
      if @game_state_model::state == :win
        @win_sound.play(0.7, 1, false)
        @game_won = true
        @alert_view = Views::WinAlertView.new(@window, self, @game_state_model::players[@game_state_model::winner].player_color)
        @game_state_model::players[@game_state_model::winner].increment_win_score
        @window.client.send_message(['win', @game_state_model::player_role].join('|'))
        
      end  
      if @game_state_model::state == :tie
        @win_sound.play(0.7, 1, false)
        @game_won = true
        @alert_view = Views::WinAlertView.new(@window, self, 'tie')
        @window.client.send_message('tie')
      end 
    end

    ##
    # Gosu implementation
    # Forces alertview check if alertview is open; prevents inputs outside of alertview if true
    # Inputs: none
    # Outputs: none

    def clicked
      if @alert_view != nil
        @alert_view.clicked
      else
        @view.clicked
      end
    end

    ##
    # Places tile on grid,
    # Handles processing up to that point.
    # Inputs: x position
    # Outputs: none

    def place_tile(x)
      GameControllerContracts.invariant(self)
      @view::grid.animate_tile_drop(x, @game_state_model::players[player_turn].player_color, delay){@game_state_model::grid.add_tile(x, player_turn)}
      GameControllerContracts.invariant(self)
    end

    ##
    # Checks if block input is viable
    # Inputs: x position
    # Outputs: none 

    def control_button_click(x)
      GameControllerContracts.invariant(self)
      GameControllerContracts.pre_button_click(self, x)
      @view::control.disable_control_on_AI
      @game_state_model::players[@game_state_model::player_turn_state]::set_move(x)
      @view::control.check_available
      GameControllerContracts.invariant(self)
    end

    ##
    # Handles processing for 'skip' button clicked
    # If skipping is available, that player's turn is skipped
    # N/A on computer's turn
    # Inputs: none
    # Outputs: none

    def skip_button_click
      GameControllerContracts.invariant(self)
      if @game_state_model::players[@game_state_model::player_turn_state].ai == nil # if it isn't an ai currently playing
        @game_state_model.toggle_player_turn_state
        @menu_click_sound.play(0.7, 1, false)
      end
      GameControllerContracts.invariant(self)
    end

    ##
    # Handles processing for 'concede' button clicked
    # If conceding is available, that player loses
    # N/A on computer's turn
    # Inputs: none
    # Outputs: none

    def concede_button_click
      GameControllerContracts.invariant(self)
      if @game_state_model::players[@game_state_model::player_turn_state].ai == nil # if it isn't an ai currently playing
        @game_won = true
        @game_state_model.toggle_player_turn_state
        @alert_view = Views::WinAlertView.new(@window, self, @game_state_model::players[@game_state_model::player_turn_state].player_color)
        @game_state_model::players[@game_state_model::player_turn_state].increment_win_score
        @menu_click_sound.play(0.7, 1, false)
      end
      GameControllerContracts.invariant(self)
    end

    ##
    # Handles processing for 'reset' button clicked
    # Rebuilds grid and buttons
    # Inputs: none
    # Outputs: none

    def reset_button_click
      GameControllerContracts.invariant(self)
      @game_state_model::grid.reset
      @view::control.build_red_grid
      GameControllerContracts.invariant(self)
    end

    ## 
    # Opens help alert view for user
    # Inputs: none
    # Outputs: none

    def question_button_click
      GameControllerContracts.invariant(self)
      @alert_view = @help_view = Views::HelpAlertView.new(@window, self)
      @menu_click_sound.play(0.7, 1, false)
      GameControllerContracts.invariant(self)
    end

    ##
    # Closes any alert view present
    # Inputs: none
    # Outputs: none

    def alert_close
      GameControllerContracts.invariant(self)
      @menu_click_sound.play(0.7, 1, false)
      @alert_view = nil
      GameControllerContracts.invariant(self)
    end

    ##
    # Closes window
    # Currently unused
    # Inputs: none
    # Outputs: none

    def cancel_button_click
      GameControllerContracts.invariant(self)
      @window.close
    end

  end
end