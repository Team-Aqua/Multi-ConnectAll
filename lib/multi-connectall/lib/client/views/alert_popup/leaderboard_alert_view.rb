module Views
  class LeaderboardAlertView

    ## 
    # Called at main menu
    # Used to identify how to play ConnectAll classic mode

    def initialize(window, controller)

      @window = window
      @lb_total = Array.new
      @lb_classic = Array.new
      @lb_otto = Array.new

      response = @window.client_network_com.receive_leaderboards
      if response != nil
        arresponse = response.split('|')
        if arresponse[0] != nil
          @lb_total = arresponse[0].split("\n")
        end 
        if arresponse[1] != nil
          @lb_classic = arresponse[1].split("\n")
        end 
        if arresponse[2] != nil
          @lb_otto = arresponse[2].split("\n")
        end 
        # puts "responses: #{@lb_total} ||| #{@lb_classic} ||| #{@lb_otto}"
      end

      @controller = controller
      @font = Gosu::Font.new(@window, "assets/fonts/HN_Bd.ttf", 20)
      @help = Gosu::Image.new("assets/images/item_leaderboards.png", :tileable => false)
      @cancel = BtnItem.new(@window, Gosu::Image.new("assets/images/btn_cancel_dark.png"), 450, 35, 100, lambda { @controller.alert_close }, Gosu::Image.new("assets/images/btn_cancel_dark.png", :tileable => false))
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def draw
      @help.draw(30, 20, 100)
      @cancel.draw
      initheight = 107
      @lb_total.each {|x| 
        @font.draw("#{x}", 90, initheight, 135, 1.0, 1.0, 0xff_646464)
        initheight += 14
      }
      initheight = 212
      @lb_classic.each {|x| 
        @font.draw("#{x}", 90, initheight, 135, 1.0, 1.0, 0xff_646464)
        initheight += 14
      }
      initheight = 320
      @lb_otto.each {|x| 
        @font.draw("#{x}", 90, initheight, 135, 1.0, 1.0, 0xff_646464)
        initheight += 14
      }
    end
    
    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none

    def update
      @cancel.update
    end

    ##
    # Gosu implementation
    # Inputs: none
    # Outputs: none
    
    def clicked
      @cancel.clicked
    end

  end
end