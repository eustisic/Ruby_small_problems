# Ian Eustis - May 2020
class PhoneNumber
  INVALID = '0000000000'.freeze
  def initialize(phone_number)
    @number = phone_number.scan(/\w/i).join
  end

  def number
    if @number.match?(/[a-z]/i)
      INVALID
    elsif @number.length == 11 && @number[0] == '1'
      @number[1..-1]
    elsif @number.length == 10
      @number
    else
      INVALID
    end
  end

  def area_code
    number.slice(0, 3)
  end

  def to_s
    number.gsub(/\A(\d{3})(\d{3})(\d{4})/, '(\1) \2-\3')
  end
end
