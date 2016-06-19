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
    # @tableau is a 1-dimensional hash containing our grid of cells.
    # The @tableau key is an array of the form [row,column].
    # The @tableau value is an array of 0-4 cards inclusive. All
    # cards in a given cell have the same value (eg. all are "J").
    @tableau = {}
    populate_tableau

    @mobile = []
    @mobile_index = nil
    find_mobile_cells
    @status = :choose_mobile

    @filler = []
    @filler_index = nil
  end

  ############################################################################
  # Initial tableau is 5x5; max tableau will fit in 5x11 (row,col).
  # Tableau has (row,col) coordinates:
  #   [0,4] [0,3] [0,2] [0,1] [0,0]
  #   :     :     :     :     [1,0]
  #   :     :     :     :     [2,0]
  #   :     :     :     :     [3,0]
  #   [4,4] [4,3] [4,2] [4,1] [4,0]
  def populate_tableau
    @tableau = {}
    (0..4).each{|col|
      (0..4).each{|row|
        @tableau[ [row,col] ] = [@stock.cards.pop]
      }
    }
  end

  ############################################################################
  # Cards in a tableau cell are potentially mobile if their value is
  # identical to neighbouring tableau cell card values to the left or
  # below. The relative immediate neighbours of interest are: top-left,
  # left, bottom-left, bottom, bottom-right.
  def find_mobile_cells
    @mobile = []
    # Iterate thru tableau in a manner which results in nicely ordered
    # coords in @mobile. Hence stepping from one mobile card to the
    # next in the UI is nice/expected for the player.
    0.upto(4).each{|row|
      10.downto(0){|col|
        rowcol = [row,col]
        next unless @tableau[rowcol]		# Empty position
        next if @mobile.include?(rowcol)	# Have already stored this position
        @mobile << rowcol if find_matching_neighbour(rowcol)
      }
    }
    @mobile_index = @mobile.empty? ? nil : 0		# Index of current mobile-cell
  end

  ############################################################################
  # Return the row & col [irow,icol] of any neighbouring cell where the
  # value of the cards in that cell match (equal) the value of the cards
  # in the cell defined by the argument rowcol [row,col]. If there is
  # more than one matching cell, we will return the first one we find.
  # If there are no matching cells, we will return nil.
  def find_matching_neighbour(rowcol)
    return nil unless @tableau[rowcol]
    row,col = rowcol

    # Check neighbouring cells to the left of rowcol
    icol = col + 1
    (row-1).upto(row+1){|irow|
      irowicol = [irow,icol]
      next unless @tableau[irowicol]
      return irowicol if @tableau[rowcol].first.value == @tableau[irowicol].first.value
    }

    # Check neighbouring cells below rowcol
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
    @filler = []			# Will contain coords of 0,1 or 2 cells

    # Find filler cell to the far-left of the target row
    irow = row
    valid_col = nil			# No valid column found yet
    (col+1).upto(10){|icol|		# Potentially 11 columns (0..10)
      if @tableau[ [irow,icol] ]
        valid_col = icol		# Valid column found (but there might be more)
      else
        break				# There are no more populated cells in this row
      end
    }
    @filler << [irow,valid_col] if valid_col

    # Find filler cell to the far-bottom of the target row
    icol = col
    valid_row = nil			# No valid row found yet
    (row+1).upto(4){|irow|		# Potentially 5 rows (0..4)
      if @tableau[ [irow,icol] ]
        valid_row = irow		# Valid row found (but there might be more)
      else
        break				# There are no more populated cells in this column
      end
    }
    @filler << [valid_row,icol] if valid_row

    @filler_index = @filler.empty? ? nil : 0		# Index of current filler-cell
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
    @tableau[rowcol].each{|card| @tableau[irowicol] << card}
    @tableau[rowcol] = nil			# Cell now empty

    @status = :choose_filler
  end

  ############################################################################
  def fill_empty_mobile_cell
    rowcol = @filler[@filler_index]		# Source cell (the selected filler cell)
    irowicol = @mobile[@mobile_index]		# Dest cell (the tableau gap; the selected mobile cell)

    # Move all cards in selected cell (rowcol) into empty cell (irowicol)
    @tableau[irowicol] = @tableau[rowcol].inject([]){|a,card| a << card; a}
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

