module Views
  class WaitingAlertView

    ##
    # Used for queuing multiplayer matches

    def initialize(window, controller)
      @window = window
      @controller = controller
      @header = Gosu::Image.new("assets/images/header_waiting.png", :tileable => false)
      # @cancel = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_cancel_dark.png"), 312, 15, 101, lambda { @window.start_menu }, Gosu::Image.new("assets/images/btn_cancel_dark.png", :tileable => false))
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @header.draw(0, 0, 100)
      # @cancel.draw
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none
    
    def update
      # @cancel.update
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none
    
    def clicked
      # @cancel.clicked
    end

  end
end