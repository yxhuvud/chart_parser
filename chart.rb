class Chart
  attr_accessor :index, :transitions, :psl, :items, :parser

  def initialize index, state_size, parser
    @index = index
    @items = []
    @transitions = Hash.new {|h,k| h[k] = []}
    @psl = {}
    @parser = parser
  end

  def to_s
    "Items(%s)[ %s ]" %
      [index, items.map(&:to_s).join("  ")]
  end

  def inspect
    to_s
  end

  def add_item item
    return  if psl[item]
    psl[item] = true
    @items << item
    true
  end

  def add item
    ret = add_item(item)
    predicted = item.goto(ProductionRule::EMPTY)
    if predicted
      e_node = SPPFNode.new(ProductionRule::EMPTY, index, index)
      predicted_item = EarleyItem.new(predicted, self)
      add_item(predicted_item)
      item.node.family e_node
      predicted_item.node = e_node
    end
    ret
  end

  def empty?
    @items.empty?
  end

  def memoize_transitions
    @items.each do |item|
      item.postdot_symbols.each do |sym|
        next_state = item.goto(sym)
        transitions[sym] << if next_state.leo?
                              LeoItem.new(item.state, item.origin, sym)
                            else
                              EarleyItem.new(next_state, item.origin)
                            end
      end
    end
  end

  def scan char, current
    # FIXME: Use a proper lookup table.
    node = SPPFNode.new(char, self.index - 1, self.index)
    transitions[char].each do |item|
      # FIXME: Instead of storing on item, look at the state machine
      # when needed.
      item.node = node
      current.add(item)
    end
  end

  def reduce
    items.each {|item| item.reduce(self) }
  end

  def accept?
    items.any? &:accept?
  end

  def accepted_items
    items.select &:accept?
  end

  def completed sym
    # fixme more efficient!
    items.map(&:completed)
  end
end
