module Views
  class ExitAlertView

    ## 
    # Called at game state
    # Used to show how to play ConnectAll

    def initialize(window, controller)
      @window = window
      @controller = controller
      @help = Gosu::Image.new("assets/images/item_quit_game.png", :tileable => false)
      @cancel = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_cancel_dark.png"), 290, 20, 100, lambda { @controller.alert_close }, Gosu::Image.new("assets/images/btn_cancel_dark.png", :tileable => false))
      @quit = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_quit.png"), 95, 295, 200, lambda { @window.close }, Gosu::Image.new("assets/images/btn_quit_click.png", :tileable => false))
      @save = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_save.png"), 95, 335, 200, lambda { @controller.save_game; @window.close }, Gosu::Image.new("assets/images/btn_save_click.png", :tileable => false))
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @help.draw(20, 10, 100)
      @cancel.draw
      @quit.draw
      @save.draw
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none
    
    def update
      @cancel.update
      @quit.update
      @save.update
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none
    
    def clicked
      @cancel.clicked
      @quit.clicked
      @save.clicked
    end

  end
end