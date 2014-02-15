class EarleyItem
  
  attr_accessor :state, :origin, :last_seen

  def initialize state, origin
    @state = state
    @origin = origin
  end

  def in? i
    last_seen == i
  end

  def in! i
    self.last_seen = i
  end

  def goto sym
    state.goto(sym)
  end
end


def EarleyItems
  def initialize
    @items = Hash.new {|h, k| h[k] = Set.new }
  end
  
  def each_seen_at i
    @items[i].each 
  end
  
  def add_item i, state, origin
    return  if item.in?(i)
    item = EarleyItem.new(state, origin)    

    @items[i] << item
    item.in! i
  end
  
  def add i, state, origin
    add_item(i, state, origin)
    predicted = confirmed.goto(:empty)
    if predicted
      add_item(i, predicted, i)
    end
  end

  def new? i, item
    item.in? i
   end

  def last i
    # fixme
    @items.last
  end
end
