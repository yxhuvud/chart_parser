AMBIGOUS_A = ChartParser::grammar do
  start :Start

  rule :Start, :S
  rule :S, :A, :A, :A, :A
  rule :A, 'a'
  rule :A, :E
  rule :E, empty
end
