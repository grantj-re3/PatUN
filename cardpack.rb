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

  # Constants for encoding/decoding pack (ie. icards)
  BITS_PER_CARD_COUNT = 8			# Store count of 52-54,104-106,etc
  CARD_COUNT_MASK = ("1" * BITS_PER_CARD_COUNT).to_i(2)	# Corresponding bit-mask
  BITS_PER_ICARD = 6				# Store int 0..51
  ICARD_MASK = ("1" * BITS_PER_ICARD).to_i(2)	# Corresponding bit-mask
  STRING_ENCODE_BITS_PER_DIGIT = 5		# Implies 2**STRING_ENCODE_BITS_PER_DIGIT digits
  STRING_ENCODE_RADIX = 2 ** STRING_ENCODE_BITS_PER_DIGIT	# digits=0,1,2,...a,b,c,...

  attr_accessor :cards, :icards

  ############################################################################
  def initialize(s_game_id=nil, will_populate=true)
    # Future constructor parameters: num_packs=1, num_jokers_per_pack=0.
    @icards = []
    @cards = []
    if will_populate
      if s_game_id
        game_id_to_icards(s_game_id)
        icards_to_cards
      else
        make_icards
        shuffle_icards
        icards_to_cards
      end
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
    code = @icards.reverse.inject(0){|accum,icard| (accum << BITS_PER_ICARD) + icard}
    code = (code << BITS_PER_CARD_COUNT) + @icards.length
    code
  end

  ############################################################################
  # Decode from a Bignum to a pack of icards.
  def self.cm_decode_to_icards(code)
    num_cards = code & CARD_COUNT_MASK
    code = code >> BITS_PER_CARD_COUNT

    icards = []
    num_cards.times{
      icards << (code & ICARD_MASK)
      code = code >> BITS_PER_ICARD
    }
    icards
  end

  ############################################################################
  # String version of encoded icards is the Game ID. Use a large radix
  # so the string will be shorter.
  def icards_to_game_id
    enc_num_bits = @icards.length * BITS_PER_ICARD + BITS_PER_CARD_COUNT
    enc_num_str_digits = (enc_num_bits / STRING_ENCODE_BITS_PER_DIGIT.to_f).ceil
    fmt = "%#{enc_num_str_digits}s"

    # tr below pads leading (string) "digits" with zero
    sprintf(fmt, encode_from_icards.to_s(STRING_ENCODE_RADIX)).tr(' ', '0')
  end

  ############################################################################
  # Convert the string Game ID into the icards array. Return icards or
  # return nil if the Game ID is invalid.
  def self.cm_game_id_to_icards(s_game_id)
    code = s_game_id.to_i(STRING_ENCODE_RADIX)
    icards = cm_decode_to_icards(code)
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

