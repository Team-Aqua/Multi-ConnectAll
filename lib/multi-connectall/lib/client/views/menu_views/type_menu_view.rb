module Views
  class TypeMenuView

    ##
    # Main menu - first menu interaction view
    # Lets users select between classic or OTTO mode,
    # and explanations for both, as well as how to play ConnectAll.

    def initialize(window, controller)
      @window = window
      @controller = controller
      @button_width = 235

      @buttonClassic = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_classic.png"), (@window.width/2)-(@button_width/2) - 25, 125, 100, lambda { @controller.to_classic_multiplayer_menu }, Gosu::Image.new("assets/images/btn_classic_click.png"))
      @buttonOtto = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_otto.png"), (@window.width/2)-(@button_width/2) - 25, 195, 100, lambda { @controller.to_otto_multiplayer_menu }, Gosu::Image.new("assets/images/btn_otto_click.png"))
      @buttonLoadSave = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_load_save.png"), (@window.width/2)-(@button_width/2) - 25, 260, 100, lambda { @controller.to_save_menu }, Gosu::Image.new("assets/images/btn_load_save_click.png"))
      @buttonLeaderboards = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_leaderboards.png"), 365, 260, 100, lambda { @controller.alert_leaderboard })
      @questionClassic = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_classic_question.png"), 365, 125, 100, lambda { @controller.question_classic_button_click }, Gosu::Image.new("assets/images/btn_classic_question_click.png"))
      @questionOtto = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_question.png"), 365, 195, 100, lambda { @controller.question_otto_button_click }, Gosu::Image.new("assets/images/btn_question_click.png"))

      @helpOtto = Gosu::Image.new("assets/images/item_otto_mode.png", :tileable => false)
      @helpClassic = Gosu::Image.new("assets/images/item_what_is_classic_mode.png", :tileable => false)

      @menu_click_sound = Gosu::Sample.new(@window, "assets/sounds/menu_click.mp3")
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @buttonClassic.draw
      @buttonOtto.draw
      @buttonLoadSave.draw
      @buttonLeaderboards.draw
      @questionOtto.draw
      @questionClassic.draw
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def update
      @buttonClassic.update
      @buttonOtto.update
      @questionOtto.update
      @questionClassic.update
      @buttonLoadSave.update
      @buttonLeaderboards.update

    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def clicked
      @menu_click_sound.play
      @buttonClassic.clicked
      @buttonOtto.clicked
      @questionOtto.clicked
      @questionClassic.clicked
      @buttonLoadSave.clicked
      @buttonLeaderboards.clicked
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def button_down(id)
    end
    
  end
end