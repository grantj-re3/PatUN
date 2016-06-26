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
class PatUnView

  ############################################################################
  def show_with_marked_cells(game, marked_type=nil)
    puts "Status: #{game.status}"
    puts "Number of filler cells: #{game.filler.length}" if game.status == :choose_filler

    case marked_type
    when :filler
      list = game.filler
      list_index = game.filler_index
    when :mobile
      puts to_s_mobile(game)

      list = game.mobile
      list_index = game.mobile_index
    else	# eg. nil; assume no marked cells
      list = []
      list_index = nil
    end

    puts to_s_stock(game)
    puts
    puts to_s_stock_summary(game)

    (0..4).each{|row|
      a = []
      (0..11).each{|col|
        rowcol = [row,col]
        cell = game.tableau[rowcol]
        s = []
        if cell
          # Cell format: "mvvvv" where
          #   m = "*" if current filler cell; "+" if non-current filler cell; " " otherwise
          #   v = A,2,3...T,J,Q,K or " "
          # Eg. "+JJJ "
          m = " "
          if list.include?(rowcol)
            m = rowcol == list[list_index] ? "*" : "+"
          end
          s = cell.inject([]){|a,c| a << c.chvalue; a}
          (4 - cell.length).times{s << " " * 1}
        end
        a << (cell ? m + s.join : " " * 5)
      }
      puts "  #{a.reverse.join(' ')}"	# Move cell for column 0 to right side
    }

    if game.status == :end_of_game_win
      puts "The game is over. Congratulations, you WIN! (#{game.tableau.length})"
    elsif game.status == :end_of_game_lose
      puts "The game is over. Bad luck, you did not win. (#{game.tableau.length})"
    end
  end

  ############################################################################
  def to_s_stock_summary(game)
    ch = game.stock.cards.length == 0 ? "" : game.stock.cards.last.chvalue
    "Stock remaining: #{game.stock.cards.length}   NEXT CARD: #{ch}"
  end

  ############################################################################
  def to_s_stock(game)
    "Stock:  #{game.stock.cards.inject([]){|a,c| a << c.to_s; a}.join(",")}"
  end

  ############################################################################
  def to_s_mobile(game)
    mlist = game.mobile.inject([]){|a,(row,col)| a << "[#{row},#{col}]"; a}.join(",")
    "Mobile cards (#{game.mobile.length}):  #{mlist}"
  end

end

