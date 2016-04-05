module Controllers
  class ServerCtrl

    def initialize()
      @server_model = Models::ServerModel.new
      @db_ctrl = Controllers::DBCtrl.new
      @network_comm_ctrl = Controllers::ServerNetworkCommunicationCtrl
    end

    def start

    end

  end
end