module Views
  class MultiplayerMenuView
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

      @menu_click_sound = Gosu::Sample.new(@window, "assets/sounds/menu_click.mp3")
      #@ole_start = Gosu::Sample.new(@window, "assets/sounds/ole_start.mp3")
      @color_selection = 0
      @color2_selection = 0
      @color_selection_wheel = ['green','orange','pink','white']
      @color2_selection_wheel = ['teal','yellow','black','purple']

      @header_color = Gosu::Image.new("assets/images/header_color.png", :tileable => false)
      
      @player_buttons ={
        'orange' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_lg_orange.png"), 110, 215, 100, lambda { color_swap }, Gosu::Image.new("assets/images/header_player_lg_orange_click.png")),
        'pink' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_lg_pink.png"), 110, 215, 100, lambda { color_swap }, Gosu::Image.new("assets/images/header_player_lg_pink_click.png")),
        'white' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_lg_white.png"), 110, 215, 100, lambda { color_swap }, Gosu::Image.new("assets/images/header_player_lg_white_click.png")),
        'green' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_lg_green.png"), 110, 215, 100, lambda { color_swap }, Gosu::Image.new("assets/images/header_player_lg_green_click.png"))
      }
      @player2_buttons = {
        'yellow' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_lg_yellow.png"), 110, 215, 100, lambda { color2_swap }, Gosu::Image.new("assets/images/header_player_lg_yellow_click.png")),
        'teal' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_lg_teal.png"), 110, 215, 100, lambda { color2_swap }, Gosu::Image.new("assets/images/header_player_lg_teal_click.png")),
        'black' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_lg_black.png"), 110, 215, 100, lambda { color2_swap }, Gosu::Image.new("assets/images/header_player_lg_black_click.png")),
        'purple' => BtnItem.new(@window, Gosu::Image.new("assets/images/header_player_lg_purple.png"), 110, 215, 100, lambda { color2_swap }, Gosu::Image.new("assets/images/header_player_lg_purple_click.png"))
      }

      #puts "gsm: #{@game_state_model::player_role}"

      @button_return = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_return_lg.png"), 140, 345, 100, lambda { @controller.to_type_menu }, Gosu::Image.new("assets/images/btn_return_lg_click.png")) 
      
      if @game_state_model::player_role == 0
        @button_player = @player_buttons[@color_selection_wheel[@color_selection]]
        @button_rdy = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_start.png"), 290, 345, 100, lambda { @controller.player_rdy(@color_selection_wheel[@color_selection], role: 0) }, Gosu::Image.new("assets/images/btn_start_click.png"))  
      elsif @game_state_model::player_role == 1
        @button_player = @player2_buttons[@color2_selection_wheel[@color2_selection]]
        @button_rdy = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_start.png"), 290, 345, 100, lambda { @controller.player_rdy(@color2_selection_wheel[@color2_selection], role: 1) }, Gosu::Image.new("assets/images/btn_start_click.png"))  
      end

    end

    ##
    # Gosu implementation:
    # Used for text input for names
    # Inputs: key id 
    # Outputs: none

    def button_down(id)
    end

    ## 
    # Defines logic for swapping colors for player one
    # Relected by button/name colors
    # Inputs: none
    # Outputs: none

    def color_swap
      @color_selection = (@color_selection + 1) % @color_selection_wheel.count
      @button_player = @player_buttons[@color_selection_wheel[@color_selection]]
    end

    ## 
    # Defines logic for swapping colors for player two
    # Reflected by button/name colors
    # Inputs: none
    # Outputs: none

    def color2_swap
      @color2_selection = (@color2_selection + 1) % @color2_selection_wheel.count
      @button_player = @player2_buttons[@color2_selection_wheel[@color2_selection]]
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @header_color.draw(110, 155, 110)
      @button_player.draw
      @button_rdy.draw
      @button_return.draw
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
    end

  end
end