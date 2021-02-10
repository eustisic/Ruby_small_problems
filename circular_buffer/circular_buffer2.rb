# Ian Eustis May 2020
class CircularBuffer

  class BufferFullException < StandardError; end
  class BufferEmptyException < StandardError; end

  def initialize(size)
    @max_size = size
    @buffer = []
  end

  def write(new_element)
    update_buffer(new_element) { raise(BufferFullException) }
  end

  def read
    @buffer.shift || raise(BufferEmptyException)
  end

  def clear
    @buffer = []
  end

  def write!(new_element)
    update_buffer(new_element) { @buffer.shift }
  end
  
  def update_buffer(new_element)
    return if new_element.nil?
    yield if @buffer.size == @max_size
    @buffer << new_element
  end
end
