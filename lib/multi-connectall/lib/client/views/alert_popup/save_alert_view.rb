module Views
  class SaveAlertView

    ## 
    # Called at game state
    # Used to show how to play ConnectAll

    def initialize(window, controller)
      @window = window
      @controller = controller
      @menu_click_sound = Gosu::Sample.new(@window, "assets/sounds/menu_click.mp3")
      @help = Gosu::Image.new("assets/images/item_game_saved.png", :tileable => false)
      @return = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_return_sm.png"), 95, 335, 200, lambda { @menu_click_sound.play(0.7, 1, false); @window.return_to_type_menu }, Gosu::Image.new("assets/images/btn_return_sm_click.png", :tileable => false))
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @help.draw(20, 10, 100)
      @return.draw
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none
    
    def update
      @return.update
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none
    
    def clicked
      @return.clicked
    end

  end
end