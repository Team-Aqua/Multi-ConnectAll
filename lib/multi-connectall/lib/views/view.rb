module Views
  class View

    ## 
    # Abstract class for views structure
    # Builds basic framework for views

    include AbstractInterface
    needs_implementation :update
    
    @controller = nil
    @model = nil

    ## 
    # Attaches model to view
    # Inputs: model
    # Outputs: none

    def set_model(model)
      @model = model
    end
  end
end