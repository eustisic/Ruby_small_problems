# Ian Eustis 2020 - wordy exercise
class WordProblem
  METHODS = %w(plus minus multiplied divided).freeze

  def initialize(problem)
    @problem = problem.scan(/-?\w+/)
    @reduction = []
    @method = nil
  end

  def number?(number)
    number == number.to_i.to_s
  end

  def method?(word)
    METHODS.include?(word)
  end

  def valid_problem?(number)
    number?(number) && !@method.nil?
  end

  def plus(args)
    @reduction = [args.reduce(:+)]
    @method = nil
  end

  def minus(args)
    @reduction = [args.reduce(:-)]
    @method = nil
  end

  def multiplied(args)
    @reduction = [args.reduce(:*)]
    @method = nil
  end

  def divided(args)
    @reduction = [args.reduce(:/)]
    @method = nil
  end

  def error_check
    @problem.any? { |word| method?(word) }
  end

  def parse_problem
    @problem.each do |word|
      if valid_problem?(word)
        @reduction << word.to_i
        send @method, @reduction
      elsif number?(word)
        @reduction << word.to_i
      elsif method?(word)
        @method = word
      end
    end
  end

  def answer
    raise ArgumentError unless error_check
    parse_problem
    @reduction[0]
  end
end
