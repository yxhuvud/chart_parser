class State
  attr_accessor :dotted_rules, :state_machine, :transitions, :index, :recursions
  attr_writer :accept, :penult

  def to_s
    index.to_s
  end

  def inspect
    transs = transitions.map do |sym, dest|
      "%s->%s" % [sym, dest]
    end.join(" ")
    accept = accept? ? '+': ''
    rec = recursive? ? 'r' : ''
    pen = penult? ? '|' : ''
    "State %s %s:\n%s\n--> %s" %
      [to_s, accept+rec+pen, dotted_rules.map(&:inspect).join("\n"), transs]
  end

  def initialize state_machine, dotted_rules, index
    @index = index
    @transitions = {}
    @recursions = Set.new
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
    nexts.reject do |k, v|
      v.empty? || v == self.dotted_rules
    end
  end

  def accept?
    @accept
  end

  def completed
    @completed ||= completed_rules.map(&:lhs)
  end

  def completed_rules
    @completed_rules ||= dotted_rules.select(&:completed?)
  end

  def mark_recursive
    expanded = goto(ProductionRule::EMPTY)
    return  unless  expanded
    expanded.transitions.each do |k, v|
      (recursions << k)  if v == self
    end
  end

  def mark_penult
    @penult = transitions.all? do |k, v|
      next true  if k == ProductionRule::EMPTY
      v.transitions.empty?
    end
  end

  def penult?
    @penult
  end

  def recursive?
    recursions.any?
  end

  def leo?
    recursive? && penult?
  end
end
