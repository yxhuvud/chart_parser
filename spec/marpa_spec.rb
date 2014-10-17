require 'spec_helper'

describe Marpa do
  let!(:a_palindrome) { A_PALINDROME }
  let!(:palindrome) { PALINDROME }
  let!(:ambigous_a) { AMBIGOUS_A }
  let!(:right_recursive) { RIGHT_RECURSIVE }
  let!(:left_recursive) { LEFT_RECURSIVE }

  describe :a_palindrome do
    let(:parser) { Marpa.new(a_palindrome) }
    subject { parser }

    its(:chart) { should have(1).items }

    it("one_char succeds") { parser.parse("a").should be_truthy }

    it "parse 'aa'" do
      subject.parse("aa").should be_truthy
    end

    it "parse 'aaa'" do
      subject.parse("aaaaa").should be_truthy
    end
  end

  describe :palindrome do
    let(:parser) { Marpa.new(palindrome) }
    subject { parser }
    its(:chart) { should have(1).items }

    describe :empty do
      before { @res = parser.parse("") }
      it("fails") { @res.should be_falsey }

      describe :items do
        subject { parser.chart }
        its(:items) { should have(1).items }
      end
    end

    describe :one_char do
      subject { parser.parse("a") }
      it("succeds") { should be_truthy }
    end

    it "parse 'ab'" do
      subject.parse("ab").should be_falsey
    end

    it "parse 'abc'" do
      subject.parse("abc").should be_falsey
    end

    it "parse 'aba'" do
      r = subject.parse("a")
      r.should be_truthy
      r = subject.parse("b")
      r.should be_falsey
      r = subject.parse("a")
      r.should be_truthy
      r = subject.parse("a")
      r.should be_falsey
      r = subject.parse("b")
      r.should be_falsey
      r = subject.parse("a")
      r.should be_truthy
    end

    describe :multiple_chars do
      before { @result = parser.parse("abaab") }
      it("fails") { @result.should be_falsey }
      it("succeeds after continuing") do
        result = parser.parse("a")
        result.should be_truthy
      end
    end

    it "parse 'abaaba'" do
      subject.parse("abaaba").should be_truthy
    end

    it "parse 'abcba'" do
      subject.parse("abcba").should be_truthy
    end
  end

  describe :left_recursion do
    let(:parser) { Marpa.new(left_recursive) }
    subject { parser }

    it :parses do
      xs = 'x' * 100
      subject.parse(xs).should be_truthy
    end

    it :without_using_n_states_per_chart do
      xs = 'x' * 10
      subject.parse xs
      subject.chart.items.size.should < 5
      # puts
      # p subject.state_machine
      # puts subject.charts.map(&:inspect).join("\n")
    end
  end

  describe :right_recursion do
    let(:parser) { Marpa.new(right_recursive) }
    subject { parser }

    it :parses do
      xs = 'x' * 100
      subject.parse(xs).should be_truthy
    end

    it :without_using_n_states_per_chart do
      xs = 'x' * 10
      subject.parse xs
      # puts
      # p subject.state_machine
      # puts subject.charts.map(&:inspect).join("\n")
      subject.chart.items.size.should < 5
    end
  end
end
