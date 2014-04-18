require 'spec_helper'

describe Marpa do 
  let!(:palindrome) { PALINDROME }
  let!(:ambigous_a) { AMBIGOUS_A }
  let!(:right_recursive) { RIGHT_RECURSIVE }
  let!(:left_recursive) { LEFT_RECURSIVE }

  describe :palindrome do 
    let(:parser) { Marpa.new(palindrome) }
    subject { parser }
    its(:chart) { should have(2).items }
    
    describe :empty do
      before { @result = parser.parse("") }
      it("fails") { @result.should be_false }
      
      describe :items do 
        subject { parser.chart }
        its(:items) { should have(2).items }
      end
    end

    describe :one_char do 
      before { @result = parser.parse("a") }
      it("succeds") { @result.should be_true }
    end

    it "parse 'ab'" do 
      subject.parse("ab").should be_false
    end

    it "parse 'ab'" do 
      subject.parse("ab").should be_false
    end

    it "parse 'abc'" do 
      subject.parse("abc").should be_false
    end

    it "parse 'aba'" do 
      r = subject.parse("a")
      r.should be_true
      r = subject.parse("b")
      r.should be_false
      r = subject.parse("a")
      r.should be_true
      r = subject.parse("a")
      r.should be_false
      r = subject.parse("b")
      r.should be_false
      r = subject.parse("a")
      r.should be_true
    end

    describe :multiple_chars do 
      before { @result = parser.parse("abaab") }
      it("fails") { @result.should be_false }
      it("succeeds after continuing") do
        result = parser.parse("a")
        result.should be_true 
      end

    end

    it "parse 'abaaba'" do 
      subject.parse("abaaba").should be_true
    end

    it "parse 'abcba'" do 
      subject.parse("abcba").should be_true
    end
  end

  describe :left_recursion do
    let(:parser) { Marpa.new(left_recursive) }
    subject { parser }

    it :parses do
      xs = 'x' * 100
      subject.parse(xs).should be_true
    end

    it :without_using_n_states_per_chart do
      xs = 'x' * 100
      subject.parse xs
      subject.chart.items.size.should < 5
      #puts
     # p subject.state_machine
     # puts subject.charts.map(&:inspect).join("\n")
    end
  end

  describe :right_recursion do
    let(:parser) { Marpa.new(right_recursive) }
    subject { parser }

    it :parses do
      xs = 'x' * 100
      subject.parse(xs).should be_true
    end

    it :without_using_n_states_per_chart do
      xs = 'x' * 10
      subject.parse xs
      # puts
      # p subject.state_machine
      puts subject.charts.map(&:inspect).join("\n")
      subject.chart.items.size.should < 5
    end
  end
end
