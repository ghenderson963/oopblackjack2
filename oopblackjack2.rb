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
   self.deck_of_cards.pop
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
  attr_accessor :name, :hand

  def initialize
    self.name = name
    self.hand = Hand.new
    @wallet = Wallet.new
  end

def make_bet(bet)
  @wallet.current_bet = bet
  @wallet.total_cash = @wallet.total_cash - bet
end

def total_cash
  @wallet.total_cash
end


  def to_s
    name
  end
end

class Dealer < Player
  attr_accessor :total_deck

  def  get_deck_count
    begin
      system "clear"
      puts "Hi, I'm the dealer"
      puts "How many decks do you want to play with?"
      @deck_count = gets.chomp.to_i
    end while @deck_count == 0
  end

  def build_decks
    puts "Building #{@deck_count} decks."
    count = 1
    self.total_deck = Deck.new
    while count <= @deck_count
      full_deck1 = Deck.new
      self.total_deck = mix_decks(full_deck1)
      count = count + 1
    end
    total_deck.count
  end

  def scramble
    self.total_deck.shuffle!
    self.total_deck.reverse!
    self.total_deck.shuffle!
  end

  def deal
   self.total_deck.pop
  end

  private

  def mix_decks(deck_to_be_added)
    deck_to_be_added.deck_of_cards.each do |card|
      puts card
      self.total_deck.add_card(card)
    end
  end
end


class Wallet
attr_accessor :total_cash, :current_bet

def initialize
self.total_cash = 2500
self.current_bet = 0
end






  end

class Bank

  def initialize
    @bank_money = 10000000
  end

def take_bets


end

def payout_winners


end

def take_money_losers


end


end

class Game
  def initialize
    # @deck = Deck.new
    @hash_of_players = {}
    @current_player = " "
    @dealer = Dealer.new
    @count = 0
  end

def play
  begin
    @dealer.get_deck_count
    @dealer.build_decks
    @dealer.scramble
    get_player_name
    system "clear"
    puts "Blackjack is the game!"
    @dealer.scramble

    2.times do
      @hash_of_players.each do |k,player|
        player.hand.add_card(@dealer.deal)
      end
    end

    # list_hands
    puts "#{@hash_of_players[0]} is first "
    @player = @hash_of_players[0]

    while @count < @hash_of_players.length
      place_bet
      list_hands
      hit_or_stay
      switch_players
    end
    puts "dealers turn"
    2.times do
      @dealer.hand.add_card(@dealer.deal)
    end
    @dealer.hand.to_s
    puts " "
    dealer_turn
    @hash_of_players.each do |_,player|
      if player.hand.total_card_value > 21
        list_hands
        puts "#{player} Busted! #{player} loses"
      elsif @dealer.hand.total_card_value > 21
        list_hands
        puts "#{player} you win!  The dealer busted!"
      elsif player.hand.total_card_value > @dealer.hand.total_card_value
        list_hands
        puts "#{player} you win!"
      elsif player.hand.total_card_value < @dealer.hand.total_card_value
        list_hands
        puts "#{player} you lose!"
      elsif player.hand.total_card_value == @dealer.hand.total_card_value
        list_hands
        puts "#{player} you and the dealer tied!  No winner!"
      end
    end
    puts "Would you like to player again? (Y)es or (N)o"
    play_again = gets.chomp
  end while play_again == 'y'
end

def switch_players
  @count = @count + 1
  @player = @hash_of_players[@count]
end

  def hit_or_stay
    while @player.hand.total_card_value < 21
      puts "Would you like a HIT or would you like to STAY #{@player}?"
      puts "Use the keyboard to type (H) for HIT or (S) to stay"
      answer = gets.chomp.downcase
      # system "clear"
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
        list_hands
        remove_player
        puts " "
        break
      elsif @player.hand.total_card_value > 21
        puts "Busted! #{@player} looses!"
        list_hands
        puts " "
        remove_player
        break
      end
      system "clear"
      list_hands
    end
  end
end

def list_hands
  count = @hash_of_players.length
  num = 0
  count.times do
    puts "#{@hash_of_players[num].name} has:"
    @hash_of_players[num].hand.to_s
    puts " "
    num += 1
  end
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

def place_bet
  bet_amount = 0
  begin
    puts "You have #{@player.total_cash}"
    puts "How much would you like to bet #{@player}?"
    bet_amount = gets.chomp.to_i
    binding.pry
  end while bet_amount > @player.total_cash
   @player.make_bet(bet_amount)
end

  def dealer_turn
    if @dealer.hand.total_card_value == 21
      puts "Dealer has Blackjack!"
      exit
    end
    while @dealer.hand.total_card_value < 17
      puts "The dealer hits!"
      puts " "
      @dealer.hand.add_card(@dealer.deal)
      @dealer.hand.to_s
      if @dealer.hand.total_card_value == 21
        puts "Dealer has Blackjack!  You lose."
        puts " "
        break
      elsif  @dealer.hand.total_card_value > 21
       puts "Dealer has busted! You win."
       puts " "
       break
      end
      puts "The dealer stays. "
     end
    end

new_game = Game.new.play
