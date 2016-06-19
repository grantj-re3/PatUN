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
class Card
  SUIT_SYMS  = %w{c d h s}.map{|ch| ch.to_sym}	# :c=club, :d=diamond, :h=heart, :s=spade
  VALUE_SYMS = %w{A 2 3 4 5 6 7 8 9 T J Q K}.map{|ch| ch.to_sym}

  attr_accessor :value, :suit

  ############################################################################
  # format1 = {
  #   :type  => :type_value_suit,
  #   :value => :A,			# :A,:2,...:T,:J,:Q,:K
  #   :suit  => :c,			# :c, :d, :h, :s
  # }
  # format2 = {
  #   :type  => :type_int,
  #   :int => 0,			# 0..51
  # }
  #
  def initialize(card_hash)
    case card_hash[:type]

    when :type_value_suit
      @value = card_hash[:value]
      @suit  = card_hash[:suit]

    when :type_int
      @value = VALUE_SYMS[card_hash[:int] % 13]
      @suit = SUIT_SYMS[card_hash[:int] / 13]

    else
      @value = nil
      @suit  = nil

    end
    # FIXME: Do range checks
  end

  ############################################################################
  # Return 0..51
  def icard
    isuit = SUIT_SYMS.index(@suit)
    ivalue = VALUE_SYMS.index(@value)
    isuit * 13 + ivalue
  end

  ############################################################################
  def chvalue
    @value.to_s
  end

  ############################################################################
  def chsuit
    @suit.to_s
  end

  ############################################################################
  def to_s
    "#{@value}#{@suit}"
  end

end

