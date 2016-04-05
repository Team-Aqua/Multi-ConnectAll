module Models
  class UniversalGameStateModel

    attr_accessor :game_state, :grid, :user1, :user2, :user1_state, :user2_state, :winner

    def initialize()
      @game_state = :waiting #:end/:active/:saved/:waiting/:save_waiting
      @grid = Models::GridModel.new
      @user1 = nil
      @user2 = nil
      @user1_state = nil #:wait/:turn/:quit
      @user2_state = nil
      @winner = nil
    end
  end
end