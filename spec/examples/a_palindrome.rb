A_PALINDROME = ChartParser::grammar do
  start :S

  rule :S, 'a', :S2, 'a'
  rule :S, 'a'

  rule :S2, empty
  rule :S2, :S
end
