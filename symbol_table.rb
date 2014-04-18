class SymbolTable
  attr_accessor :symbols, :e_non_terminals

  def initialize
    @symbols = Set.new
    @e_non_terminals = Set.new
  end

  def [] sym
    symbol[sym]
  end

  def add sym
    if sym == ProductionRule::EMPTY
      e_non_terminal! sym
    end
    @symbols << sym
    sym
  end

  def terminal? sym
    !sym.kind_of? Symbol
  end

  def e_non_terminal! sym
    e_non_terminals << sym
  end

  def e_non_terminal? sym
    e_non_terminals.include? sym
  end

  def has_e_non_terminal? sym
    e_non_terminal?(sym) || e_non_terminal?(e(sym))
  end

  def to_e_non_terminal sym
    return sym  if e_non_terminal?(sym)
    e_non = e(sym)
    e_non_terminal! e_non
    e_non
  end

  def e sym
    :"#{sym.to_s}'"
  end
end
