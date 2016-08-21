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
  COUNTER_KEYS = (0..4).map{|i| sym = i.to_s.to_sym}	# Keys: :0, :1,... :4

  ############################################################################
  def initialize(game)
    @game = game			# The model object
    @tableau_counts = {}
  end

  ############################################################################
  def show_with_marked_cells(marked_type=nil)
    puts "\nGame ID: #{@game.stock.icards_to_game_id}"
    calculate_tableau_counts
    #puts "Card values: #{@tableau_counts[:cards][:by_value]}"
    #puts "Cell values: #{@tableau_counts[:cells][:by_value]}"
    #puts
    #puts "Card counts: #{@tableau_counts[:cards][:by_count]}"
    puts "Cell counts: #{@tableau_counts[:cells][:by_count]}"

    summary_strs = []
    case marked_type
    when :filler
      summary_strs << to_s_filler_summary

      list = @game.filler
      list_index = @game.filler_index
    when :mobile
      summary_strs << to_s_mobile_summary

      list = @game.mobile
      list_index = @game.mobile_index
    else	# eg. nil; assume no marked cells
      list = []
      list_index = nil
    end

    #puts to_s_stock
    summary_strs << to_s_stock_summary
    summary_strs << to_s_next_card
    puts summary_strs.join(";  ")

    (0..4).each{|row|
      a = []
      (0..10).each{|col|
        rowcol = [row,col]
        cell = @game.tableau[rowcol]
        s = []
        if cell
          # Cell format: "mvvvvm" where
          #   m = "<" or ">" if current filler cell; "(" or ")" if non-current filler cell; " " otherwise
          #   v = A,2,3...T,J,Q,K or " "
          # Eg. "(JJJ )"
          m1 = " "
          m2 = " "
          if list.include?(rowcol)
            m1 = rowcol == list[list_index] ? "<" : "("
            m2 = rowcol == list[list_index] ? ">" : ")"
          end
          s = cell.inject([]){|a,c| a << c.chvalue; a}
          s << " " * (4 - cell.length)
        end
        a << (cell ? m1 + s.join + m2 : " " * 6)
      }
      puts "  #{a.reverse.join(' ')}"	# Move cell for column 0 to right side
    }

    case @game.status
    when :end_of_game_win
      puts "The game is over. Congratulations, you WIN! (#{@game.tableau.length})"
    when :end_of_game_lose
      puts "The game is over. Bad luck, you did not win. (#{@game.tableau.length})"
    when :choose_mobile
      puts "Choose mobile card."
    when :choose_filler
      puts "Choose a card to fill the gap (from left column or bottom row)."
    end
  end

  ############################################################################
  def to_s_next_card
    cards = @game.stock.cards
    sprintf "NEXT CARD: %s", cards.length == 0 ? "" : cards.last.chvalue
  end

  ############################################################################
  def to_s_stock_summary
    sprintf "Stock remaining: %2d", @game.stock.cards.length
  end

  ############################################################################
  def to_s_stock
    "Stock:  #{@game.stock.cards.inject([]){|a,c| a << c.to_s; a}.join(",")}"
  end

  ############################################################################
  def to_s_filler_summary
    sprintf "Number of filler cards: %2d", @game.filler.length
  end

  ############################################################################
  def to_s_mobile_summary
    sprintf "Number of mobile cards: %2d", @game.mobile.length
  end

  ############################################################################
  def to_s_mobile
    mlist = @game.mobile.inject([]){|a,(row,col)| a << "[#{row},#{col}]"; a}.join(",")
    "Mobile cards (#{@game.mobile.length}):  #{mlist}"
  end

  ############################################################################
  def calculate_tableau_counts
    tc = {}
    tc[:cards] = Hash.new(0); tc[:cells] = Hash.new(0)

    # Collect tableau counts
    (0..4).each{|row|
      (0..10).each{|col|
        cell = @game.tableau[ [row,col] ]
        next unless cell
        tc[:cells][ cell.first.value ] += 1
        tc[:cards][ cell.first.value ] += cell.length
      }
    }

    # Build a summary line for each set of counts
    by_value = {}; by_count = {}; s_count = {}
    [:cards, :cells].each{|cc|
      by_value[cc] = []; by_count[cc] = {}; s_count[cc] = []
      COUNTER_KEYS.each{|key| by_count[cc][key] = []}

      Card::VALUE_SYMS.each{|v|
        by_count[cc][ tc[cc][v].to_s.to_sym ] << v
        by_value[cc] << "#{v}:#{tc[cc][v]}"
      }
      COUNTER_KEYS.each{|key| s_count[cc] << "#{key}:[#{by_count[cc][key].join(',')}]" }
      tc[cc][:by_count] = s_count[cc].join("  ")
      tc[cc][:by_value] = by_value[cc].join("  ")
    }
    @tableau_counts = tc
  end

end

