module ChartParser
  class ParseGenerator
    attr_accessor :parser, :charts

    def initialize parser
      @parser = parser
      @charts = parser.charts
      parser
    end
  end
end
