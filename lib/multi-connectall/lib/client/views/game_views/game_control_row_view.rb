module Views

  ##
  # GameDropControlRowView sets up the red grid responsible for player input.
  # Users can select this row to choose where to drop down blocks at their turn.
  # 

  class GameDropControlRowView

    attr_accessor :control_disabled

    def initialize(window, controller, game_state_model)
      @window = window
      @controller = controller
      @game_state_model = game_state_model
      @grid_xpos = 50
      @grid_ypos = 116
      @control_disabled = false

      @x = @y = 0.0
      build_red_grid
    end

    ##
    # Generates red grid at startup for game.
    # Inputs: none
    # Outputs: none

    def build_red_grid
      @red_grid = Array.new
      original_pos = 29
      (1..8).each { |x|
        red_button = BtnItem.new(@window, Gosu::Image.new("assets/images/block_red.png", :tileable => true), original_pos, 420, 35, lambda { @controller.control_button_click(x) }, Gosu::Image.new("assets/images/block_red_click.png", false))
        @red_grid << red_button
        original_pos = original_pos + 35.5
      }
    end

    ##
    # Checks whether or not the row can be selected for input by user.
    # If the column is not available, the user is shown an N/A block.
    # Inputs: game started
    # Outputs: none
    #

    def check_available
      original_pos = 29
      (1..8).each { |x|
        if @game_state_model::grid.column_depth(x) <= 0 and @red_grid.at(x - 1).hover_image != nil
          red_button_disabled = BtnItem.new(@window, Gosu::Image.new("assets/images/block_red_not_available.png", :tileable => true), original_pos, 420, 35, lambda { })
          @red_grid.delete_at(x - 1)
          @red_grid.insert(x - 1, red_button_disabled)
        end
        original_pos = original_pos + 35.5
      }
    end

    ## 
    # Disables player tile selection on AI's turn
    # Inputs: none
    # Outputs: none

    def disable_control_on_AI
      if @game_state_model::game_mode == :pvai
        original_pos = 29
        (1..8).each { |x|
          if @game_state_model::players[@game_state_model::player_turn_state].is_a?(Models::RealPlayer)
            red_button_disabled = BtnItem.new(@window, Gosu::Image.new("assets/images/block_red_not_available.png", :tileable => true), original_pos, 420, 35, lambda { })
            @red_grid.delete_at(x - 1)
            @red_grid.insert(x - 1, red_button_disabled)
          else
            red_button = BtnItem.new(@window, Gosu::Image.new("assets/images/block_red.png", :tileable => true), original_pos, 420, 35, lambda { @controller.control_button_click(x) }, Gosu::Image.new("assets/images/block_red_click.png", false))
            @red_grid.delete_at(x - 1)
            @red_grid.insert(x - 1, red_button)
          end
          original_pos = original_pos + 35.5
        }
      end
    end

    ##
    # Disables player tile selection on tile drop
    # Used to prevent sequencing errors

    def disable_control_on_player
      if @game_state_model::game_mode == :pvp
        original_pos = 29
        (1..8).each { |x|
          if @red_grid.at(x - 1).hover_image != nil
            red_button_disabled = BtnItem.new(@window, Gosu::Image.new("assets/images/block_red_not_available.png", :tileable => true), original_pos, 420, 35, lambda { })
            @red_grid.delete_at(x - 1)
            @red_grid.insert(x - 1, red_button_disabled)
            original_pos = original_pos + 35.5
          end
        }
      end
      control_disabled = true
    end

    ##
    # Reenables player tile selection on tile drop
    # Used to prevent sequencing errors

    def enable_control_on_player
      # future development: 'smart toggling'
      if @game_state_model::game_mode == :pvp
        original_pos = 29
        (1..8).each { |x|
          if @game_state_model::grid.column_depth(x) > 0 or @red_grid.at(x - 1).hover_image == nil
            red_button = BtnItem.new(@window, Gosu::Image.new("assets/images/block_red.png", :tileable => true), original_pos, 420, 35, lambda { @controller.control_button_click(x) }, Gosu::Image.new("assets/images/block_red_click.png", false))
            @red_grid.delete_at(x - 1)
            @red_grid.insert(x - 1, red_button)
            original_pos = original_pos + 35.5
          end
        }
      end
      control_disabled = false
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @red_grid.each do |j|
        j.draw
      end
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def update
      @red_grid.each do |j|
        j.update
      end
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def clicked
      @red_grid.each do |j|
        j.clicked
      end
    end

  end
end