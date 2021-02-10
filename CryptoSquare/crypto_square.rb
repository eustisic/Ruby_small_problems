# Crypto Square - 2020 Ian Eustis
class Crypto
	attr_reader :size

	def initialize(string)
		@sanitized = string.downcase.scan(/\w/)
		@size = Math.sqrt(@sanitized.length).ceil
	end

	# divide the string into segments and pad with white space
	def segments
		segments = @sanitized.each_slice(size).to_a
		segments.each do |seg| 
			if seg.length <  @size
				(@size - seg.length).times { seg.push(' ') }
			end
		end

		segments
	end

	def normalize_plaintext
		@sanitized.join
	end

	def plaintext_segments
		join_strip(segments)
	end

	def cipher
		join_strip(segments.transpose)
	end

	def ciphertext
		cipher.join
	end

	def normalize_ciphertext
		cipher.join(' ')
	end

	private

	# returns a new array with sub arrays joined and stripped
	def join_strip(array)
		array.map { |seg| seg.join.rstrip }
	end
end
