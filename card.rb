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
  def initialize(value, suit)
    # FIXME: Do range checks
    @value = value.to_s.upcase.to_sym	# :A, :2, ... :T, :J, :Q, :K
    @suit  = suit.to_s.downcase.to_sym	# :c, :d, :h, :s
  end

  ############################################################################
  def self.new_from_int(icard)
    raise ArgumentError.new('Argument must be in the range 0..51') unless (0..51).include?(icard)

    value = VALUE_SYMS[icard % 13]
    suit = SUIT_SYMS[icard / 13]
    self.new(value, suit)
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

