module Models
  class ServerModel
    attr_accessor :queues, :active_games, :online_users 
    def initialize()
      @queues = {:classic => [], :otto => []}
      @active_games = []
      @online_users = Hash.new
    end
  end
end