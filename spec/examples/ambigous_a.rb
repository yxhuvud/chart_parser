include ProductionRule::Alias

start = GrammarSymbol.new("Start")
s = GrammarSymbol.new("S")
a = GrammarSymbol.new("A")
e = GrammarSymbol.new("E")
production_rules = [
                    rule(start, s),
                    rule(s, a, a, a, a),
                    rule(a, 'a'),
                    rule(a, e),
                    rule(e, GrammarSymbol::EMPTY)
                   ]
terminals = %w(a)

AMBIGOUS_A = Grammar.new(production_rules, terminals, start)
