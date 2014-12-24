require "pry"

class Deck
  attr_accessor :deck_of_cards

  def initialize
    self.deck_of_cards = []
    suit = ["spades", "diamonds", "clubs", "hearts"]
    rank = ['2','3','4','5','6','7','8','9','jack','queen','king','ace']
    array_of_suit_rank_pairs = []
    array_of_suit_rank_pairs = suit.product(rank)
    count = 0
    array_of_suit_rank_pairs.each do |array|
      self.deck_of_cards[count] = Card.new(array[0],array[1])
      count = count + 1
    end
  end

  def scramble
    self.deck_of_cards.shuffle!
    self.deck_of_cards.reverse!
    self.deck_of_cards.shuffle!
  end

  def deal
   self.deck_of_cards.deck_of_cards.pop
  end

  def add_card(card_to_add)
    self.deck_of_cards << card_to_add
  end

  def to_s
    count = 0
    self.deck_of_cards.each do |card|
      count = count + 1
      puts "Card number #{count} is a #{card.rank} of #{card.suit} "
    end
  end
end

class Hand
  attr_accessor :hand_array

  def initialize
    self.hand_array = []
    @number_of_cards = @hand_array.count
  end

  def add_card(card)
    self.hand_array.push(card)
  end

  def total_card_value
    total = 0
    self.hand_array.each do |card|
      total += card.value(card.rank).to_i
    end
    self.hand_array.select { |card| card.value(card.rank) == 11 }.count.times do
      if total > 21
        total -= 10
      end
    end
    total
end

  def to_s
    hand_total = 0
    self.hand_array.each do |card|
      puts "#{card.rank} of #{card.suit}"
    end
    hand_total += total_card_value
    puts "for a total of #{hand_total}"
  end

  def remove_cards
    self.hand_array = []
  end
end

class Card
  attr_accessor :rank, :suit, :value

  def initialize(suit, rank)
  self.suit = suit
  self.rank = rank
  self.value = value(rank)
  end

  def value(rank)
    if rank == "ace"
      self.value = 11
    elsif rank.to_i == 0
      self.value = 10
    else
      self.value = rank
    end
  end

  def to_s
    puts "a #{self.rank} of #{self.suit}"
  end
end

class Player
  attr_accessor :name, :hand, :bet, :wallet, :current_bet

  def initialize
    self.name = name
    self.hand = Hand.new
    self.wallet = Wallet.new
    self.bet = 0
    self.current_bet = 0
  end

  def make_bet(bet)
    self.wallet.current_bet = bet
  end

  def total_cash
    self.wallet.total_cash
  end

  def settle_bet(win)
    if win == "win"
      self.wallet.total_cash = self.wallet.total_cash + self.wallet.current_bet
    else
      self.wallet.total_cash = self.wallet.total_cash - self.wallet.current_bet
    end
  end

  def to_s
    name
  end
end

class Dealer < Player
  attr_accessor :total_deck

  def build_decks
    puts "Building and shuffling decks."
    count = 1
    self.total_deck = Deck.new
  end

  def scramble
    self.total_deck.shuffle!
    self.total_deck.reverse!
    self.total_deck.shuffle!
  end

  def deal
   self.total_deck.deck_of_cards.pop
  end
end


class Wallet
  attr_accessor :total_cash, :current_bet

  def initialize
    self.total_cash = 2500
    self.current_bet = 0
  end

  def to_s
    puts "You have #{total_cash} dollars"
    puts "Your current bet is #{current_bet} dollars"
  end
end

class Game
  def initialize
    @hash_of_players = {}
    @dealer = Dealer.new
    @count = 0
  end

