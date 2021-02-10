class NoSolutionError < StandardError; end
# Calculates Luhn check numbers.
class Luhn
  def initialize(number)
    @numbers = number.digits
  end

  def addends
    @numbers.map.with_index do |number, index|
      if index.odd?
        number >= 5 ? (number * 2 - 9) : number * 2
      else
        number
      end
    end.reverse
  end

  def checksum
    addends.sum
  end

  def valid?
    (checksum % 10).zero?
  end

  def self.create(check_num)
    check_num *= 10
    10.times do
      return check_num if new(check_num).valid?
      check_num += 1
    end
    raise NoSolutionError
  end
end
