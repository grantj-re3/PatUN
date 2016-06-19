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
require "cardpack"

##############################################################################
class PatUn

  attr_reader :stock, :tableau, :status,
    :mobile, :mobile_index, :filler, :filler_index

  ############################################################################
  def initialize
    @stock = CardPack.new
    @tableau = {}
    initial_tableau

    @mobile = []
    @mobile_index = nil
    find_mobile_cells
    @status = :choose_mobile

    @filler = []
    @filler_index = nil
  end

  ############################################################################
  # Cards in a tableau cell are potentially mobile if their value is
  # identical to neighbouring tableau cell card values to the left or
  # below. The relative immediate neighbours of interest are: top-left,
  # left, bottom-left, bottom, bottom-right.
  def find_mobile_cells
    @mobile = []
    0.upto(4).each{|row|
      10.downto(0){|col|
        rowcol = [row,col]
        next unless @tableau[rowcol]	# Empty position
        next if @mobile.include?(rowcol)	# Have already stored this position
        @mobile << rowcol if find_matching_neighbour(rowcol)
      }
    }
    @mobile_index = @mobile.empty? ? nil : 0		# Index of current mobile-cell
  end

  ############################################################################
  def find_matching_neighbour(rowcol)
    return nil unless @tableau[rowcol]
    row,col = rowcol

    # Check neighbouring cards to the left
    icol = col + 1
    (row-1).upto(row+1){|irow|
      irowicol = [irow,icol]
      next unless @tableau[irowicol]
      return irowicol if @tableau[rowcol].first.value == @tableau[irowicol].first.value
    }


    # Check neighbouring cards to below
    irow = row + 1
    col.downto(col-1){|icol|
      irowicol = [irow,icol]
      next unless @tableau[irowicol]
      return irowicol if @tableau[rowcol].first.value == @tableau[irowicol].first.value
    }
    return nil
  end

  ############################################################################
  def find_filler_cells
    rowcol = @mobile[@mobile_index]
    row,col = rowcol
    @filler = []

    # Find filler cell to the far-left
    irow = row
    valid_col = nil			# No valid column found yet
    (col+1).upto(10){|icol|		# Potentially 11 columns (0..10)
      if @tableau[ [irow,icol] ]
        valid_col = icol		# Valid column found (but there might be more)
      else
        break
      end
    }
    @filler << [irow,valid_col] if valid_col

    # Find filler cell to the far-bottom
    icol = col
    valid_row = nil			# No valid row found yet
    (row+1).upto(4){|irow|		# Potentially 5 rows (0..4)
      if @tableau[ [irow,icol] ]
        valid_row = irow		# Valid row found (but there might be more)
      else
        break
      end
    }
    @filler << [valid_row,icol] if valid_row

    @filler_index = @filler.empty? ? nil : 0		# Index of current filler-cell
  end

  ############################################################################
  # Initial tableau is 5x5; max tableau will fit in 5x11 (row,col).
  # Tableau has (row,col) coordinates:
  #   [0,4] [0,3] [0,2] [0,1] [0,0]
  #   :     :     :     :     [1,0]
  #   :     :     :     :     [2,0]
  #   :     :     :     :     [3,0]
  #   [4,4] [4,3] [4,2] [4,1] [4,0]
  def initial_tableau
    @tableau = {}	# 1D-hash; Index = [row,column] (a 2-valued array)
    (0..4).each{|col|
      (0..4).each{|row|
        @tableau[ [row,col] ] = [@stock.cards.pop]
      }
    }
  end

  ############################################################################
  def mobile_next
    @mobile_index = (@mobile_index + 1) % @mobile.length if @mobile_index
  end

  ############################################################################
  def mobile_previous
    @mobile_index = (@mobile_index - 1) % @mobile.length if @mobile_index
  end

  ############################################################################
  def filler_next
    @filler_index = (@filler_index + 1) % @filler.length if @filler_index
  end

  ############################################################################
  def filler_previous
    @filler_index = (@filler_index - 1) % @filler.length if @filler_index
  end

  ############################################################################
  def mobile_join_cells
    rowcol = @mobile[@mobile_index]		# Source cell (the selected mobile cell)
    irowicol = find_matching_neighbour(rowcol)	# Dest cell (any of the matching neighbours)

    # Move all cards in selected cell (rowcol) into matching cell (irowicol)
    @tableau[rowcol].each{|c| @tableau[irowicol] << c}
    @tableau[rowcol] = nil			# Cell now empty

    @status = :choose_filler
  end

  ############################################################################
  def fill_empty_mobile_cell
    rowcol = @filler[@filler_index]		# Source cell (the selected filler cell)
    irowicol = @mobile[@mobile_index]		# Dest cell (the tableau gap; the selected mobile cell)

    # Move all cards in selected cell (rowcol) into empty cell (irowicol)
    @tableau[irowicol] = @tableau[rowcol].inject([]){|a,c| a << c; a}
    @tableau[rowcol] = nil			# Cell now empty

    @status = :choose_stock
  end

  ############################################################################
  def fill_empty_filler_cell
    irowicol = @filler[@filler_index]		# Dest cell (the selected filler cell)

    # Move card from top of the stock into empty cell (irowicol)
    @tableau[irowicol] = [@stock.cards.pop]

    @status = :choose_mobile
  end

end

