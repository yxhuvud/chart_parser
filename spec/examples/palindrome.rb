PALINDROME = GrammarDefinition.define do 
  start :S

  rule :S, 'a', :S2, 'a'
  rule :S, 'b', :S2, 'b'
  rule :S, 'c', :S2, 'c'
  rule :S, 'a'
  rule :S, 'b'
  rule :S, 'c'
  
  rule :S2, empty
  rule :S2, :S
end
