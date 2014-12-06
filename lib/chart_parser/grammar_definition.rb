module ChartParser
  class GrammarDefinition
    attr_accessor :symbol_table
    attr_accessor :rules, :start_symbols

    def self.define &block
      definition = new(SymbolTable.new)
      definition.instance_eval &block
      definition.generate
    end

    def generate
      Grammar.new(rules, start_symbols, symbol_table)
    end

    def initialize symbol_table
      @symbol_table = symbol_table
      @rules = Set.new
      @start_symbols = Set.new
    end

    def rule lhs, *rhs
      r = ProductionRule.new(lhs, rhs, symbol_table)
      symbol_table.add r.lhs
      r.rhs.each do |s|
        symbol_table.add(s)
      end
      rules << r
    end

    def start *symbols
      symbols.each {|s| start_symbols << s}
    end

    def empty
      ProductionRule::EMPTY
    end
  end
end
