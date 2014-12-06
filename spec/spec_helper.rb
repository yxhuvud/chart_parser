require 'rspec/its'
require 'rspec/collection_matchers'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

require File.expand_path('./lib/chart_parser.rb')

include ChartParser

require File.expand_path('./examples/palindrome')
require File.expand_path('./examples/a_palindrome')
require File.expand_path('./examples/ambigous_a')
require File.expand_path('./examples/right_recursive')
require File.expand_path('./examples/left_recursive')
