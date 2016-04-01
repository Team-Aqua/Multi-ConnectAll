module Views

  ##
  # GameFooterView is the 'footer view' of the game menu.
  # Contains a 'concede' and 'skip' options in-game, for the user.

  class GameFooterView
    def initialize(window, controller, game_state_model)
      @window = window
      @controller = controller
      @game_state_model = game_state_model

      @status_buttons = Array.new
      @skip = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_skip.png", :tileable => true), 169, 470 + 50, 35, lambda { @controller.skip_button_click }, Gosu::Image.new("assets/images/btn_skip_click.png", false))
      @concede = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_concede.png", :tileable => true), 169, 470 + 10, 35, lambda { @controller.concede_button_click }, Gosu::Image.new("assets/images/btn_concede_click.png", :tileable => true))
      @status_buttons << @skip
      @status_buttons << @concede
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none
    
    def draw
      @status_buttons.each do |i|
        i.draw
      end
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def update
      @status_buttons.each do |i|
        i.update
      end
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def clicked
      @status_buttons.each do |i|
        i.clicked
      end
    end
    
  end
end