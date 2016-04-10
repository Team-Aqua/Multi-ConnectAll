module Views

  ## 
  # GridView holds the grid where tiles are placed.
  # Contains player-specific tile information.

  class GridView
    attr_accessor :set_tiles, :tiles, :model

    def initialize(window, controller, model)
      @window = window
      @controller = controller
      @model = model
      @grid_model = @model::grid
      @grid_xpos = 29
      @grid_ypos = 116
      @grid_top

      @grey_block = Gosu::Image.new("assets/images/block_grey.png")

      @tilesClassic = { 'green' => Gosu::Image.new("assets/images/block_green.png"),
                'yellow' => Gosu::Image.new("assets/images/block_yellow.png"),
                'pink' => Gosu::Image.new("assets/images/block_pink.png"),
                'teal' => Gosu::Image.new("assets/images/block_teal.png"),
                'orange' => Gosu::Image.new("assets/images/block_orange.png"),
                'white' => Gosu::Image.new("assets/images/block_white.png"),
                'black' => Gosu::Image.new("assets/images/block_black.png"),
                'grey' => Gosu::Image.new("assets/images/block_grey.png"),
                'purple' => Gosu::Image.new("assets/images/block_purple.png") }

      @tilesOtto = { 'green' => Gosu::Image.new("assets/images/block_green_o.png"),
                'yellow' => Gosu::Image.new("assets/images/block_yellow_o.png"),
                'pink' => Gosu::Image.new("assets/images/block_pink_t.png"),
                'teal' => Gosu::Image.new("assets/images/block_teal_o.png"),
                'orange' => Gosu::Image.new("assets/images/block_orange_t.png"),
                'white' => Gosu::Image.new("assets/images/block_white_t.png"),
                'black' => Gosu::Image.new("assets/images/block_black_o.png"),
                'grey' => Gosu::Image.new("assets/images/block_grey.png"),
                'purple' => Gosu::Image.new("assets/images/block_purple_t.png") }
      
      @tiles = @tilesClassic

      @potential_tiles = { 'green' => Gosu::Image.new("assets/images/block_green_potential.png"),
                           'yellow' => Gosu::Image.new("assets/images/block_yellow_potential.png"),
                           'pink' => Gosu::Image.new("assets/images/block_pink_potential.png"),
                           'teal' => Gosu::Image.new("assets/images/block_teal_potential.png"),
                           'orange' => Gosu::Image.new("assets/images/block_orange_potential.png"),
                           'white' => Gosu::Image.new("assets/images/block_white_potential.png"),
                           'black' => Gosu::Image.new("assets/images/block_black_potential.png"),
                           'grey' => Gosu::Image.new("assets/images/block_grey.png"),
                           'purple' => Gosu::Image.new("assets/images/block_purple_potential.png") }

      @falling_tiles = []
      @click_sound = Gosu::Sample.new(@window, "assets/sounds/quick_beat.mp3")
      @swoosh_sound = Gosu::Sample.new(@window, "assets/sounds/fast_swish.mp3")
      set_tiles
    end

    def load_tiles
      if @model::game_type == :classic
        @tiles = @tilesClassic
      elsif @model::game_type == :otto
        @tiles = @tilesOtto
      end
    end

    ##
    # Sets tiles depending on game type selected in menu
    # Inputs: none
    # Outputs: none
    
    def set_tiles
      if @model::game_type == :classic || @model::game_type == 'classic'
        @tiles = @tilesClassic
      elsif @model::game_type == :otto || @model::game_type == 'otto'
        @tiles = @tilesOtto
      end
    end

    ##
    # Returns the value at the grid given the x and y coordinates
    # Inputs: X position, Y position
    # Outputs: grid value
    
    def getGridModelValue(x, y)
      @grid_model.getValue(x, y)
    end

    ## 
    # Animates the tile drop using the animation library.
    # Inputs: X position, player color, delay time
    # Outputs: none

    def animate_tile_drop(x, player_color, delay)
      Thread.new {
      sleep(delay)
      @swoosh_sound.play
      y = @grid_ypos+((38*(@grid_model.column_depth(x)-2))+19)
      x = 29 + ((x-1)*35.5)
      animation = Animations::Basic.new(x, @grid_ypos, x_dest: 0, y_dest: y, x_speed: 0, y_speed: 0.1, image: @tiles[player_color], z: 15)
      animation.animate
      @falling_tiles.push(animation)
      while @falling_tiles.include?(animation)
        sleep(0.1)
      end
      yield
      }
    end

    ##
    # Extension of Gosu implementation,
    # Draws tiles in relative position
    # Currently implementing pixel-perfect position (35.5px, 38px)
    # Inputs: none
    # Outputs: none

    def draw_tiles
      ypos = @grid_ypos
      (0..7).each { |y|
        xpos = @grid_xpos
        (0..7).each { |x|
          if @grid_model.getValue(x, y) != 0
            @tiles[@model::players[@grid_model.getValue(x, y)-1]::player_color].draw(xpos, ypos, 15)
          else
            @grey_block.draw(xpos, ypos, 5)
          end
          xpos = xpos + 35.5
        }
        ypos = ypos + 38
      }
    end

    ##
    # Draws the potential block positions for the current player.
    # Currently unused.
    # Inputs: none
    # Outputs: none

    def draw_potentials
      ypos = @grid_ypos
      (1..7).each { |y|
        xpos = @grid_xpos
        (0..7).each { |x|
          if @grid_model.getValue(x, y) != 0 and @grid_model.getValue(x, y - 1) == 0
            # puts "#{@grid_model.getValue(x, y)}, x: #{x}, y: #{y}"
            @potential_tiles[@model::players[@model.player_turn_state]::player_color].draw(xpos, ypos, 14)
          end
          if y == 7 and @grid_model.getValue(x, y) == 0
            @potential_tiles[@model::players[@model.player_turn_state]::player_color].draw(xpos, ypos + 38, 14)
          end
          xpos = xpos + 35.5
        }
        ypos = ypos + 38
      }
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      if @falling_tiles != []
        @falling_tiles.each do |tile|
          tile.draw
        end
      end
      draw_tiles
      draw_potentials
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def update
      if @falling_tiles != []
        @falling_tiles.each do |tile|
          if tile::state == :dead
            @click_sound.play
            @falling_tiles.delete(tile)
          end
        end
      end
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def clicked
    end

  end
end