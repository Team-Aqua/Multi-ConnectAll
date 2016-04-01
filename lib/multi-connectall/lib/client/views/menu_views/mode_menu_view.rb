module Views
  class ModeMenuView

    ##
    # View structure for P1vP2 or PvAI selection.

    def initialize(window, controller)
      @window = window
      @controller = controller
      @button_width = 235

      @buttonPvP = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_play_player.png"), (@window.width/2)-(@button_width/2), 125, 100, lambda { @controller.pvp_button_click }, Gosu::Image.new("assets/images/btn_play_player_click.png"))
      @buttonPvAi = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_play_ai.png"), (@window.width/2)-(@button_width/2), 195, 100, lambda { @controller.pvai_button_click }, Gosu::Image.new("assets/images/btn_play_ai_click.png"))
      @buttonReturn = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_return_xl.png"), (@window.width/2)-(@button_width/2), 257, 100, lambda { @controller.return_menu }, Gosu::Image.new("assets/images/btn_return_xl_click.png"))
      @menu_click_sound = Gosu::Sample.new(@window, "assets/sounds/menu_click.mp3")
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @buttonPvAi.draw
      @buttonPvP.draw
      @buttonReturn.draw
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def update
      @buttonPvAi.update
      @buttonPvP.update
      @buttonReturn.update
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def clicked
      @menu_click_sound.play(0.7, 1, false)
      @buttonPvAi.clicked
      @buttonPvP.clicked
      @buttonReturn.clicked
    end

    ##
    # Gosu implementation
    # Inputs: key
    # Outputs: none

    def button_down(key)
    end

  end
end