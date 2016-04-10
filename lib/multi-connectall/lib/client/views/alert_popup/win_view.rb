module Views
  class WinAlertView < CascadingAlertView

    ## 
    # AlertView provided at game win 
    # Alert is coloured by player who won
    # Contains paths for return and replay

    def initialize(window, controller, player_color)
      super(window, controller)

      @menu_click_sound = Gosu::Sample.new(@window, "assets/sounds/menu_click.mp3")

      @player_win_views ={
        'orange' => Gosu::Image.new("assets/images/header_orange_win.png", :tileable => false),
        'pink' => Gosu::Image.new("assets/images/header_pink_win.png", :tileable => false),
        'white' => Gosu::Image.new("assets/images/header_white_win.png", :tileable => false),
        'green' => Gosu::Image.new("assets/images/header_green_win.png", :tileable => false),
        'yellow' => Gosu::Image.new("assets/images/header_yellow_win.png", :tileable => false),
        'teal' => Gosu::Image.new("assets/images/header_teal_win.png", :tileable => false),
        'black' => Gosu::Image.new("assets/images/header_black_win.png", :tileable => false),
        'purple' => Gosu::Image.new("assets/images/header_purple_win.png", :tileable => false),
        'tie' => Gosu::Image.new("assets/images/header_tie.png", :tileable => false)
      }

      @view = @player_win_views[player_color]
      # @replay = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_replay.png"), 185, 445, 200, lambda { @controller.reset_match }, Gosu::Image.new("assets/images/btn_replay_click.png", :tileable => false))
      @return = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_return_sm.png"), 185, 485, 200, lambda { @menu_click_sound.play(0.7, 1, false); @controller.return_to_spec_menu }, Gosu::Image.new("assets/images/btn_return_sm_click.png", :tileable => false))
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @view.draw(0, @y_anchor_pos, 100)
      if (@anchor_reached)
        #@replay.draw
        @return.draw
      end
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none
    
    def update
      #@replay.update
      @return.update

      slide_view
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none
    
    def clicked
      if (@anchor_reached)
        #@replay.clicked
        @return.clicked
      end
    end

  end
end