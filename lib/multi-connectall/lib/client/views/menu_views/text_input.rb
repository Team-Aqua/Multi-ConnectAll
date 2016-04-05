require 'gosu'
class TextField < Gosu::TextInput

  ## 
  # TextField is a custom implementation of a text field
  # Lets users enter in text given max size and alphanumeric characters
  # Code referenced from: https://docs.omniref.com/ruby/gems/gosu/0.7.24/universal-darwin/files/examples/TextInput.rb

  INACTIVE_COLOR  = 0xcc666666
  ACTIVE_COLOR    = 0xccff6666
  SELECTION_COLOR = 0xcc0000ff
  CARET_COLOR     = 0xff505050
  PADDING_X = 10
  PADDING_Y = -3
  attr_reader :x, :y

  def initialize(window, font, x, y, ip_text, size = nil)
    # TextInput's constructor doesn't expect any arguments.
    super()
    @window, @font, @x, @y, self.text = window, font, x, y, ip_text
    if size == 'large'
      @box = Gosu::Image.new("assets/images/ip_name_lg.png", :tileable => false)
      @box_hover = Gosu::Image.new("assets/images/ip_name_lg_hover.png", :tileable => false)
      @MAX_WIDTH = 300
    else 
      @box = Gosu::Image.new("assets/images/ip_name.png", :tileable => false)
      @box_hover = Gosu::Image.new("assets/images/ip_name_hover.png", :tileable => false)
      @MAX_WIDTH = 133
    end
    @drawbox
    @width = 151
    @height = 33
    @caret_height = 25
  end

  ##
  # Filters text by the given parameters:
  # Must be alphanumeric and must fit within the text box.
  # Inputs: text character, singular
  # Outputs: text
  
  def filter text
    if width + @font.text_width(text) < @MAX_WIDTH
      return text.gsub(/[^A-Z0-9a-z ]/, '')
    else 
      return nil
    end
  end

  ##
  # Returns the text currently in field.
  # Inputs: none
  # Outputs: text

  def get_text
    return self.text
  end

  ## 
  # Draws the box first,
  # Then the caret and the text after.
  # Layers to ensure proper printing.
  # Gosu implementation.
  # Inputs: none
  # Outputs: none

  def draw
    # Depending on whether this is the currently selected input or not, change the
    # background's color.
    if @window.text_input == self then
      @drawbox = @box  
    else
      @drawbox = @box_hover
    end
    @drawbox.draw(x - PADDING_X, y - PADDING_Y, 100)
    pos_x = x + @font.text_width(self.text[0...self.caret_pos])
    sel_x = x + @font.text_width(self.text[0...self.selection_start])    
    # Draw the caret; again, only if this is the currently selected field.
    if @window.text_input == self then
      @window.draw_line(pos_x, y - PADDING_Y + 5,          CARET_COLOR,
                        pos_x, y + height - PADDING_Y - 5, CARET_COLOR, 100)
    end
    # Finally, draw the text itself!
    @font.draw(self.text, x, y, 120, 1, 1, 0xff_646464)
  end

  ## 
  # Returns the width of the text given the font used.
  # Input: none
  # Output: size in integer

  def width
    @font.text_width(self.text)
  end

  ## 
  # Returns the height of the text given the font used.
  # Input: none
  # Output: size in integer

  def height
    @font.height
  end

  ## 
  # Hit-test for selecting a text field with the mouse.
  # Input: mouse x, y positions
  # Output: boolean
  
  def under_point?(mouse_x, mouse_y)
    mouse_x > x - PADDING_X and mouse_x < x + @width + PADDING_X and
      mouse_y > y - PADDING_Y and mouse_y < y + @height + PADDING_Y
  end

  ##
  # Tries to move the caret to the position specifies by mouse_x
  # Can be selected by clicking via mouse
  # Input: mouse x position
  # Output: new caret position
  
  def move_caret(mouse_x)
    # Test character by character
    1.upto(self.text.length) do |i|
      if mouse_x < x + @font.text_width(text[0...i]) then
        self.caret_pos = self.selection_start = i - 1;
        return
      end
    end
    # Default case: user must have clicked the right edge
    self.caret_pos = self.selection_start = self.text.length
  end
end