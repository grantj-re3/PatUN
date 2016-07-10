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

  attr_accessor :cards

  ############################################################################
  def initialize
    @icards = []
    @cards = []
    make_icards
    shuffle_icards
    icards_to_cards
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
  def to_s
    @cards.inject([]){|a,c| a << c.to_s; a}.inspect
  end

  ############################################################################
  def to_s_icard
    @cards.inject([]){|a,c| a << c.icard; a}.inspect
  end

end

