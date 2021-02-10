module Hand
  BUST_LIMIT = 21
  def aces
    hand.select { |card| card.face == 'Ace' }
  end

  def display_hand
    hand.inject('') { |string, card| string + " #{card}" }.center(20)
  end

  def total
    total_value = hand.inject(0) { |sum, card| sum + card.value }
    aces_array = aces

    while total_value > BUST_LIMIT && !aces_array.empty?
      total_value -= 10
      aces_array.pop
    end

    total_value
  end
end

class Participant
  include Hand
  attr_accessor :name, :hand

  def initialize(name)
    @name = name
    @hand = []
  end

  def to_s
    @name
  end

  def value_of_hand
    puts "#{self} has #{total}"
  end

  def busted?
    total > BUST_LIMIT
  end
end

class Player < Participant
  STARTING_CASH = 100
  attr_accessor :money, :bet
  def initialize(name)
    @money = STARTING_CASH
    @bet = 0
    super
  end

  def change_name
    puts "What's your name?"
    name = ''
    loop do
      name = gets.chomp
      break unless name.strip.empty?
      puts "Please enter your name."
    end
    @name = name
  end

  def place_bet
    puts "How much would you like to wager?"
    bet = ''
    puts "You have: #{money}"
    loop do
      bet = gets.chomp
      break if (1..money).cover?(bet.to_i) && bet.to_i.to_s == bet
      puts "That's not a valid amount."
    end
    self.bet = bet.to_i
  end
end

class Dealer < Participant
  STAY_LIMIT = 17
  def display_dealer_hand
    "|?| #{hand[1]}".center(20)
  end
end

class Deck
  SUITS = ["\u2665", "\u2660", "\u2663", "\u2666"]
  FACES = ['2', '3', '4', '5', '6', '7', '8', '9', '10',
           'Jack', 'Queen', 'King', 'Ace']

  attr_accessor :cards

  def initialize
    @cards = []
    FACES.each do |face|
      SUITS.each do |suit|
        cards.push Card.new(suit, face)
      end
    end
    add_values
    cards.shuffle!
  end

  def add_values
    cards.each do |card|
      case card.face
      when 'Ace' then card.value = 11
      when 'Jack', 'Queen', 'King' then card.value = 10
      else
        card.value = card.face.to_i
      end
    end
  end
end

class Card
  attr_accessor :suit, :face, :value
  def initialize(suit, face)
    @suit = suit
    @face = face
  end

  def to_s
    "#{face}#{suit}"
  end
end

class Game
  private
  attr_accessor :player, :dealer, :deck

  def initialize
    @deck = Deck.new
    @player = Player.new('')
    @dealer = Dealer.new('dealer')
  end

  def clear
    system('cls') || system('clear')
  end

  def display_greeting
    puts "Welcome to twenty one!"
    puts ""
    puts " => Twenty one is a game much like Black Jack.
    Each player is dealt two cards and can choose to hit or stay.
    The dealer is dealt one face down card and must stay if thier
    hand totals 17 or more. Face cards are worth ten and aces can be ten or one.
    Try to hit 21 without going over."
    puts ""
  end

  def new_hands
    dealer.hand = []
    player.hand = []
  end

  def deal_to(hand)
    hand << @deck.cards.shift
  end

  def deal_cards
    2.times { deal_to player.hand }
    2.times { deal_to dealer.hand }
  end

  def heading(player)
    puts "#{player}'s hand".center(20, '-')
  end

  def display_cards(opt=1)
    heading(player)
    puts player.display_hand
    puts ""
    heading(dealer)
    puts dealer.display_dealer_hand if opt == 1
    puts dealer.display_hand if opt != 1
    puts ""
  end

  def input_validation(array)
    loop do
      answer = gets.chomp.downcase
      return answer if array.include? answer
      puts "Not a valid answer. (#{array.join('/')})?"
    end
  end

  def player_turn
    loop do
      clear
      display_cards
      puts 'Hit or stay? (h/s)'
      break if input_validation(%w(h s)) == 's'
      deal_to player.hand
      break if player.busted?
    end
  end

  def dealer_turn
    while dealer.total < Dealer::STAY_LIMIT
      deal_to dealer.hand
    end
  end

  def display_values
    player.value_of_hand
    dealer.value_of_hand
  end

  def winning_hand
    winner = player.total <=> dealer.total
    return :plyr_win if winner > 0
    return :dlr_win if winner < 0
    :tie
  end

  def result
    return :plyr_bust if player.busted?
    return :dlr_bust if dealer.busted?
    winning_hand
  end

  def show_result
    clear
    display_cards('final')
    display_values
    case result
    when :plyr_win then puts "#{player} wins!"
    when :tie then puts "It's a tie."
    when :dlr_win then puts "Dealer wins."
    when :plyr_bust then puts "#{player} busted! #{dealer} wins"
    when :dlr_bust then puts "#{dealer} busted! #{player} wins"
    end
  end

  def keep_score
    case result
    when :plyr_bust, :dlr_win then player.money -= player.bet
    when :plyr_win, :dlr_bust then player.money += player.bet
    end
  end

  def display_goodbye
    puts "You are all out of money!" if player.money == 0
    puts "Thanks for playing!"
  end

  def game_over?
    return true if player.money == 0
    puts "Would you like to play again? (y/n)"
    input_validation(%w(y n)) == 'y' ? false : true
  end

  def set_up
    display_greeting
    player.change_name
    clear
  end

  def play_round
    player.place_bet
    deal_cards
    player_turn
    dealer_turn unless player.busted?
    keep_score
  end

  public

  def start
    clear
    set_up

    loop do
      play_round
      show_result
      break if game_over?
      new_hands
    end

    display_goodbye
  end
end

Game.new.start
