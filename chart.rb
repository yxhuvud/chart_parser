class Chart
  class << self
    attr_accessor :psl
  end
  
  attr_accessor :index, :transitions, :psl, :items

  def initialize index, state_size
    @index = index
    @items = []
    @transitions = Hash.new {|h,k| h[k] = []}
    @psl = Array.new(state_size)
  end

  def to_s
    "Items(%s)[ %s ]" % 
      [index, items.map(&:to_s).join("  ")]
  end
  
  def add_item item
    return  if item.origin.psl[item.state.index] == index
    #    p 'adding [%s, %s]' % [state, origin && origin.index]
    item.origin.psl[item.state.index] = index
    @items << item
  end
  
  def add item
    add_item(item)
    predicted = item.goto(ProductionRule::EMPTY)
    if predicted 
      add_item(EarleyItem.new(predicted, self))
    end
  end

  def empty? 
    @items.empty?
  end

  def memoize_transitions
    @items.each do |item|
      item.postdot_symbols.each do |sym|
        next_item = item.goto(sym)
          transitions[sym] << EarleyItem.new(next_item, item.origin)
      end
    end
  end

  def leo_eligible? d_rule
    d_rule.right_recursive? && leo_unique?(d_rule)
  end

  # move to earley_set.
  def leo_unique? d_rule
    penult = d_rule.penult
    penult && items.contain?(d_rule) &&
      penult_unique?(earley_items, penult)
  end

  def penult_unique? items, penult
    items.map(&:penult).compact!.one?
  end

  def scan sym, current
    # FIXME: Use a proper lookup table.
 #   puts
  #  p "scanning %s" % sym
  #  p transitions
    transitions[sym].each { |item| current.add(item) }
  end

  def reduce
    items.each {|item| item.reduce(self) }
  end
  
  def accept?
    items.any? &:accept?
  end
  
  def completed sym
    # fixme more efficient!
    items.map(&:completed)
  end
end
