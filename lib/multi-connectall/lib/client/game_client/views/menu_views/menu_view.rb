module Views
  class MenuView

    ## 
    # The generic backbone for all menus.
    # Contains header and background details.

    def initialize(window, controller)
      @window = window
      @controller = controller

      @header = Gosu::Image.new("assets/images/header_connectall.png", :tileable => true)
      @background = Gosu::Image.new("assets/images/bg_blue.png", :tileable => false)
      @font = Gosu::Font.new(@window, "assets/fonts/Roboto-Bold.ttf", 20)

    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @header.draw(0, 0, 10)
      @background.draw(0,0,9)
    end

    ##
    # Gosu implementation
    # Inputs: key input
    # Outputs: none

    def button_down(key)
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def update
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def clicked
    end

  end
end