module Views
  class CascadingAlertView < AlertView
    attr_reader :y_anchor_pos
    ##
    # Generic AlertView implementation
    # Used as framework for other alertviews

    def initialize(window, controller)
      super(window, controller)
      @y_anchor_pos = -465.5
      @anchor_reached = false
      @base_speed = 2
      @accel = 0.3
      @speed = @base_speed
    end

    def slide_view
      if @y_anchor_pos < 0
        @speed = @speed + @accel
        @y_anchor_pos += @speed
      else
        @anchor_reached = true
        @speed = @base_speed
      end
    end

  end
end