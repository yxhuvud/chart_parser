require 'set'
require 'grammar'
rqeuire 'earley_item'

class Marpa
  attr_accessor :earley_items, :source, :state_machine

  def initialize grammar
    @transitions = {|h,k|  h[k] = {} }
    @state_machine = StateMachine.new(grammar)
    @earley_items = EarleyItems.new
  end

  def parse source
    @source = source
    source.each_char.with_index method(:parse_char)
    success?
  end

  def parse_char char, i
    scan_pass i, char
    # ???
    if earley_items.last(i)
      return
    end
    reduction_pass i
  end

  def success?
    earley_items[source.size].any? &:accept?
  end

  def scan_pass i, sym
    transitions(i - 1, sym).each do |from, origin|
      to = from.goto(sym)
      earley_items.add i, to, origin 
    end
  end

  def reduction_pass i
    earley_items.each_seen_at(i) do |item| #|work, origin|
      lh_sides = item.state.completed_rules.map(&:lhs)
      lh_sides.each do |lhs|
        reduce_one_lhs(i, item.origin, lhs)
      end
    end
    memoize_transitions i
  end

  def memoize_transitions i
    postdot_symbols.each do |sym|
    #  if leo_eligible?(sym)
    #    transitions[i][sym] = LIM #??
    #  else
        transitions[i][sym] = postdot_match(i, sym)
   #   end
    end
  end

  def reduce_one_lhs i, origin, lhs
    transitions[i][lhs].each do |pim|
   #   if LIM
   #     leo_reduction_operation i, pim
   #   else
        earley_reduction_operation i, pim, lhs
   #   end
    end
  end

  def earley_reduction_operation i, from, trans
    to_ah = from.goto(trans) # from = from_ah
    earley_items.add i, to_ah, from.origin
  end

  def leo_reduction_operation i, from
    from_ah, trans, origin = *from
    to_ah = from_ah.goto(trans)
    earley_items.add i, to_ah, origin
  end

  # todo helpers
  def leo_eligible? d_rule, loc
    d_rule.right_recursive? && leo_unique?(@earley_items[loc], d_rule)
  end

  # move to earley_set.
  def leo_unique? items, d_rule
    penult = d_rule.penult
    penult && items.contain?(d_rule) &&
      penult_unique?(items, penult)
  end

  # move to earley_set?
  def penult_unique? items, penult
    items.map(&:penult).compact!.count == 1
  end

  def postdot_match? i, sym
  end
end
