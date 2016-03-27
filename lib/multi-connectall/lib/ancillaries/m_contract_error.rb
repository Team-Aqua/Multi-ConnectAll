class MContractError < RuntimeError
  def initialize(error)
    abort("#{self.class.name} : #{error}")
  end
end