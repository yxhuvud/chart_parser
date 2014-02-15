class ProductionRule
  attr_accessor :lhs, :rhs, :pos, :accept

  def initialize lhs, rhs, pos=nil
    @lhs, = GrammarSymbol::builder(lhs)
    @rhs = GrammarSymbol::builder(rhs)
    @pos = pos
  end

  def to_s
    o = "#@lhs -> #{@rhs.inspect}"
    o << ",#{pos}"  if pos
    o
  end

  def empty?
    rhs == GrammarSymbol::EMPTY
  end

  def == other
    lhs == other.lhs && rhs == other.rhs && pos == other.pos
  end

  def sort_key
    [lhs.to_s, rhs.inspect, pos]
  end

  def penultimate?
    if @penul_calculated
      return @penul
    end
    @penul_calculated = true
    return nil  unless self.next
    if !GrammarSymbol::e_non_terminal?(postdot) && !self.next.next
      @penul = postdot
    else
      @penul = nil
    end
  end

  def next
    return @next  if @next
    pos = @pos
    pos += 1
    if postdot && GrammarSymbol::e_non_terminal?(rhs[pos])
      @next = ProductionRule.new(lhs, rhs, pos).next
    elsif postdot || pos == rhs.size
      @next = ProductionRule.new(lhs, rhs, pos)
    else
      nil
    end
  end

  def postdot
    rhs[@pos + 1]
  end

  def current
    rhs[@pos]
  end

  def consume_e_non_terminals
    pos = 0
    while GrammarSymbol::e_non_terminal?(rhs[pos])
      pos += 1
    end
    self.pos = pos
  end

  module Alias
    def rule lhs, *rhs
      ProductionRule.new lhs, rhs
    end
  end
end
