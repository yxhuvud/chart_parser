include ProductionRule::Alias

start = GrammarSymbol.new("Start")
s = GrammarSymbol.new("S")
s2 = GrammarSymbol.new("S2")

production_rules = [
                    rule(start, s),
                    rule(s, 'a', s2, 'a'),
                    rule(s, 'b', s2, 'b'),
                    rule(s, 'c', s2, 'c'),
                    rule(s, 'a'),
                    rule(s, 'b'),
                    rule(s, 'c'),

                    rule(s2, GrammarSymbol::EMPTY),
                    rule(s2, s),
                   ]

terminals = %w(a b c)

PALINDROME = Grammar.new(production_rules, terminals, start)
