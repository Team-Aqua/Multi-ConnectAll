module Views
  class AlertView

    ##
    # Generic AlertView implementation
    # Used as framework for other alertviews

    def initialize(window, controller)
      @window = window
      @controller = controller
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none
    
    def update
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none
    
    def clicked
    end

  end
end