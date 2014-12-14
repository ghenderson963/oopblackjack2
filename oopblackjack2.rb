require "pry"

class Deck
  attr_accessor :count, :deck_of_cards

  def initialize
    @deck_of_cards = []
    suit = ["spades", "diamonds", "clubs", "hearts"]
    rank = ['2','3','4','5','6','7','8','9','jack','queen','king','ace']
    array_of_suit_rank_pairs = []
    array_of_suit_rank_pairs = suit.product(rank)
    count = 0
    array_of_suit_rank_pairs.each do |array|
      @deck_of_cards[count] = Card.new(array[0],array[1])
      count = count + 1
    end
  end


  def scramble
    @deck_of_cards.shuffle!
    @deck_of_cards.reverse!
    @deck_of_cards.shuffle!
  end

  def deal
   @deck_of_cards.pop
  end

  def add_card(card_to_add)
    count = @deck_of_cards.length
    @deck_of_cards[count ] = card_to_add
  end

  def to_s
    count = 0
    @deck_of_cards.each do |card|
      count = count + 1
      puts "Card number #{count} is a #{card.rank} of #{card.suit} "
    end
  end
end

class Hand
  attr_accessor :hand_array

  def initialize
    @hand_array = []
    @number_of_cards = @hand_array.count
  end

  def add_card(card)
    @hand_array.push(card)
  end

  def total_card_value
    total = 0
    @hand_array.each do |card|
      total += card.value(card.rank).to_i
    end
    @hand_array.select { |card| card.value(card.rank) == 11 }.count.times do
      if total > 21
        total -= 10
      end
    end
    total
end

  def to_s
    hand_total = 0
    @hand_array.each do |card|
      puts "#{card.rank} of #{card.suit}"
    end
    hand_total += total_card_value
    puts "for a total of #{hand_total}"
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
  attr_accessor :name, :hand

  def initialize
    @name = name
    @hand = Hand.new
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

    @total_deck = Deck.new
    while count <= @deck_count
      full_deck1 = Deck.new

      @total_deck = mix_decks(full_deck1)
      count = count + 1
    end
    total_deck.count
  end

   def scramble
    @total_deck.shuffle!
    @total_deck.reverse!
    @total_deck.shuffle!
  end


  def deal
   @total_deck.pop
  end

def dealer_turn


end

private

def mix_decks(deck_to_be_added)
  deck_to_be_added.deck_of_cards.each do |card|
    puts card
    @total_deck.add_card(card)
  end
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

  list_hands
  puts "#{@hash_of_players[0]} is first "
  @player = @hash_of_players[0]
  while @count < @hash_of_players.length
    hit_or_stay
    switch_players
  end
  puts "dealers turn"
  2.times do
    @dealer.hand.add_card(@dealer.deal)
  end
  @dealer.hand.to_s
  dealer_turn
  @hash_of_players.each do |_,player|
    if player.hand.total_card_value > 21
      list_hands
      puts "Busted #{player} loses"
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

#     puts "For a total of #{player_total_count}"
#     announce_dealer_cards(dealer_hand)
#     puts "For a total of #{dealer_total_count}"
#     puts "You Busted! Sorry you lose!"
#   elsif dealer_total_count > 21
#     announce_player_cards(player_hand)
#     puts "For a total of #{player_total_count}"
#     announce_dealer_cards(dealer_hand)
#     puts "For a total of #{dealer_total_count}"
#     puts "You win! The dealer busted!"
#   elsif player_total_count > dealer_total_count
#     announce_player_cards(player_hand)
#     puts "For a total of #{player_total_count}"
#     announce_dealer_cards(dealer_hand)
#     puts "For a total of #{dealer_total_count}"
#     puts "You Win!"
#   elsif player_total_count < dealer_total_count
#     announce_player_cards(player_hand)
#     puts "For a total of #{player_total_count}"
#     announce_dealer_cards(dealer_hand)
#     puts "For a total of #{dealer_total_count}"
#     puts "Dealer Wins!"
#   else player_total_count == dealer_total_count
#     announce_player_cards(player_hand)
#     puts "For a total of #{player_total_count}"
#     announce_dealer_cards(dealer_hand)
#     puts "For a total of #{dealer_total_count}"
#     puts "Tie so BORING!"
#   end
#   puts "Would you like to play again?  (Y)es or (N)o"
#   play_again = gets.chomp
# end while play_again == 'y'
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

def choose_who_goes_first
  count_of_players = @hash_of_players.length
  player_number = @hash_of_players.keys.sample
  @player = @hash_of_players[player_number]
end

def remove_player
  @hash_of_players.delete_if{ |key, value| key == "#{@player}"}
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
