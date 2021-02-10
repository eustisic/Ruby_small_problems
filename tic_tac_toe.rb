# Tic Tac Toe 2020 - Ian Eustis
class Board
  attr_accessor :squares, :size, :winning_lines

  def initialize(size)
    @winning_lines = []
    @size = size
    @squares = {}
    (1..(@size**2)).each { |key| @squares[key] = Square.new }
    winning_combos
  end

  def runs_of(num, array)
    array.each_cons(num) { |lines| @winning_lines << lines }
  end

  def left_diagonal_lines(array)
    array.each_with_index do |row, index|
      ((@size - 1) - index).times { row.prepend(nil) }
      index.times { row.append(nil) }
    end
    array.transpose.each { |col| runs_of(3, col) }
    array.map!(&:compact)
  end

  def right_diagonal_lines(array)
    array.each_with_index do |row, index|
      ((@size - 1) - index).times { row.append(nil) }
      index.times { row.prepend(nil) }
    end
    array.transpose.each { |col| runs_of(3, col) }
  end

  def winning_combos
    array_of_board = []
    (1..(@size**2)).to_a.each_slice(@size) { |row| array_of_board << row }

    array_of_board.each { |row| runs_of(3, row) }
    array_of_board.transpose.each { |col| runs_of(3, col) }
    left_diagonal_lines(array_of_board)
    right_diagonal_lines(array_of_board)

    @winning_lines.select! { |x| x.all?(Numeric) }
  end

  def draw
    squares_array = Array.new(@size**2) { |i| "  #{@squares[i + 1]}  " }
    buffer = Array.new(@size, "     ").join('|')
    dividor = Array.new(@size, "-----").join('+')

    @size.times do |num|
      puts buffer
      puts squares_array.shift(@size).join("|")
      puts buffer
      break if num == (@size - 1)
      puts dividor
    end
  end

  def reset
    (1..(@size**2)).each { |key| @squares[key] = Square.new }
  end

  def dup
    dupboard = Board.new(@size)
    dupboard.squares = squares.map { |index, square| [index, square.dup] }.to_h
    dupboard
  end

  def new?
    unmarked_keys.size == @size**2
  end

  def last?
    unmarked_keys.size == 1
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.select { |_, sq| sq.unmarked? }.keys
  end

  def joinor
    array = unmarked_keys
    case array.size
    when 1 then array.join
    when 2 then array[0].to_s + ' or ' + array[1].to_s
    else
      array[0, array.size - 1].join(', ') + ', or ' + array[-1].to_s
    end
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    winning_marker
  end

  def count_markers(squares)
    marks = squares.collect(&:marker).uniq
    marks.size == 1 && !marks.any?(Square::INITIAL_MARKER) ? marks.first : nil
  end

  def winning_marker
    @winning_lines.each do |line|
      if count_markers(@squares.values_at(*line))
        return count_markers(@squares.values_at(*line))
      end
    end
    nil
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_accessor :name, :marker, :score, :choice

  def initialize(name, marker, score)
    @name = name
    @marker = marker
    @score = score
    @choice = nil
  end

  def change_name
    name = ''
    loop do
      puts "Enter #{self}'s name:"
      name = gets.chomp
      break unless name.strip.empty?
      puts "Name must include at least one character."
    end
    @name = name
  end

  def to_s
    @name
  end
end

class Computer < Player
  COMPUTER_MARKER = "O"
end

class Human < Player
  def change_marker
    answer = ''
    loop do
      puts "Pick any single character as your marker!"
      answer = gets.chomp
      break if answer.strip.size == 1 && answer != Computer::COMPUTER_MARKER
      puts "Not a valid marker."
    end
    @marker = answer
  end

  def who_moves_first
    puts "Who should move first, player or computer? (p/c)"
    answer = ''
    loop do
      answer = gets.chomp.downcase
      break if ["p", "c"].include?(answer)
      puts "Not a valid selection."
    end
    answer == "p" ? @marker : Computer::COMPUTER_MARKER
  end
end

class TTTGame
  private

  attr_reader :board, :human, :computer
  attr_accessor :current_marker

  def initialize
    @human = Human.new('player', 'X', 0)
    @computer = Computer.new('computer', Computer::COMPUTER_MARKER, 0)
  end

  def board_size
    puts "What shall the board size be? (3/5/9)"
    size = nil
    loop do
      size = gets.chomp.to_i
      break if [3, 5, 9].include?(size)
      puts "Not a valid board size"
    end
    size
  end

  def set_playfirst_marker
    @current_marker = human.who_moves_first
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear
    system('clear') || system('cls')
  end

  def display_board
    puts "#{human.name}: #{human.marker}"
    puts "#{computer.name}: #{computer.marker}"
    board.draw
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def human_turn?
    @current_marker == human.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = Computer::COMPUTER_MARKER
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def human_moves
    square = nil
    puts "Choose a square: (#{board.joinor})"
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    minimax(board, @computer)
    board[computer.choice] = computer.marker
  end

  def switch(player)
    player.marker == human.marker ? @computer : @human
  end

  def minimax_score(state)
    case state.winning_marker
    when computer.marker then 10
    when human.marker then -10
    else 0
    end
  end

  def minimax(brd, player, depth=0)
    return minimax_score(brd) if game_over?(brd) || depth >= 10
    scores = {}
    brd.unmarked_keys.each do |square|
      possible_state = brd.dup
      possible_state[square] = player.marker
      scores[square] = minimax(possible_state, switch(player), depth += (1))
    end

    computer.choice, best_score = minormax(scores, player)

    best_score
  end

  def minormax(scores, player)
    if player.marker == computer.marker
      scores.max_by { |_, v| v }
    else
      scores.min_by { |_, v| v }
    end
  end

  def keep_scores
    case board.winning_marker
    when human.marker then human.score += 1
    when computer.marker then computer.score += 1
    end
  end

  def display_scores
    puts "#{human.name} has #{human.score} wins."
    puts "#{computer.name} has #{computer.score} wins."
  end

  def game_setup
    puts "Welcome to Tic Tac Toe!"
    puts ''
    @board = Board.new(board_size)
    human.change_name
    computer.change_name
    human.change_marker
    set_playfirst_marker
    clear
  end

  def display_result
    display_board
    case board.winning_marker
    when human.marker then puts "You won!"
    when computer.marker then puts "Computer won!"
    else
      puts "It's a tie!"
    end
    keep_scores
    display_scores
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def reset_game
    board.reset
    clear
    set_playfirst_marker
    display_play_again_message
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ''
  end

  def game_rounds
    display_board
    loop do
      current_player_moves
      break if game_over?(board)
      clear_screen_and_display_board if human_turn?
    end
    display_result
  end

  def game_over?(brd)
    brd.someone_won? || brd.full?
  end

  public

  def play
    game_setup

    loop do
      game_rounds
      break unless play_again?
      reset_game
    end

    display_goodbye_message
  end
end

TTTGame.new.play
