# Run Length Encoding - Ian Eustis 2020
class RunLengthEncoding
  # chunks adjacent characters that are the same then creates a string
  def self.encode(string)
    string.chars.chunk(&:itself).each_with_object('') do |(element, array), str|
      str << (array.length > 1 ? array.length.to_s + element : element)
    end
  end

  def self.decode(string)
    string.gsub(/\d+\D/) { |match| match[-1] * match.to_i }
  end
end
