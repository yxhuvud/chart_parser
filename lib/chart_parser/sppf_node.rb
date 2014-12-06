module ChartParser
  class SPPFNode
    attr_accessor :element, :start, :stop, :family

    def initialize element, start, stop
      @element = element
      @start = start
      @stop = stop
      @family = Set.new
    end

    def family item
      @family << item
    end

    def inspect
      "#{element}[#@start #@stop]"
    end
  end
end
