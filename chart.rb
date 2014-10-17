class Chart

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

  def inspect
    to_s
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
        next_state = item.goto(sym)
        if next_state.recursive? && next_state.penult?
          transitions[sym] << LeoItem.new(item.state, item.origin, sym)
        else
          transitions[sym] << EarleyItem.new(next_state, item.origin)
        end
      end
    end
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
