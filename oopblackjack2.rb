require "pry"

class Deck
  attr_accessor :deck_of_cards

  def initialize
    @deck_of_cards = []
    ["spades", "diamonds", "clubs", "hearts"].each do |suit|
      ['2','3','4','5','6','7','8','9','jack','queen','king','ace'].each do |rank|
        @deck_of_cards << Card.new(suit,rank)
      end
    end
  end

   def scramble!
     deck_of_cards.shuffle!
     deck_of_cards.reverse!
     deck_of_cards.shuffle!
  end

  def deal
   deck_of_cards.pop
  end

  def add_card(card_to_add)
    deck_of_cards << card_to_add
  end

  def to_s
    i = 0
    deck_of_cards.each do |card|
      i = i + 1
      puts "Card number #{i} is a #{card.rank} of #{card.suit} "
    end
  end

end


module Hand

  def add_card(card)
    self.cards.push(card)
  end

  def total_card_value
    total = 0
    cards.each do |card|
      total += card.value(card.rank).to_i
    end
   cards.select { |card| card.value(card.rank) == 11 }.count.times do
      if total > 21
        total -= 10
      end
    end
    total
  end

  def list_hand
    hand_total = 0
    cards.each do |card|
      puts "#{card.rank} of #{card.suit}"
    end
    hand_total += total_card_value
    puts "==>For a total of #{hand_total}"
  end

  def show_flop
    puts "First card hidden."
    puts "#{cards[1].rank} of #{cards[1].suit}"
  end

  def remove_cards
    @cards = []
  end

end

class Card
  attr_accessor :rank, :suit, :value

  def initialize(suit, rank)
    @suit = suit
    @rank = rank
    @value = value(rank)
  end

  def value(rank)
    if rank == "ace"
      @value = 11
    elsif rank.to_i == 0
      @value = 10
    else
      @value = rank
    end
  end

  def to_s
    puts "a #{@rank} of #{@suit}"
  end

end

class Player
  include Hand

  attr_accessor :name, :wallet, :cards

  def initialize
    @name = name
    @cards = []
    @wallet = Wallet.new
  end

  def make_bet(bet)
    wallet.current_bet = bet
  end

  def total_cash
    wallet.total_cash
  end

  def settle_bet(win)
    if win == "win"
      wallet.total_cash = wallet.total_cash + wallet.current_bet
    else
      wallet.total_cash = wallet.total_cash - wallet.current_bet
    end
  end

  def to_s
    name
  end

end

class Dealer < Player
  include Hand

  attr_accessor :total_deck

  def build_decks
    puts "Building and shuffling decks."
    @total_deck = Deck.new
  end

  def deal
   @total_deck.deck_of_cards.pop
  end

end

class Wallet
  attr_accessor :total_cash, :current_bet

  def initialize
    @total_cash = 2500
    @current_bet = 0
  end

  def to_s
    puts "You have #{total_cash} dollars"
    puts "Your current bet is #{current_bet} dollars"
  end

end

class Game
  attr_accessor :dealer, :hash_of_players, :count, :player


  def initialize
    @hash_of_players = {}
    @dealer = Dealer.new
    @count = 0
  end

  def switch_players
    if count < hash_of_players.length
      self.count = count + 1
      self.player = hash_of_players[count]
    end
  end

  def players_turn
    system "clear"
    puts "#{@hash_of_players[0]} is first."
    @player = hash_of_players[0]
    hash_of_players.each do |_,player|
      system "clear"
      show_cards
      hit_or_stay
      system "clear"
      show_cards
      puts "Hit Enter or Return to proceed"
      choice = gets.chomp
      switch_players
    end
  end

  def play
    system "clear"
    get_player_name

    begin
      system "clear"
      dealer.build_decks
      dealer.total_deck.scramble!
      puts " "
      puts "Let's play Blackjack!"
      puts " "
      place_bets
      clean_up_card
      initial_deal
      players_turn
      system "clear"
      dealers_turn
      find_winners
      puts "Would you like to player again? (Y)es or (N)o"
      play_again = gets.chomp
    end while play_again == 'y'
  end

  def place_bets
    hash_of_players.each do  |_,player|
      bet_amount = 0
      begin
        system "clear"
        puts "You have #{player.total_cash}"
        puts "How much would you like to bet #{player}?"
        puts " "
        bet_amount = gets.chomp.to_i
     end while bet_amount > player.total_cash
     player.make_bet(bet_amount)
    end
  end

  def clean_up_card
    hash_of_players.each { |_,player| player.remove_cards }
    dealer.remove_cards
  end

  def initial_deal
    2.times do
      hash_of_players.each { |_,player| player.add_card(dealer.deal) }
      dealer.add_card(dealer.deal)
    end
  end

  def hit_or_stay
    while @player.total_card_value < 21
      puts "Would you like a HIT or would you like to STAY #{player}?"
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
      player.add_card(dealer.deal)
      if player.total_card_value == 21
        puts "Blackjack! #{player} wins!"
        sleep(3)
        show_cards
        player.settle_bet("win")
        puts " "
        break
      elsif player.total_card_value > 21
        puts "Busted! #{player} looses!"
        show_cards
        puts " "
        player.settle_bet(FALSE)
        break
      end
      system "clear"
      show_cards
    end
  end

  def show_cards
    puts "#{@player} has:"
    @player.list_hand
    @player.wallet.to_s
    puts " "
    puts "The dealer has:"
    dealer.show_flop
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
      hash_of_players[num] = Player.new
      hash_of_players[num].name = "#{players_name}"
    end
  end

  def remove_player
    hash_of_players.delete_if{ |key, value| key == "#{@player}"}
  end

  def dealers_turn
    system "clear"
    puts "Dealers turn!"
    puts "Dealer has:"
    dealer.list_hand
    puts " "
    if dealer.total_card_value == 21
      puts "Dealer has Blackjack!"
      puts " "
    end
    while dealer.total_card_value < 17
      puts "The dealer hits!"
      dealer.add_card(dealer.deal)
      sleep(1)
      puts "The dealer gets:"
      dealer.cards.last.to_s
      puts "For a total of #{dealer.total_card_value}"
      puts " "
      sleep(2)
    end
  end

  def find_winners
    hash_of_players.each do |_,player|
      if player.total_card_value > 21
        player.settle_bet(FALSE)
        puts "#{player} Busted! #{player} loses"
      elsif dealer.total_card_value > 21
        player.settle_bet("win")
        puts "#{player} you win!  The dealer busted!"
      elsif player.total_card_value > dealer.total_card_value
        player.settle_bet("win")
        puts "#{player} you win!"
      elsif player.total_card_value < dealer.total_card_value
        player.settle_bet(FALSE)
        puts "#{player} you lose!"
      elsif player.total_card_value == dealer.total_card_value
        player.settle_bet("win")
        puts "#{player} you and the dealer tied!  No winner!"
      end
    end
  end

end

new_game = Game.new
new_game.play
