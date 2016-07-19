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
require "card"

##############################################################################
class CardPack
  TOTAL_CARDS = 52

  attr_accessor :cards, :icards

  ############################################################################
  def initialize(will_populate=true)
    # Future constructor parameters: num_packs=1, num_jokers_per_pack=0.
    @icards = []
    @cards = []
    if will_populate
      make_icards
      shuffle_icards
      icards_to_cards
    end
  end

  ############################################################################
  # Return a shallow copy of cards. Ie. The CardPack object is new, but the
  # references are to the same 52 Card objects.
  def clone_contents
    pack = self.class.new(false)
    pack.icards = @icards.clone
    pack.cards = @cards.clone
    pack
  end

  ############################################################################
  def make_icards
    @icards = []
    (1 .. TOTAL_CARDS).each{|i| @icards << i-1}
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
  # Encode the pack of icards into a Bignum.
  def encode_from_icards
    bits_per_icard = 6			# 6 bits to store int 0..51
    code = @icards.reverse.inject(0){|accum,icard| (accum << bits_per_icard) + icard}
    code = (code << 8) + @icards.length	# 8 bits for number of icards
    code
  end

  ############################################################################
  # Decode from a Bignum to a pack of icards.
  def decode_to_icards(code)
    num_cards = code & 0b1111_1111
    code = code >> 8

    icards = []
    bits_per_icard = 6			# 6 bits to store int 0..51
    mask = ("1" * bits_per_icard).to_i(2)
    num_cards.times{
      icards << (code & mask)
      code = code >> bits_per_icard
    }
    icards
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

