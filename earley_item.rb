class EarleyItem
  
  attr_accessor :state, :origin

  def to_s
    "Earley[%s, %s]" % [state, (origin && origin.index)]
  end

  def initialize state, origin
    @state = state
    @origin = origin
  end

  def goto sym
    state.goto(sym)
  end

  def accept?
    origin == nil && 
      state.accept?
  end

  def completed
    state.completed
  end

  def postdot_symbols
    state.postdot_symbols
  end
  
  def scan sym, items
    items.add goto(sym), origin
  end
  
  def reduce sym, items
    items.add(goto(sym), origin)
  end
end

class LeoItem < EarleyItem
  attr_accessor :trans

  def initialize eim, trans
    self.origin = eim.origin
    self.state = eim.state
    self.trans = trans
  end
  
  def reduce sym, items
    items.add_item(goto(trans), origin)
  end

  def to_s
    "Leo[%s, %s, %s]" % 
      [state, (origin && origin.index), trans]
  end
end

class EarleyItems
  class << self
    attr_accessor :psl
  end
  
  attr_accessor :index, :transitions, :psl, :items

  def initialize index, state_size
    @index = index
    @items = []
    @transitions = Hash.new {|h,k| h[k] = []}
    @psl = [nil] * state_size
  end

  def to_s
    "Items(%s)[ %s ]" % 
      [index, items.map(&:to_s).join("  ")]
  end
  
  def add_item state, origin
    return  if origin && (origin.psl[state.index] == index)
#    p 'adding [%s, %s]' % [state, origin && origin.index]
    origin.psl[state.index] = index  if origin
    item = EarleyItem.new(state, origin)    
    @items << item
  end
  
  def add state, origin
    add_item(state, origin)
    predicted = state.goto(:empty)
    if predicted
      add_item(predicted, self)
    end
  end

  def empty? 
   @items.empty?
  end

  def memoize_transitions
    @items.each do |item|
      item.postdot_symbols.each do |sym|
      #  if leo_eligible?(sym)
      #    transitions[sym] = [LeoItem.new(item, sym)]
      #  else
          transitions[sym] += [item]
      #  end
      end
    end
  end

  def leo_eligible? d_rule
    d_rule.right_recursive? && leo_unique?(d_rule)
  end

  # move to earley_set.
  def leo_unique? d_rule
    penult = d_rule.penult
    penult && earley_items.contain?(d_rule) &&
      penult_unique?(earley_items, penult)
  end

  def penult_unique? items, penult
    items.map(&:penult).compact!.one?
  end

  def scan sym, current
    # FIXME: Use a proper lookup table.
    s = GrammarSymbol::builder(sym).first
 #   puts
 #   p "scanning %s" % sym
 #   p transitions
    transitions[s].each do |item|
      item.scan(s, current)
    end
  end

  def reduce
    items.each do |item|
 #     p "reducing item %s" % item
      item.completed.each do |lhs|
        next  unless item.origin # start production!
  #      p 'completed: %s, pos %s' % [lhs, item.origin.index]
        reduce_sym(item.origin, lhs)
      end
    end
  end

  def reduce_sym source, sym
    source.transitions[sym].each do |item|
      item.reduce sym, self
    end
  end
  
  def accept?
    items.any? &:accept?
  end
end
