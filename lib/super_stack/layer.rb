module SuperStack
  class Layer < Hash

    include SuperStack::LayerWrapper

    def initialize(*args)
      super(*args)
      SuperStack::LayerWrapper.from_hash self
    end
  end
end