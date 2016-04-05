# Server interactions dev
require 'celluloid/io'
require 'socket'
require 'randexp'

# Standard games import
require 'gosu'

require_relative '../ancillaries/abstractInterface'

require_relative 'controllers/game_controllers/game_ctrl'
require_relative 'controllers/view_controllers/menu_ctrl'
require_relative 'controllers/game_controllers/network_comm_ctrl'

require_relative 'controllers/game_logic/rules'
require_relative 'controllers/game_logic/classic_rules'
require_relative 'controllers/game_logic/otto_rules'

require_relative 'controllers/game_logic/AI'
require_relative 'controllers/game_logic/classic_AI'
require_relative 'controllers/game_logic/otto_AI'

require_relative 'models/game_state_model'
require_relative 'models/grid_model'
require_relative 'models/player'
require_relative 'models/ai_player'
require_relative 'models/real_player'
require_relative 'models/ai_level'

require_relative 'views/btn_item'
require_relative 'views/game_views/game_view'
require_relative 'views/game_views/game_grid_view'
require_relative 'views/game_views/game_control_row_view'
require_relative 'views/game_views/game_header_view'
require_relative 'views/game_views/game_footer_view'

require_relative 'views/menu_views/initial_menu_view'
require_relative 'views/menu_views/menu_view'
require_relative 'views/menu_views/type_menu_view'
require_relative 'views/menu_views/mode_menu_view'
require_relative 'views/menu_views/player_select_menu_view'
require_relative 'views/menu_views/multiplayer_menu_view'
require_relative 'views/menu_views/text_input'
require_relative 'views/menu_views/login_server_menu_view'
require_relative 'views/menu_views/save_menu_view'

require_relative 'views/animations/basic'

require_relative 'views/alert_popup/alert_view'
require_relative 'views/alert_popup/cascading_alert_view'
require_relative 'views/alert_popup/connect_instructions_view'
require_relative 'views/alert_popup/otto_instructions_view'
require_relative 'views/alert_popup/connect_all_view'
require_relative 'views/alert_popup/help_view'
require_relative 'views/alert_popup/win_view'
require_relative 'views/alert_popup/waiting_alert_view'
require_relative 'views/alert_popup/login_alert_view'
require_relative 'views/alert_popup/leaderboard_alert_view'

require_relative '../ancillaries/m_contract_error'
require_relative 'contracts/AI_contracts'
require_relative 'contracts/game_controller_contracts'
require_relative 'contracts/game_state_model_contracts'
require_relative 'contracts/grid_model_contracts'
require_relative 'contracts/main_controller_contracts'
require_relative 'contracts/menu_controller_contracts'
require_relative 'contracts/player_model_contracts'
require_relative 'contracts/rules_contracts'

# Server interactions dev

require_relative 'settings'

class GameWindow < Gosu::Window

  attr_accessor :game_state_model, :controllers, :client_network_com

  ## 
  # Main application portal for ConnectAll
  # User must enter ruby main.rb to start
  # Setup all gosu-relatead logic and high-level controller logic

  def initialize(h, w, model: nil)
    super w, h, false
    Gosu::enable_undocumented_retrofication
    self.caption = "ConnectAll"
    @song = Gosu::Song.new(self, "assets/music/bitbop.mp3")
    @song.volume = 0.2
    #@song.play(true)

    # Dev server interaction
    if model != nil
      @game_state_model = model
    else
      @game_state_model = Models::GameStateModel.new
    end
 
    @controllers = {  :menu => Controllers::MenuCtrl.new(self, @game_state_model),
                      :game => Controllers::GameCtrl.new(self, @game_state_model) }
    #disabled for testing
    @currentCtrl = @controllers[:menu]

    if @client_network_com == nil
      @client_network_com = Controllers::NetworkCommunicationCtrl.new(SERVER, PORT, self)
    end

    @fps_init = Time.now.to_f
    @fps_counter = 0


  end

  ## 
  # Gosu implementation for showing cursor
  # Inputs: none
  # Outputs: boolean

  def needs_cursor?
    true
  end

  ##
  # Gosu logic for button or key input 
  # Depending on which, user interactions are called 
  # Inputs: key or mouse input
  # Outputs: none

  def button_down(key)
    MainControllerContracts.invariant(self)
    if key == Gosu::MsLeft then
      @currentCtrl.clicked
    end
    @currentCtrl.button_down(key)
    MainControllerContracts.invariant(self)
  end

  ##
  # Starts the start menu
  # Connect menu controller to views.
  # Inputs: none
  # Outputs: none
  
  def start_menu
    MainControllerContracts.invariant(self)
    initialize(440, 533)
    @currentCtrl = @controllers[:menu]
    MainControllerContracts.invariant(self)
  end

  ## 
  # Starts the game based on menu selection.
  # Connect game controller to views.
  # Inputs: none
  # Outputs: none

  def start_game

    # Dev server interaction
    # FIXME: Shift this to 'login to server' interaction
    # 
    @client_network_com.send_message(['setup', @game_state_model::players[@game_state_model::player_role]::name, @game_state_model::players[@game_state_model::player_role].player_color].join('|'))
    @controllers[:game]::view::grid.set_tiles
    initialize(568, 343, model: @game_state_model)
    @currentCtrl = @controllers[:game]

  end

  ##
  # Development test for FPS

  def fps
    if Time.now.to_f < (@fps_init + 1.0)
      @fps_counter = @fps_counter + 1
    else
      puts @fps_counter
      @fps_counter = 0
      @fps_init = Time.now.to_f
    end
  end

  ##
  # Gosu implementation
  # Inputs: none
  # Outputs: none

  def draw
    @currentCtrl.draw
  end

  ##
  # Gosu implementation
  # Inputs: none
  # Outputs: none

  def update
    @currentCtrl.update
  end

  ##
  # Gosu implementation
  # Inputs: none
  # Outputs: none
    
  def clicked
    @currentCtrl.clicked
  end

end

# Main.new(SERVER, PORT).show

@window = GameWindow.new(440, 533)
@window.show
