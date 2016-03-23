module Models
  class Model

    ##
    # Abstract interface for model

    include AbstractInterface

    needs_implementation :update

    @observers = []
    
    def add_observer(observer)
      @observers.push(observer)
    end

    def remove_observer(observer)
      @observers.delete(observer)
    end

    def notify_observers()
      @observers.each do |oberserver|
        observer.update()
      end
    end
  end
end