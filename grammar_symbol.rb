require 'set'

class GrammarSymbol
  EMPTY = :empty
  # TODO: Lookuptable for terminals.
  SYMBOLS = {}
  attr_accessor :sym, :e_non_terminal

  class << self
    attr_accessor :e_non_terminals
    def builder args
      Array(args).map {|arg|
        case
        when arg.instance_of?(self)
          arg
        when SYMBOLS[arg]
          SYMBOLS[arg]
        else
          SYMBOLS[arg] = new(arg)
        end
      }
    end

    def e_non_terminal! sym
      self.e_non_terminals ||= Set.new
      e_non_terminals << sym
    end

    def e_non_terminal? sym
      if sym.kind_of? self
        sym = sym.sym
      end
      return false  unless e_non_terminals
      e_non_terminals.include? sym
    end

    def e sym
      "#{sym}'"
    end
  end

  def initialize sym, terminal=false
    @sym = sym
    @e_non_terminal = self.class.e_non_terminal?(sym)
    @terminal = terminal
  end

  def terminal?
    terminal
  end

  def e_non_terminal?
    @e_non_terminal
  end

  def has_e_non_terminal?
    @e_non_terminal || self.class.e_non_terminal?(e)
  end

  def to_e_non_terminal!
    return self  if e_non_terminal?
    self.sym = e
    self.e_non_terminal = true
    self.class.e_non_terminal! self.sym
    self
  end

  def e
    self.class.e(sym)
  end

  def to_e_non_terminal
    copy = dup
    copy.to_e_non_terminal!
  end

  def == other
    sym == other.sym
  end

  def to_s
    sym.to_s
  end

  def inspect
    "%s" % to_s
  end
end
