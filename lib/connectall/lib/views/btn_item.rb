class BtnItem

    ## 
    # Logic for buttons for Gosu.
    # Code referenced from: http://blog.dreasgrech.com/2010/08/simple-menu-for-gosu-game-in-ruby.html
    
    attr_accessor :hover_image
    HOVER_OFFSET = 0
    def initialize (window, image, x, y, z, callback, hover_image = nil)
        @window = window
        @main_image = image
        @hover_image = hover_image
        @original_x = @x = x
        @original_y = @y = y
        @z = z
        @callback = callback
        @active_image = @main_image
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
        @active_image.draw(@x, @y, @z)
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def update
        if is_mouse_hovering then
            if !@hover_image.nil? then
                @active_image = @hover_image
            end

            @x = @original_x + HOVER_OFFSET
            @y = @original_y + HOVER_OFFSET
        else 
            @active_image = @main_image
            @x = @original_x
            @y = @original_y
        end
    end

    ##
    # Identifies if the mouse is selecting the button,
    # given window relative x, y positions.
    # Inputs: none
    # Outputs: boolean

    def is_mouse_hovering
        mx = @window.mouse_x
        my = @window.mouse_y
        (mx >= @x and my >= @y) and (mx <= @x + @active_image.width) and (my <= @y + @active_image.height)
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def clicked
        if is_mouse_hovering then
            @callback.call
        end
    end
end