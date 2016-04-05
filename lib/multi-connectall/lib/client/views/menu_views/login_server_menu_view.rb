module Views
  class LoginServerMenuView

    ##
    # View structure for P1vP2 or PvAI selection.

    def initialize(window, controller)
      @window = window
      @controller = controller
      @button_width = 235
      @font = Gosu::Font.new(@window, "assets/fonts/HN_Bd.ttf", 32)

      @headerUsername = BtnItem.new(@window, Gosu::Image.new("assets/images/header_username.png"), 22.5, 120, 100, lambda { })
      @headerIP = BtnItem.new(@window, Gosu::Image.new("assets/images/header_ip.png"), 22.5, 220, 100, lambda { })
      @headerPort = BtnItem.new(@window, Gosu::Image.new("assets/images/header_port.png"), 22.5, 320, 100, lambda { })

      @text_fields = Array.new(3) { |index| 
        if index == 0
          TextField.new(@window, @font, 32.5, 175 + index * 100, NAME, 'large') 
        elsif index == 1
          TextField.new(@window, @font, 32.5, 175 + index * 100, SERVER, 'large') 
        elsif index == 2
          TextField.new(@window, @font, 32.5, 175 + index * 100, PORT, 'large') 
        end
      }

      @button_return = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_return_lg.png"), 372, 285, 100, lambda { @controller.to_initial_menu }, Gosu::Image.new("assets/images/btn_return_lg_click.png")) 
      @button_rdy = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_start.png"), 372, 355, 100, lambda { @controller.login(name: @text_fields[0].get_text, server: @text_fields[1].get_text, port: @text_fields[2].get_text) }, Gosu::Image.new("assets/images/btn_start_click.png"))

      @menu_click_sound = Gosu::Sample.new(@window, "assets/sounds/menu_click.mp3")

    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @headerUsername.draw
      @headerIP.draw
      @headerPort.draw
      @text_fields.each { |tf| tf.draw }

      @button_return.draw
      @button_rdy.draw
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def update
      @headerUsername.update
      @headerIP.update
      @headerPort.update

      @button_return.update
      @button_rdy.update
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def clicked
      @menu_click_sound.play(0.7, 1, false)
      @headerUsername.clicked
      @headerIP.clicked
      @headerPort.clicked

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