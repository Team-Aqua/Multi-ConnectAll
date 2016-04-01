module Views
  class ConnectInstructionsAlertView

    ## 
    # Called at main menu
    # Used to identify how to play ConnectAll classic mode

    def initialize(window, controller)
      @window = window
      @controller = controller
      @help = Gosu::Image.new("assets/images/item_what_is_classic_mode.png", :tileable => false)
      @cancel = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_cancel_dark.png"), 450, 35, 100, lambda { @controller.alert_close }, Gosu::Image.new("assets/images/btn_cancel_dark.png", :tileable => false))
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