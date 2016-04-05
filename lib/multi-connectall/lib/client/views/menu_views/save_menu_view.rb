module Views
  class SaveMenuView

    ##
    # View structure for P1vP2 or PvAI selection.

    def initialize(window, controller)
      @window = window
      @controller = controller
      @button_width = 235
      @font = Gosu::Font.new(@window, "assets/fonts/HN_Bd.ttf", 32)

      @header_color = Gosu::Image.new("assets/images/header_save.png", :tileable => false)

      @text_fields = Array.new(1) { |index| TextField.new(@window, @font, 42.5, 175, '', 'large') }

      @button_return = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_return_lg.png"), 140, 345, 100, lambda { @controller.to_type_menu }, Gosu::Image.new("assets/images/btn_return_lg_click.png")) 
      @button_rdy = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_start.png"), 290, 345, 100, lambda { @controller.to_type_menu }, Gosu::Image.new("assets/images/btn_start_click.png"))
      
      @menu_click_sound = Gosu::Sample.new(@window, "assets/sounds/menu_click.mp3")

    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @text_fields.each { |tf| tf.draw }
      @header_color.draw(32.5, 125, 100)
      @button_return.draw
      @button_rdy.draw
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def update
      @button_return.update
      @button_rdy.update
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def clicked
      @menu_click_sound.play(0.7, 1, false)
      @button_return.clicked
      @button_rdy.clicked
    end

    ##
    # Gosu implementation
    # Inputs: key
    # Outputs: none

    def button_down(id)
      if id == Gosu::KbTab then
        index = @text_fields.index(@window.text_input) || -1
        @window.text_input = @text_fields[(index + 1) % @text_fields.size]

      elsif id == Gosu::KbEscape then
        if @window.text_input then
          @window.text_input = nil
        else
          close
        end

      elsif id == Gosu::MsLeft then
        @window.text_input = @text_fields.find { |tf| tf.under_point?(@window.mouse_x, @window.mouse_y) }
        @window.text_input.move_caret(@window.mouse_x) unless @window.text_input.nil?
      end
    end

  end
end