class ProductionRule
  EMPTY = :":empty::"

  attr_accessor :lhs, :rhs, :pos, :symbol_table

  def initialize lhs, rhs, symbol_table, pos=nil
    raise  if symbol_table.kind_of? Integer # refactoring
    unless lhs.kind_of?(Symbol) || lhs.sym.kind_of?(Symbol)
      raise  ArgumentError  
    end
    # FIXME ADD support for differentiating terminals and
    # nonterminals.
    @symbol_table = symbol_table
    @lhs = symbol_table.add(lhs)
    @rhs = rhs.map {|s| symbol_table.add(s)}
    @pos = pos
  end

  def to_s
    o = "#{@lhs} -> #{@rhs.inspect}"
    o << ",#{pos}"  if pos
    o
  end

  def inspect
    to_s
  end

  def empty?
    rhs == [EMPTY]
  end

  def == other
    lhs == other.lhs && rhs == other.rhs && pos == other.pos
  end

  def sort_key
    [lhs.inspect, rhs.inspect, pos]
  end

  def penultimate?
    if @penul_calculated
      return @penul
    end
    @penul_calculated = true
    return nil  unless self.next
    if !symbol_table.e_non_terminal?(postdot) && !self.next.next
      @penul = postdot
    else
      @penul = nil
    end
  end

  def completed?
    !self.next
  end

  def next
    return @next  if @next
    pos = @pos
    pos += 1
    if postdot && symbol_table.e_non_terminal?(rhs[pos])
      @next = ProductionRule.new(lhs, rhs, symbol_table, pos).next
    elsif postdot || pos == rhs.size
      @next = ProductionRule.new(lhs, rhs, symbol_table, pos)
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
    while symbol_table.e_non_terminal?(rhs[pos])
      pos += 1
    end
    self.pos = pos
  end
end
