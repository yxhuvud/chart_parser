LEFT_RECURSIVE = ChartParser::grammar do
  start :S

  rule :S, :S, 'x'
  rule :S, 'x'
end
