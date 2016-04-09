module Models
  class UniversalGameStateModel

    attr_accessor :game_state, :game_mode, :grid, :last_move, :user1, :user2, :user1_state, :user2_state, :winner, :assigned_role, 
    :user1_data, :user2_data, :user1_stats, :user2_stats
    

    def initialize()
      @game_state = :waiting #:end/:active/:saved/:waiting/:save_waiting
      @game_mode = nil #:otto/classic
      @grid = Models::GridModel.new
      @last_move_x = nil
      @last_move_y = nil
      @user1 = nil
      @user2 = nil
      @user1_state = nil #:wait/:turn/:quit
      @user2_state = nil

      @user1_data = nil
      @user2_data = nil

      @user1_stats = "1/1/10"
      @user2_stats = "2/2/22"

      @assigned_role = nil
      @winner = nil
    end
  end
end