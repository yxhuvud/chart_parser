include ProductionRule::Alias

production_rules = [
                    rule(:Start, :S),

                    rule(:S, 'a', :S2, 'a'),
                    rule(:S, 'b', :S2, 'b'),
                    rule(:S, 'c', :S2, 'c'),
                    rule(:S, 'a'),
                    rule(:S, 'b'),
                    rule(:S, 'c'),

                    rule(:S2, GrammarSymbol::EMPTY),
                    rule(:S2, :S),
                   ]

PALINDROME = Grammar.new(production_rules, :Start)
