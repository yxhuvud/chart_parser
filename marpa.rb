require 'set'
require 'grammar'


class AHFA
  def initialize grammar
  end

  def goto from, trans
  end
end

def EarlyItems
  START_ITEM = [0, :start, 0]

  def initialize
    @psl = fdsaofd #fdofdsa

    @items = Hash.new {|h, k| h[k] = Set.new }
    add *START_ITEM
  end

  def add i, confirmed
    confirmed_item = [confirmed, origin]
    predicted = goto(confirmed, :empty)
    if confirmed_item new?
      @items[i] << confirmed_item
    end
    if predicted
      predicted_item = [predicted, i]
      if predicted_item new?
        @items[i] << predicted_item
      end
    end
  end

  def new? item
  end

  def last i
    @items.last
  end
end

class Marpa
  attr_accessor :earley_items, :source


  def initialize grammar
    @transitions = {|h,k|  h[k] = {} }
  end

  def setup
    @earley_items = EarleyItems.new
  end

  def parse source
    setup
    @source = source
    source.each_char.with_index do |char, i|
      scan_pass i, char
      if earley_items.last i
        return false
      end
      reduction_pass i
    end
    @earley_items[source.size].any? {|rule| rule.accept? }
  end

  def scan_pass i, sym
    transitions(i - 1, sym).each do |from, origin|
      to = goto(from, sym)
      @earley_items.add i, to, origin
    end
  end

  def reduction_pass i
    @earley_items.each do |work, origin|
      lh_sides = completed_rules(work)
      lh_sides.each do |lhs|
        reduce_one_lhs(i, origin, lhs)
      end
    end
    memoize_transitions i
  end

  def memoize_transitions i
    postdot_symbols(i).each do |sym|
      if leo_eligible?(sym)
        transitions[i][sym] = LIM #??
      else
        transitions[i][sym] = postdot_match(i, sym)
      end
    end
  end

  def reduce_one_lhs i, origin, lhs
    transitions[i][lhs].each do |pim|
      if LIM
        leo_reduction_operation i, pim
      else
        earley_reduction_operation i, pim, lhs
      end
    end
  end

  def earley_reduction_operation i, from, trans
    from_ah, origin = *from
    to_ah = goto(from_ah, trans)
    @earley_items.add i, to_ah, origin
  end

  def leo_reduction_operation i, from
    from_ah, trans, origin = *from
    to_ah = goto(from_ah, trans)
    @earley_items.add i, to_ah, origin
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
