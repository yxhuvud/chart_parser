class State
  attr_accessor :dotted_rules, :state_machine, :transitions, :index
  attr_writer :accept

  def to_s
    index.to_s
  end

  def inspect
    "State %s:\n%s" % 
      [to_s, dotted_rules.map(&:inspect).join("\n")]
  end

  def initialize state_machine, dotted_rules, index
    @index = index
    @transitions = {}
    @state_machine = state_machine
    raise  if dotted_rules.empty?
    raise  unless dotted_rules.all? {|r| r.kind_of? ProductionRule}
    @dotted_rules = dotted_rules.sort_by &:sort_key
  end

  def add_transition sym, to
    transitions[sym] = to
  end

  def goto sym
    transitions[sym]
  end

  def postdot_symbols
    transitions.keys
  end

  def nonkernels grammar
    expanded_rules = Set.new
    visited = Set.new
    lhss_to_find = dotted_rules.map(&:current).compact.uniq
    while (lhs = lhss_to_find.pop)
      next  if visited.include?(lhs)
      next  if grammar.symbol_table.e_non_terminal?(lhs)
      visited << lhs
      rules = grammar.matching_rules(lhs)
      rules.each do |exp|
        lhss_to_find << exp.rhs.first
        expanded_rules << exp
      end
    end
    expanded_rules.to_a
  end

  def generate_transitions
    nexts = @dotted_rules.group_by(&:current)
    nexts.each do |k, v|
      nexts[k] = v.map(&:next).compact
    end
    nexts.reject {|k, v| v.empty? }
  end

  def accept?
    @accept
  end
  
  def completed
    @completed ||= completed_rules.map(&:lhs)
  end
  
  def completed_rules
    dotted_rules.select &:completed?
  end
end
