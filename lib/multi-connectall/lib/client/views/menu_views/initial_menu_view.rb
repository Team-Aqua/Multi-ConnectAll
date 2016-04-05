module Views
  class InitialMenuView

    ##
    # View structure for P1vP2 or PvAI selection.

    def initialize(window, controller)
      @window = window
      @controller = controller
      @button_width = 235

      @buttonLogin = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_login_server.png"), 92.5, 125, 100, lambda { @controller.to_login_server }, Gosu::Image.new("assets/images/btn_login_server_click.png"))
      @buttonClassicAI = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_classic_ai.png"), 92.5, 190, 100, lambda { @controller.start_classic_ai }, Gosu::Image.new("assets/images/btn_classic_ai_click.png"))
      @buttonOttoAI = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_otto_ai.png"), 92.5, 255, 100, lambda { @controller.start_otto_ai }, Gosu::Image.new("assets/images/btn_otto_ai_click.png"))
      @buttonHelp = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_help_lg.png"), 92.5, 320, 100, lambda { @controller.question_help_click }, Gosu::Image.new("assets/images/btn_help_lg_click.png"))
      
      @buttonHelpLogin = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_help_login.png"), 386, 125, 100, lambda { @controller.question_login_button_click }, Gosu::Image.new("assets/images/btn_help_login_click.png"))
      @buttonHelpClassicAI = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_help_classic_ai.png"), 386, 190, 100, lambda {  @controller.question_classic_button_click }, Gosu::Image.new("assets/images/btn_help_classic_ai_click.png"))
      @buttonHelpOttoAI = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_help_otto_ai.png"), 386, 255, 100, lambda {  @controller.question_otto_button_click }, Gosu::Image.new("assets/images/btn_help_otto_ai_click.png"))

      @menu_click_sound = Gosu::Sample.new(@window, "assets/sounds/menu_click.mp3")
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @buttonLogin.draw
      @buttonClassicAI.draw
      @buttonOttoAI.draw
      @buttonHelp.draw

      @buttonHelpLogin.draw
      @buttonHelpClassicAI.draw
      @buttonHelpOttoAI.draw
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def update
      @buttonLogin.update
      @buttonClassicAI.update
      @buttonOttoAI.update
      @buttonHelp.update

      @buttonHelpLogin.update
      @buttonHelpClassicAI.update
      @buttonHelpOttoAI.update
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def clicked
      @menu_click_sound.play(0.7, 1, false)
      @buttonLogin.clicked
      @buttonClassicAI.clicked
      @buttonOttoAI.clicked
      @buttonHelp.clicked

      @buttonHelpLogin.clicked
      @buttonHelpClassicAI.clicked
      @buttonHelpOttoAI.clicked
    end

    ##
    # Gosu implementation
    # Inputs: key
    # Outputs: none

    def button_down(key)
    end

  end
end