def play
  system "clear"
  get_player_name

  begin
    system "clear"
    @count = 0
    @dealer.build_decks
    @dealer.total_deck.scramble
    puts " "
    puts "Let's play Blackjack!"
    puts " "
    @hash_of_players.each { |_,player| place_bet(player)}
    @hash_of_players.each { |_,player| player.hand.remove_cards }
    @dealer.hand.remove_cards
    2.times do
      @hash_of_players.each { |_,player| player.hand.add_card(@dealer.deal) }
      @dealer.hand.add_card(@dealer.deal)
    end
    system "clear"
    puts "#{@hash_of_players[0]} is first."
    @player = @hash_of_players[0]
    @hash_of_players.each do |_,player|
      system "clear"
      show_cards
      hit_or_stay
      system "clear"
      show_cards
      puts "Hit Enter or Return to proceed"
      choice = gets.chomp
      switch_players
    end
    system "clear"
    puts "Dealers turn!"
    puts "Dealer has:"
    @dealer.hand.to_s
    puts " "
    if @dealer.hand.total_card_value == 21
      puts "Dealer has Blackjack!"
      puts " "
    end
    while @dealer.hand.total_card_value < 17
      puts "The dealer hits!"
      @dealer.hand.add_card(@dealer.deal)
      sleep(1)
      puts "The dealer gets:"
      @dealer.hand.hand_array.last.to_s
      puts "For a total of #{@dealer.hand.total_card_value}"
      puts " "
      sleep(2)
    end
    @hash_of_players.each do |_,player|
      if player.hand.total_card_value > 21
        player.settle_bet(FALSE)
        puts "#{player} Busted! #{player} loses"
      elsif @dealer.hand.total_card_value > 21
        # list_hands
        player.settle_bet("win")
        puts "#{player} you win!  The dealer busted!"
      elsif player.hand.total_card_value > @dealer.hand.total_card_value
        # list_hands
        player.settle_bet("win")
        puts "#{player} you win!"
      elsif player.hand.total_card_value < @dealer.hand.total_card_value
        # list_hands
        player.settle_bet(FALSE)
        puts "#{player} you lose!"
      elsif player.hand.total_card_value == @dealer.hand.total_card_value
        # list_hands
        player.settle_bet("win")
        puts "#{player} you and the dealer tied!  No winner!"
      end
    end
    puts "Would you like to player again? (Y)es or (N)o"
    play_again = gets.chomp
  end while play_again == 'y'
end

def switch_players
  if @count < @hash_of_players.length
    @count = @count + 1
    @player = @hash_of_players[@count]
  end
end

def hit_or_stay
  while @player.hand.total_card_value < 21
    puts "Would you like a HIT or would you like to STAY #{@player}?"
    puts "Use the keyboard to type (H) for HIT or (S) to stay"
    answer = gets.chomp.downcase
    if !["h", "s"].include?(answer)
      puts "You must enter s or h"
      next
    end
    if answer == "s"
      puts "You choose to stay!"
      puts " "
      break
    end
    @player.hand.add_card(@dealer.deal)
    if @player.hand.total_card_value == 21
      puts "Blackjack! #{@player} wins!"
      sleep(3)
      show_cards
      @player.settle_bet("win")
      puts " "
      break
    elsif @player.hand.total_card_value > 21
      puts "Busted! #{@player} looses!"
      show_cards
      puts " "
      @player.settle_bet(FALSE)
      break
    end
    system "clear"
    show_cards
    end
  end
end

def show_cards
  puts "#{@player} has:"
  @player.hand.to_s
  @player.wallet.to_s
  puts " "
  puts "The dealer has:"
  @dealer.hand.to_s
  puts " "
end

def get_player_name
  begin
    puts "how many players are going to play?  Chose 1-4"
    number_of_players = gets.chomp.to_i
  end while number_of_players == 0 || number_of_players > 4
    number_of_players.times do |num|
      puts "What is player#{num + 1}'s name?"
      players_name = gets.chomp.to_s
      @hash_of_players[num] = Player.new
      @hash_of_players[num].name = "#{players_name}"
    end
end

def remove_player
  @hash_of_players.delete_if{ |key, value| key == "#{@player}"}
end

def place_bet(player)
  bet_amount = 0
  begin
    puts "You have #{player.total_cash}"
    puts "How much would you like to bet #{player}?"
    puts " "
    bet_amount = gets.chomp.to_i
  end while bet_amount > player.total_cash
   player.make_bet(bet_amount)
end

new_game = Game.new.play
