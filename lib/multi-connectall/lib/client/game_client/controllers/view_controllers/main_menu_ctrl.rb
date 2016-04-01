module Controllers
  class MenuCtrl

    ##
    # Menu controller for game state,
    # Controls high-level logic for otto/classic and PvP/PvAI

    def initialize(window, game_state_model)
      @window = window
      @game_state_model = game_state_model
      @views = [Views::MenuView.new(@window, self), Views::ModeMenuView.new(@window, self)]
      @current_view = @views.first
      @alert_view = nil
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
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
    # Prioritises alert view 
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
    # Inputs: none
    # Outputs: none

    def button_down(key)
    end

    ## 
    # Processing logic for pvp button
    # Sets model state and starts game
    # Inputs: none
    # Outputs: none

    def pvp_button_click
      @game_state_model::game_mode = :pvp
      @window.start_game
    end

    ## 
    # Processing logic for pvai button
    # Sets model state and starts game
    # Inputs: none
    # Outputs: none

    def pvai_button_click
      @game_state_model::game_mode = :pvai
      @window.start_game
    end

    ## 
    # Processing logic for classic mode button
    # Sets model state and starts game
    # Inputs: none
    # Outputs: none

    def classic_button_click
      @game_state_model::game_type = :classic
      @current_view = @views[1]
    end

    ## 
    # Processing logic for otto mode button
    # Sets model state and starts game
    # Inputs: none
    # Outputs: none

    def otto_button_click
      @game_state_model::game_type = :otto
      @current_view = @views[1]
    end

  end
end