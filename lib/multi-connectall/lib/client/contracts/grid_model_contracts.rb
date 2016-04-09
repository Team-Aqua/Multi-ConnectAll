require_relative '../../ancillaries/m_contract_error'
module GridModelContracts
  class GridModelContractError < MContractError
    def initialize(error)
      super(error)
    end
  end

  def self.invariant(model)
    if model.x < 0 then raise GridModelContractError.new("column number should be greater than 0") end
    if model.y < 0 then raise GridModelContractError.new("row number should be greater than 0") end
    if model.grid == nil then raise GridModelContractError.new("Grid does not exist") end
    model.grid.each do |row|
      row.each do |tile|
        if (tile != 0 and tile != 1 and tile != 2) then raise GridModelContractError.new("Grid value incorrect, #{tile}") end 
      end
    end
  end 

  def self.pre_generate_grid(model)
    if model.x < 0 then raise GridModelContractError.new("column number should be greater than 0") end
    if model.y < 0 then raise GridModelContractError.new("row number should be greater than 0") end
  end

  def self.post_generate_grid(model)
    if model.grid == nil then raise GridModelContractError.new("Grid does not exist") end
  end

  def self.pre_column_depth(model, col)
    if col > model.x then raise GridModelContractError.new("column specified not within grid column range (#{model.x}, #{col})") end
  end

  def self.post_column_depth(model, val)
    if  val > model.y then raise GridModelContractError.new("depth exceeds grid height") end
    if  val < 0 then raise GridModelContractError.new("depth smaller than 0") end
  end

  def self.pre_get_value(model, x, y)
    invariant(model)
    if x < 0 then raise GridModelContractError.new("column index must be greater than zero: #{x}") end
    if y < 0 then raise GridModelContractError.new("row index must be greater than zero") end
    if x > model.x then raise  GridModelContractError.new("column index must be greater than grids row range") end
    if y > model.x then raise  GridModelContractError.new("row index must be smaller than grids row range") end
  end

  def self.post_get_value(model, val)
    if val != 0 and val != 1 and val != 2 then raise GridModelContractError.new("Grid Corrupted. Found incorrect value") end
  end

  def self.pre_set_value(model, x, y, val)
    invariant(model)
    if x < 0 then raise GridModelContractError.new("column index must be greater than zero") end
    if y < 0 then raise GridModelContractError.new("row index must be greater than zero") end
    if x > model.x then raise  GridModelContractError.new("column index must be greater than grids row range") end
    if y > model.x then raise  GridModelContractError.new("row index must be smaller than grids row range") end
    if val != 0 and val != 1 and val != 2 then raise GridModelContractError.new("Grid Set Value Incorrect") end 
  end

  def self.post_set_value(model)
    model.grid.each do |row|
      row.each do |val|
        if val != 0 and val != 1 and val != 2 then raise GridModelContractError.new("Grid Value Incorrect") end 
      end
    end
  end

  def self.pre_add_tile(model, x, playernum)
    if model.column_depth(x) == 0 then raise GridModelContractError.new("Cannot add tile to a full column") end
    if playernum != 1 and playernum != 2 then raise GridModelContractError.new("Playernum not within player range") end 
  end

  def self.post_add_tile(model)
    model.grid.each do |row|
      row.each do |val|
        if val != 0 and val != 1 and val != 2 then raise GridModelContractError.new("Grid Value Incorrect") end 
      end
    end
  end

  def self.post_reset(model)
    model.grid.each do |row|
      row.each do |val|
        if val != 0 then raise GridModelContractError.new("Grid Reset Corrupt") end 
      end
    end
  end

end