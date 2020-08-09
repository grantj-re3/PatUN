#
# Author:	Grant Jackson
# Package:	N/A
# Environment:	Ruby 2.0.0
#
# Copyright (C) 2016
# Licensed under GPLv3. GNU GENERAL PUBLIC LICENSE, Version 3, 29 June 2007
# http://www.gnu.org/licenses/
#
##############################################################################
require "base64"
require "card"

##############################################################################
class CardPack
  TOTAL_CARDS = 52

  # Encode icard int using Base64 encoding.
  # - Shift int to fit into most significant 6 bits
  # - Only extract first char (corresponding to most significant 6 bits)
  ICARD_ENCODE = (0..TOTAL_CARDS-1).to_a.inject({}){|h,i| h[i] = Base64.encode64((i << 2).chr)[0,1]; h}
  ICARD_DECODE = ICARD_ENCODE.invert

  attr_accessor :cards, :icards

  ############################################################################
  def initialize(s_game_id=nil, will_populate=true)
    # Future constructor parameters: num_packs=1, num_jokers_per_pack=0.
    @icards = []
    @cards = []
    if will_populate
      if s_game_id
        game_id_to_icards(s_game_id)
      else
        make_icards
        shuffle_icards
      end
      icards_to_cards
    end
  end

  ############################################################################
  # Return a shallow copy of cards. Ie. The CardPack object is new, but the
  # references are to the same 52 Card objects.
  def clone_contents
    pack = self.class.new(nil, false)
    pack.icards = @icards.clone
    pack.cards = @cards.clone
    pack
  end

  ############################################################################
  def make_icards
    @icards = []
    0.upto(TOTAL_CARDS-1).each{|i| @icards << i}
  end

  ############################################################################
  def shuffle_icards
    index = 0
    icards_shuffled = []

    TOTAL_CARDS.downto(1){|num_unshuffled|
      count = rand(1 .. num_unshuffled)
      index = (index + count) % num_unshuffled
      icards_shuffled << @icards.delete_at(index)
    }
    @icards = icards_shuffled
  end

  ############################################################################
  def icards_to_cards
    @cards = @icards.inject([]){|a,i| a << Card.new_from_int(i); a}
  end

  ############################################################################
  # String version of encoded icards is the Game ID.
  def icards_to_game_id
    @icards.map{|i| ICARD_ENCODE[i]}.join
  end

  ############################################################################
  # Convert the string Game ID into the icards array. Return icards or
  # return nil if the Game ID is invalid.
  def self.cm_game_id_to_icards(s_game_id)
    icards = s_game_id.split("").map{|ch| ICARD_DECODE[ch]}
    return nil unless icards.length == TOTAL_CARDS
    0.upto(TOTAL_CARDS-1){|i| return nil unless icards.include?(i)}
    icards
  end

  ############################################################################
  def game_id_to_icards(s_game_id)
    @icards = self.class.cm_game_id_to_icards(s_game_id)
    raise("Invalid Game ID: #{s_game_id}") unless @icards
    @icards
  end

  ############################################################################
  def to_s
    @cards.inject([]){|a,c| a << c.to_s; a}.inspect
  end

  ############################################################################
  def to_s_icard
    @cards.inject([]){|a,c| a << c.icard; a}.inspect
  end

end

