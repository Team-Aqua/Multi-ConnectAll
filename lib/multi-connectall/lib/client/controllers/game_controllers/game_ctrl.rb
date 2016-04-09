module Controllers
  class GameCtrl
    attr_accessor :view, :window, :game_state_model, :alert_view, :state, :data_loaded

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
      
      # puts "#{@game_state_model::game_mode}"
      if @game_state_model::game_mode != :pvai
        @alert_view = Views::WaitingAlertView.new(@window, self)
      else
        @alert_view = nil
      end

      @player_moved = false
      @data_loaded = false
      @skip_run = false
      @skip_pos = 0
      @concede_run = false
      @concede_pos = 0

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
          move_block
        end
      end
      if @game_state_model::game_mode != :pvai
        toggle_multiplayer_controls
        begin
        send_sync_message
        read_message
        rescue
        end
      end
    end

    ##
    # Logic for placing block
    # Refactored for multiplayer functionality

    def move_block(self_proc = false)
      @player_moved = @game_state_model::players[@game_state_model::player_turn_state].make_move{ |x, player_num, player_color, delay|
        @view::control.disable_control_on_player
        @view::grid.animate_tile_drop(x, player_color, delay) {
          @view::control.enable_control_on_player
          @game_state_model::grid.add_tile(x, player_num);
          check_winner_winner;  
          @view::control.disable_control_on_AI;
          @game_state_model.toggle_player_turn_state;
          @view::control.check_available; 
          if self_proc == false
            @window.client_network_com.move(x, @current_universal_game_state_model)
            # @window.client_network_com.send_message(['move',@window.game_state_model::player_role,"#{x}%#{@window.game_state_model::grid.column_depth(x)}"].join('|'))
          end
          @player_moved = false; 
          @game_state_model::turn_count += 1
          }
        }
    end

    ## 
    # Sends signal to server depending on what is required
    # For initial sync - load is required
    # For in-game - wait is required

    def send_sync_message
      if @data_loaded == false 
        write_message('load')
      else
        write_message('wait')
      end
    end

    ##
    # Generic write signal
    # Used for sending messages to server
    
    def write_message(message)
      @window.client_network_com.send_message(message)
    end

    ##
    # Reads server message
    # Possible states:
    # 'game' - standard game logic - either new move or old move placed.
    # 'load' - new game logic - loads other player info

    def read_message
      if data = @window.client_network_com.read_message ## IMPORTANT: blocks until message is received
        puts "Data Read: #{data}"
      end
      #   data = data.split('|')
      #   if data && !data.empty?
      #     if data[0] == "game"
      #       position = data.last
      #       puts "Position: #{position} |||"
      #       position = position.split('%')
      #       if (position[0] == 'A' and @game_state_model::player_role == 1) or (position[0] == 'B' and @game_state_model::player_role == 0)
      #         puts "Fixed length: #{data.length - 7} || Player turn: #{@game_state_model::turn_count}"
      #         if position[1] == 'S'
      #           if (@game_state_model::turn_count < (data.length - 7)) # ((position[2] == '0' and @game_state_model::player_role == 1) or (position[1] == '1' and @game_state_model::player_role == 0)) and 
      #             # puts "judge"
      #             @view::control.enable_control_on_player
      #             skip_logic
      #             return
      #           else 
      #             return
      #           end
      #         elsif position[1] == 'C' 
      #           if (@game_state_model::turn_count < (data.length - 7))
      #             # puts "jury"
      #             concede_logic('other')
      #             return
      #           else 
      #             return
      #           end
      #         elsif position[1] == 'V' 
      #           puts "conceding!"
      #           save_logic
      #           return
      #         else
      #           ypos = @game_state_model::grid.column_depth(position[1].to_i)
      #           # puts "val: #{ypos} || relative position: #{position[2]}"
      #           if ypos > position[2].to_i and @player_moved == false
      #             @player_moved = true;
      #             xpos = position[1].to_i
      #             @game_state_model::players[@game_state_model::player_turn_state].set_move(xpos)
      #             move_block(self_proc: true)
      #           end 
      #         end
      #       end
      #     elsif data[0] == "load"
      #       @data_loaded = true
      #       @alert_view = nil
      #       if @game_state_model::player_role == 0
      #         @game_state_model::players[1]::name = data[2]
      #         @game_state_model::players[1]::player_color = data[4] 
      #         @game_state_model::players[1]::score = data[6].to_i
      #       elsif @game_state_model::player_role == 1
      #         @game_state_model::players[0]::name = data[1]
      #         @game_state_model::players[0]::player_color = data[3] 
      #         @game_state_model::players[0]::score = data[5].to_i
      #       end
      #     end
      #   end
      # end
    end

    ##
    # Sets multiplayer functions depending on whose turn it is

    def toggle_multiplayer_controls
      # puts "turn state: #{@game_state_model::player_turn_state}, player role: #{@game_state_model::player_role}"
      if (@game_state_model::player_turn_state != @game_state_model::player_role) 
        if (@view::control.control_disabled == false)
          @view::control.disable_control_on_player
        end
      elsif (@game_state_model::player_turn_state == @game_state_model::player_role) 
        if (@view::control.control_disabled == true)
          @view::control.enable_control_on_player
        else
          #puts "SIGH"
        end
      end
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
        if @game_state_model::winner == @game_state_model::player_role
          @window.client_network_com.send_win
        else
          @window.client_network_com.send_loss
        end
      end  
      if @game_state_model::state == :tie
        @win_sound.play(0.7, 1, false)
        @game_won = true
        @alert_view = Views::WinAlertView.new(@window, self, 'tie')
        @window.client_network_com.send_tie
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
      # if @skip_run == false
      #   @skip_run = true
      #   if (@game_state_model::players[@game_state_model::player_turn_state].ai == nil) and (@game_state_model::player_turn_state == @game_state_model::player_role) # if it isn't an ai currently playing
      #     write_message(['skip', @game_state_model::player_role].join('|'))
      #     skip_logic
      #     @menu_click_sound.play(0.7, 1, false)
      #   end
      #   @skip_run = false
      # end
      GameControllerContracts.invariant(self)
    end      

    def skip_logic
      # @game_state_model.toggle_player_turn_state
      # @game_state_model::turn_count += 1
    end

    def save_logic
      GameControllerContracts.invariant(self)
      @alert_view = @help_view = Views::SaveAlertView.new(@window, self)
      @menu_click_sound.play(0.7, 1, false)
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
        # concede_logic('self')
        # write_message(['concede', @game_state_model::player_role].join('|'))
        @menu_click_sound.play(0.7, 1, false)
      end
      GameControllerContracts.invariant(self)
    end

    def concede_logic(lost)
      # @game_won = true
      # # @game_state_model.toggle_player_turn_state
      # if (lost == 'self')
      #   if (@game_state_model::player_role == 0)
      #     winner = 1
      #   else
      #     winner = 0
      #   end
      # else 
      #   winner = @game_state_model::player_role
      # end
      # @alert_view = Views::WinAlertView.new(@window, self, @game_state_model::players[winner].player_color)
      # @game_state_model::players[winner].increment_win_score
      # @game_state_model::turn_count += 1
    end

    ##
    # Handles processing for 'reset' button clicked
    # Rebuilds grid and buttons
    # Inputs: none
    # Outputs: none

    def reset_button_click
      GameControllerContracts.invariant(self)
      # @game_state_model::grid.reset
      # @view::control.build_red_grid
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

    def quit_alert
      GameControllerContracts.invariant(self)
      @alert_view = @help_view = Views::ExitAlertView.new(@window, self)
      @menu_click_sound.play(0.7, 1, false)
      GameControllerContracts.invariant(self)
    end

    def save_game
      # puts "Game save process here."
      # write_message(['save', @game_state_model::player_role].join('|'))
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