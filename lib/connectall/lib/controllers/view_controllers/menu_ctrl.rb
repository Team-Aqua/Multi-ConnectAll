module Controllers
  class MenuCtrl
    attr_reader :game_state_model, :window, :views 
    ##
    # Menu controller for game state,
    # Controls low-level logic for otto/classic and PvP/PvAI, and player colors/names
    
    def initialize(window, game_state_model)
      @window = window
      @game_state_model = game_state_model
      @menu_background = Views::MenuView.new(@window, self)
      @views = [Views::TypeMenuView.new(@window, self), Views::ModeMenuView.new(@window, self)]
      @current_view = @views.first
      @alert_view = nil
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @menu_background.draw
      @current_view.draw
      if @alert_view != nil
        @alert_view.draw
      end
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def update
      @current_view.update
      if @alert_view != nil
        @alert_view.update
      end
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def clicked
      if @alert_view != nil
        @alert_view.clicked
      else
        @current_view.clicked
      end
    end

    ##
    # Gosu implementation
    # Inputs: key
    # Outputs: none

    def button_down(key)
      MenuControllerContracts.invariant(self)
      @current_view.button_down(key)
      MenuControllerContracts.invariant(self)
    end

    ## 
    # Setup player logic for player color and name, then starts game
    # Inputs: player 1 color, player 2 color, player 1 name, player 2 game
    # Outputs: none

    def player_rdy(color, player2_color: nil, player1_name: "Player 1", player2_name: "Player 2", ai_level:nil)
      MenuControllerContracts.invariant(self)
      @game_state_model::players.push(Models::RealPlayer.new(1, color, player1_name))
      if player2_color != nil
        @game_state_model::players.push(Models::RealPlayer.new(2, player2_color, player2_name))
      else
        if @game_state_model::game_type == :classic
          @game_state_model::players.push(Models::AIPlayer.new(2, 'black', GameLogic::ClassicAI.new(@game_state_model, ai_level), "Roboto"))
        else
        @game_state_model::players.push(Models::AIPlayer.new(2, 'black', GameLogic::OttoAI.new(@game_state_model, ai_level), "Roboto"))
        end
      end
      @window.start_game
      MenuControllerContracts.invariant(self)
    end

    ## 
    # Setup structure for 2p game
    # Redirects view to third menu view
    # Inputs: none
    # Outputs: none

    def pvp_button_click
      MenuControllerContracts.invariant(self)
      @game_state_model::game_mode = :pvp
      @game_state_model::num_of_players = 2
      @current_view = Views::PlayerMenuView.new(@window, self, @game_state_model)
      MenuControllerContracts.invariant(self)
    end

    ## 
    # Setup structure for 1p game
    # Redirects view to third menu view
    # Inputs: none
    # Outputs: none

    def pvai_button_click
      MenuControllerContracts.invariant(self)
      @game_state_model::game_mode = :pvai
      @game_state_model::num_of_players = 1
      @current_view = Views::PlayerMenuView.new(@window, self, @game_state_model)
      MenuControllerContracts.invariant(self)
    end

    ## 
    # Setup structure for classic game
    # Redirects view to second menu view
    # Inputs: none
    # Outputs: none

    def classic_button_click
      MenuControllerContracts.invariant(self)
      @game_state_model::game_type = :classic
      @game_state_model::game_mode_logic = GameLogic::ClassicRules.new(@game_state_model)
      @current_view = @views[1]
      MenuControllerContracts.invariant(self)
    end

    ## 
    # Setup structure for otto game
    # Redirects view to second menu view
    # Inputs: none
    # Outputs: none
    
    def otto_button_click
      MenuControllerContracts.invariant(self)
      @game_state_model::game_type = :otto
      @game_state_model::game_mode_logic = GameLogic::OttoRules.new(@game_state_model)
      @current_view = @views[1]
      MenuControllerContracts.invariant(self)
    end

    ## 
    # Opens AlertView for Otto mode
    # Inputs: none
    # Outputs: none
    
    def question_otto_button_click
      MenuControllerContracts.invariant(self)
      @alert_view = @help_view = Views::OttoInstructionsAlertView.new(@window, self)
      MenuControllerContracts.invariant(self)
    end

    ## 
    # Opens AlertView for ConnectAll
    # Inputs: none
    # Outputs: none

    def question_help_click
      MenuControllerContracts.invariant(self)
      @alert_view = @help_view = Views::ConnectAllAlertView.new(@window, self)
      MenuControllerContracts.invariant(self)
    end

    ## 
    # Opens AlertView for ConnectAll
    # Inputs: none
    # Outputs: none

    def question_classic_button_click
      MenuControllerContracts.invariant(self)
      @alert_view = @help_view = Views::ConnectInstructionsAlertView.new(@window, self)
      MenuControllerContracts.invariant(self)
    end

    ## 
    # Closes any open alertview
    # Inputs: none
    # Outputs: none

    def alert_close
      MenuControllerContracts.invariant(self)
      @alert_view = nil
      MenuControllerContracts.invariant(self)
    end

    ## 
    # Menu controller to return to 'select players' menu
    # Inputs: none
    # Outputs: none

    def return_to_mode_menu
      MenuControllerContracts.invariant(self)
      @current_view = @views[1]
      MenuControllerContracts.invariant(self)
    end

    ## 
    # Menu controller to return to 'select game type' menu
    # Inputs: none
    # Outputs: none
    
    def return_menu
      MenuControllerContracts.invariant(self)
      @current_view = @views[0]
      MenuControllerContracts.invariant(self)
    end
    

  end
end