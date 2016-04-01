module Animations
  class Basic

    ##
    # Basic animation for falling blocks
    # Provides the falling animation via separate thread
    
    attr_accessor :state

    def initialize(x, y, x_dest: xdest, y_dest: ydest, x_speed: xspeed, y_speed: yspeed, image: imagev, z: zv)
      @state = :alive
      @x = x.to_f
      @y = y.to_f
      @x_dest = x_dest.to_f
      @y_dest = y_dest.to_f

      @y_offset = @y_dest - @y

      @x_speed = x_speed.to_f
      @y_speed = y_speed.to_f
      @image = image
      @z = z
      @frame_rate = 60.0
      @speed = 3.0
    end

    ## 
    # Slowly accelerates the block as it drops
    # Factors as 'gravity' implementation
    # Inputs: none
    # Outputs: none

    def accelaration
      @speed = (@speed * 1.05)
    end

    ##
    # Used for animation calling
    # Immediately opens a thread to process animation
    # Inputs: none
    # Outputs: thread with animation

    def animate
      Thread.new{anim}
    end

    ##
    # Animates falling block given speed and acceleration
    # At termination, state change lets game process return to normal state
    # Inputs: none
    # Outputs: final state change
    
    def anim
      while (@y <= @y_dest)
        @y = @y + @speed
        accelaration
        sleep((@y_speed/@frame_rate))
      end
      @state = :dead
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @image.draw(@x, @y, @z)
    end

  end
end