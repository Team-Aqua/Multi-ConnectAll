module Controllers
  class DBCtrl

    def initialize()
    	@databaseSemaphore = 
      @database = Mysql.new("mysqlsrv.ece.ualberta.ca", "ece421usr2" , "iDd0FBwq", "ece421grp2", 13020)
      @database.autocommit = true
      create_tables()
    end
    
    def create_tables()
      @database.query("CREATE TABLE IF NOT EXISTS users (
      	playerID INTEGER NOT NULL, 
      	playerName VARCHAR(50) NOT NULL, 
      	classicWins INTEGER DEFAULT 0, 
      	classicLoses INTEGER DEFAULT 0, 
      	classicTies INTEGER DEFAULT 0, 
      	ottoWins INTEGER DEFAULT 0, 
      	ottoLoses INTEGER DEFAULT 0, 
      	ottoTies INTEGER DEFAULT 0, 
      	UNIQUE (playerID))")

      @database.query("CREATE TABLE IF NOT EXISTS savedGames (
      	playerID INTEGER NOT NULL, 
      	gameState VARCHAR(2048), 
      	UNIQUE (playerID))")
    end
    
    def drop_tables()
      @database.query("DROP TABLE IF EXISTS users")
      @database.query("DROP TABLE IF EXISTS savedGames")
    end
    
    def insert_user_row(playerID, playerName)
    	@database.query("INSERT INTO users (playerID, playerName) VALUES (" << playerID << ", ‘" << playerName << "’)")
    def

    def update_user_row(playerID, fieldName)
      @database.query("UPDATE users SET " << fieldName << " = " << fieldName << "+1 WHERE playerID = " << playerID << "")
    end

    def insert_saved_game(playerID, gameState)
    	@database.query("INSERT INTO savedGames (playerID, gameState) VALUES (" << playerID << ", " << gameState << ")")
    def

    def get_saved_game(playerID)
    	@database.query("SELECT gameState FROM savedGames WHERE playerID = " << playerID <<"")
    end

    def delete_saved_game(playerID)
    	@database.query("DELETE FROM savedGames WHERE playerID = " << playerID << "")
    end

    def get_top_classic_players()
    	@database.query("SELECT playerName, classicWins AS wins, classicLoses AS loses, classicTies AS ties FROM users ORDER BY classicWins - classicLoses + classicTies DESC LIMIT 5")
    end

    def get_top_otto_players()
			@database.query("SELECT playerName, ottoWins AS wins, ottoLoses AS loses, ottoTies AS ties FROM users ORDER BY ottoWins - ottoLoses + ottoTies DESC LIMIT 5")
    end

    def get_top_overall_players()
    	@database.query("SELECT playerName, classicWins + ottoWins AS wins, classicLoses + ottoLoses AS loses, classicTies + ottoTies AS ties FROM users ORDER BY classicWins - classicLoses + classicTies + ottoWins - ottoLoses + ottoTies DESC LIMIT 5")
    end

  end
end