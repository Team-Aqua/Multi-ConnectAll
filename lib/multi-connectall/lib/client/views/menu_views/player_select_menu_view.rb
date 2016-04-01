module Views
  class PlayerMenuView
    attr_accessor :color_swap

    ##
    # PlayerMenuView lets users select names and colours before playing.
    # Selected after PvAI/P1vP2 selection
    
    ##
    # Multiplayer functionality: on load,
    # this page sets up the multiplayer
    # Dev: needs to be able to 'drop' player if they exit this screen

    def initialize(window, controller, game_state_model)
      @window = window
      @game_state_model = game_state_model
      @controller = controller
      @button_width = 235
      @font = Gosu::Font.new(@window, "assets/fonts/HN_Bd.ttf", 32)
      @ai_level = Models::AILevel.new

      @menu_click_sound = Gosu::Sample.new(@window, "assets/sounds/menu_click.mp3")
      #@ole_start = Gosu::Sample.new(@window, "assets/sounds/ole_start.mp3")
      @color_selection = 0
      @color2_selection = 0
      @color_selection_wheel = ['green','orange','pink','white']
      @color2_selection_wheel = ['teal','yellow','black','purple']
      
      @player_buttons ={
        'orange' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_nocolon_orange.png"), (@window.width/2)-(@button_width/2) - 125, 115, 100, lambda { color_swap }, Gosu::Image.new("assets/images/header_player_nocolon_orange_click.png")),
        'pink' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_nocolon_pink.png"), (@window.width/2)-(@button_width/2) - 125, 115, 100, lambda { color_swap }, Gosu::Image.new("assets/images/header_player_nocolon_pink_click.png")),
        'white' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_nocolon_white.png"), (@window.width/2)-(@button_width/2) - 125, 115, 100, lambda { color_swap }, Gosu::Image.new("assets/images/header_player_nocolon_white_click.png")),
        'green' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_nocolon_green.png"), (@window.width/2)-(@button_width/2) - 125, 115, 100, lambda { color_swap }, Gosu::Image.new("assets/images/header_player_nocolon_green_click.png"))
      }
      @player_name = {
        'orange' => BtnItem.new(@window, Gosu::Image.new("assets/images/input_orange_name.png"), (@window.width/2)-(@button_width/2) - 125, 185, 100, lambda { color_swap }),
        'pink' => BtnItem.new(@window, Gosu::Image.new("assets/images/input_pink_name.png"), (@window.width/2)-(@button_width/2) - 125, 185, 100, lambda { color_swap }),
        'white' => BtnItem.new(@window, Gosu::Image.new("assets/images/input_white_name.png"), (@window.width/2)-(@button_width/2) - 125, 185, 100, lambda { color_swap }),
        'green' => BtnItem.new(@window, Gosu::Image.new("assets/images/input_green_name.png"), (@window.width/2)-(@button_width/2) - 125, 185, 100, lambda { color_swap })
      }
      @player2_buttons = {
        'yellow' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_nocolon_yellow.png"), (@window.width/2)-(@button_width/2) - 125, 115, 100, lambda { color2_swap }, Gosu::Image.new("assets/images/header_player_nocolon_yellow_click.png")),
        'teal' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_nocolon_teal.png"), (@window.width/2)-(@button_width/2) - 125, 115, 100, lambda { color2_swap }, Gosu::Image.new("assets/images/header_player_nocolon_teal_click.png")),
        'black' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_nocolon_black.png"), (@window.width/2)-(@button_width/2) - 125, 115, 100, lambda { color2_swap }, Gosu::Image.new("assets/images/header_player_nocolon_black_click.png")),
        'purple' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_nocolon_purple.png"), (@window.width/2)-(@button_width/2) - 125, 115, 100, lambda { color2_swap }, Gosu::Image.new("assets/images/header_player_nocolon_purple_click.png"))
      }
      @player2_name = {
        'yellow' => BtnItem.new(@window, Gosu::Image.new("assets/images/input_yellow_name.png"), (@window.width/2)-(@button_width/2) - 125, 185, 100, lambda { color2_swap }),
        'teal' => BtnItem.new(@window, Gosu::Image.new("assets/images/input_teal_name.png"), (@window.width/2)-(@button_width/2) - 125, 185, 100, lambda { color2_swap }),
        'black' => BtnItem.new(@window, Gosu::Image.new("assets/images/input_black_name.png"), (@window.width/2)-(@button_width/2) - 125, 185, 100, lambda { color2_swap }),
        'purple' => BtnItem.new(@window, Gosu::Image.new("assets/images/input_purple_name.png"), (@window.width/2)-(@button_width/2) - 125, 185, 100, lambda { color2_swap })
      }

      @ai_grid = Array.new
      @ai_grid_empty = Array.new
      
      button1_ai = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_1.png", :tileable => true), 29, 280, 35, lambda { set_ai(0) }, Gosu::Image.new("assets/images/btn_ai_1_clicked.png", false))
      button2_ai = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_2.png", :tileable => true), 64.5, 280, 35, lambda { set_ai(1) }, Gosu::Image.new("assets/images/btn_ai_2_clicked.png", false))
      button3_ai = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_3.png", :tileable => true), 100, 280, 35, lambda { set_ai(2) }, Gosu::Image.new("assets/images/btn_ai_3_clicked.png", false))
      button4_ai = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_4.png", :tileable => true), 135.5, 280, 35, lambda { set_ai(3) }, Gosu::Image.new("assets/images/btn_ai_4_clicked.png", false))
      button5_ai = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_5.png", :tileable => true), 171, 280, 35, lambda { set_ai(4) }, Gosu::Image.new("assets/images/btn_ai_5_clicked.png", false))
      button6_ai = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_6.png", :tileable => true), 206.5, 280, 35, lambda { set_ai(5) }, Gosu::Image.new("assets/images/btn_ai_6_clicked.png", false))
      button7_ai = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_7.png", :tileable => true), 242, 280, 35, lambda { set_ai(6) }, Gosu::Image.new("assets/images/btn_ai_7_clicked.png", false))
      button8_ai = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_8.png", :tileable => true), 277.5, 280, 35, lambda { set_ai(7) }, Gosu::Image.new("assets/images/btn_ai_8_clicked.png", false))
      
      button1_ai_empty = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_1_empty.png", :tileable => true), 29, 280, 35, lambda { set_ai(0) }, Gosu::Image.new("assets/images/btn_ai_1_clicked.png", false))
      button2_ai_empty = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_2_empty.png", :tileable => true), 64.5, 280, 35, lambda { set_ai(1) }, Gosu::Image.new("assets/images/btn_ai_2_clicked.png", false))
      button3_ai_empty = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_3_empty.png", :tileable => true), 100, 280, 35, lambda { set_ai(2) }, Gosu::Image.new("assets/images/btn_ai_3_clicked.png", false))
      button4_ai_empty = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_4_empty.png", :tileable => true), 135.5, 280, 35, lambda { set_ai(3) }, Gosu::Image.new("assets/images/btn_ai_4_clicked.png", false))
      button5_ai_empty = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_5_empty.png", :tileable => true), 171, 280, 35, lambda { set_ai(4) }, Gosu::Image.new("assets/images/btn_ai_5_clicked.png", false))
      button6_ai_empty = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_6_empty.png", :tileable => true), 206.5, 280, 35, lambda { set_ai(5) }, Gosu::Image.new("assets/images/btn_ai_6_clicked.png", false))
      button7_ai_empty = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_7_empty.png", :tileable => true), 242, 280, 35, lambda { set_ai(6) }, Gosu::Image.new("assets/images/btn_ai_7_clicked.png", false))
      button8_ai_empty = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_ai_8_empty.png", :tileable => true), 277.5, 280, 35, lambda { set_ai(7) }, Gosu::Image.new("assets/images/btn_ai_8_clicked.png", false))

      @button_return = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_return_lg.png"), 382, 205, 100, lambda { @controller.return_to_mode_menu }, Gosu::Image.new("assets/images/btn_return_lg_click.png")) 
      
      @window.client_network_com.join_game #FIXME: Should probably move this logic to a ctrl instead of being in a view

      if (@game_state_model::game_mode == :pvp)
        if @game_state_model::player_role == 0
          @button_player = @player_buttons[@color_selection_wheel[@color_selection]]
          @name_player = @player_name[@color_selection_wheel[@color_selection]]
          @button_rdy = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_start.png"), 382, 275, 100, lambda { @controller.player_rdy(@color_selection_wheel[@color_selection], player_name: @text_fields[0].get_text, role: 0) }, Gosu::Image.new("assets/images/btn_start_click.png"))  
        elsif @game_state_model::player_role == 1
          @button_player = @player2_buttons[@color2_selection_wheel[@color2_selection]]
          @name_player = @player2_name[@color2_selection_wheel[@color2_selection]]
          @button_rdy = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_start.png"), 382, 275, 100, lambda { @controller.player_rdy(@color2_selection_wheel[@color2_selection], player_name: @text_fields[0].get_text, role: 1) }, Gosu::Image.new("assets/images/btn_start_click.png"))  
        end
        # @button_player2 = @player2_buttons[@color2_selection_wheel[@color2_selection]]
        # @name_player2 = @player2_name[@color2_selection_wheel[@color2_selection]]
        @text_fields = Array.new(1) { |index| TextField.new(@window, @font, 113, 175 + index * 110, "ID") }
      else
        @button_player = @player_buttons[@color_selection_wheel[@color_selection]]
        @name_player = @player_name[@color_selection_wheel[@color_selection]]
        #Added to reduce logic complexity in draw and update. SHould be out of view tho
        @text_fields = Array.new(1) { |index| TextField.new(@window, @font, 113, 175, "Player #{index + 1}") }
        # @button_player2 = BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_black.png"), -500, -500, 100, lambda { color2_swap }, Gosu::Image.new("assets/images/header_player_black_click.png"))        
        # @name_player2 = BtnItem.new(@window, Gosu::Image.new("assets/images/input_black_name.png"), -500, -500, 100, lambda { color_swap })
        @header_ai_difficulty = Gosu::Image.new("assets/images/btn_ai_difficulty.png", :tileable => false)
        @ai_bg = Gosu::Image.new("assets/images/bg_ai.png", :tileable => false)
        @button_rdy = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_start.png"), 382, 275, 100, lambda { @controller.player_rdy(@color_selection_wheel[@color_selection], player_name: @text_fields[0].get_text, ai_level: @ai_level)}, Gosu::Image.new("assets/images/btn_start_click.png"))


        @ai_grid << button1_ai
        @ai_grid << button2_ai
        @ai_grid << button3_ai
        @ai_grid << button4_ai
        @ai_grid << button5_ai
        @ai_grid << button6_ai
        @ai_grid << button7_ai
        @ai_grid << button8_ai

        @ai_grid_empty << button1_ai_empty
        @ai_grid_empty << button2_ai_empty
        @ai_grid_empty << button3_ai_empty
        @ai_grid_empty << button4_ai_empty
        @ai_grid_empty << button5_ai_empty
        @ai_grid_empty << button6_ai_empty
        @ai_grid_empty << button7_ai_empty
        @ai_grid_empty << button8_ai_empty

      end    

    end

    def set_ai(id)
      @ai_level.level = id
    end

    ##
    # Gosu implementation:
    # Used for text input for names
    # Inputs: key id 
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

    ## 
    # Defines logic for swapping colors for player one
    # Relected by button/name colors
    # Inputs: none
    # Outputs: none

    def color_swap
      @color_selection = (@color_selection + 1) % @color_selection_wheel.count
      @button_player = @player_buttons[@color_selection_wheel[@color_selection]]
      @name_player = @player_name[@color_selection_wheel[@color_selection]]
    end

    ## 
    # Defines logic for swapping colors for player two
    # Reflected by button/name colors
    # Inputs: none
    # Outputs: none

    def color2_swap
      @color2_selection = (@color2_selection + 1) % @color2_selection_wheel.count
      @button_player = @player2_buttons[@color2_selection_wheel[@color2_selection]]
      @name_player = @player2_name[@color2_selection_wheel[@color2_selection]]
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      if (@game_state_model::game_mode != :pvp)
        @header_ai_difficulty.draw(29, 225, 100)
        @ai_bg.draw(25, 277, 10)
        (0..@ai_level.level).each do |x| 
          @ai_grid[x].draw
        end
        (@ai_level.level + 1..7).each do |y| 
          @ai_grid_empty[y].draw
        end
      end
      @button_player.draw
      # @button_player2.draw
      @name_player.draw
      # @name_player2.draw
      @button_rdy.draw
      @button_return.draw
      @text_fields.each { |tf| tf.draw }
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def update
      @button_player.update
      # @button_player2.update
      @button_rdy.update
      @button_return.update
      if (@game_state_model::game_mode != :pvp)
        @ai_grid.each { |gv| gv.update }
        @ai_grid_empty.each { |gve| gve.update }
      end
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def clicked
      @menu_click_sound.play
      @button_player.clicked
      # @button_player2.clicked
      @button_rdy.clicked
      @button_return.clicked
      if (@game_state_model::game_mode != :pvp)
        @ai_grid.each { |gv| gv.clicked }
        @ai_grid_empty.each { |gve| gve.clicked }
      end
    end

  end
end