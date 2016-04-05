module Views
  class WaitingMenuAlertView

    ## 
    # Called at main menu
    # Shows details on how to play OTTO mode

    def initialize(window, controller)
      @window = window
      @controller = controller
      @help = Gosu::Image.new("assets/images/item_waiting_player_menu.png", :tileable => false)
      # key: cancel must run @controller.exit_queue(which queue) later
      @cancel = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_back.png"), 450, 35, 100, lambda { @controller.to_view_menu }, Gosu::Image.new("assets/images/btn_back_click.png", :tileable => false))
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @help.draw(30, 20, 100)
      @cancel.draw
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none
    
    def update
      @cancel.update
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none
    
    def clicked
      @cancel.clicked
    end

  end
end