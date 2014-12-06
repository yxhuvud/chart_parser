require 'rspec/its'
require 'rspec/collection_matchers'
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

require File.expand_path('./lib/chart_parser.rb')

include ChartParser

require 'examples/palindrome'
require 'examples/a_palindrome'
require 'examples/ambigous_a'
require 'examples/right_recursive'
require 'examples/left_recursive'
