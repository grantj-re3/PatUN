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
require "etc"
require "card"
require "cardpack"

##############################################################################
class PatUn
  WILL_STORE_MOVES = true
  SERIAL_OBJECT = Marshal		# Object-serialisation: YAML or Marshal
  DIR = File.expand_path(".", File.dirname(__FILE__))
  BASENAME = "save_history_PatUn"
  FPATH_SCORES = "#{DIR}/scores.txt"

  attr_accessor :status

  attr_reader :stock, :tableau, :cycle_count, :model_history,
    :mobile, :mobile_index, :filler, :filler_index

  ############################################################################
  def initialize(s_game_id=nil)
    @stock = CardPack.new(s_game_id)
    # @tableau is a 1-dimensional hash containing our grid of cells.
    # The @tableau key is an array of the form [row,column]. Eg. @tableau[ [0,4] ]
    # The @tableau value is an array of 0-4 cards inclusive. All
    # cards in a given cell have the same value (eg. all are "J").
    @tableau = {}
    @max_tableau_column_index = nil
    populate_tableau_from_stock

    @mobile = []		# List of mobile cells within the tableau
    @mobile_index = nil

    @filler = []		# List of filler cells within the tableau
    @filler_index = nil

    @model_history = []		# List of cycle-history
    @cycle_count = 0
    @status = :start_cycle
  end

  ############################################################################
  def start_cycle
    @cycle_count += 1

=begin
    if @cycle_count == 1
      # Initialise game near end-game for debugging
      dir = File.expand_path(".", File.dirname(__FILE__))
      fname = "#{DIR}/save2.25.Marshal"
      fname = "#{DIR}/save2.27.Marshal"
      fname = "#{DIR}/save3.11.Marshal"
      fname = "#{DIR}/save3.21.Marshal"
      fname = "#{DIR}/save3.34.Marshal"
      fname = "#{DIR}/save4.38.Marshal"
      @stock, @tableau, @cycle_count = self.class.load_object(fname)
    end
=end

    save_object = {
      :stock		=> @stock.clone_contents,
      :tableau		=> tableau_clone_contents,
      :cycle_count	=> @cycle_count
    }
    @model_history << save_object
    self.class.save_object(save_object, @cycle_count) if WILL_STORE_MOVES
  end

  ############################################################################
  # Return a shallow copy of cards. Ie. The hash object is new, but the
  # references are to the same 52 Card objects.
  def tableau_clone_contents
    @tableau.inject({}){|h,(rowcol,cell)| h[rowcol] = cell.clone if cell; h}
  end

  ############################################################################
  def undo_cycle
    if @status != :choose_mobile && @model_history.length >= 1
      # Jump back to the begining of *this* cycle
      obj = @model_history.last
      @stock, @tableau, @cycle_count = [ obj[:stock], obj[:tableau], obj[:cycle_count] ]

      @model_history.pop	# Remove last cycle as it will be resaved in start_cycle()
      @status = :start_cycle

    elsif @status == :choose_mobile && @model_history.length >= 2
      # Jump back to the begining of the *previous* cycle
      @model_history.pop
      obj = @model_history.last
      @stock, @tableau, @cycle_count = [ obj[:stock], obj[:tableau], obj[:cycle_count] ]

      @model_history.pop	# Remove last cycle as it will be resaved in start_cycle()
      @status = :start_cycle
    end
  end

  ############################################################################
  def check_game_status
    find_mobile_cells
    if @mobile.empty?
      # Either end of game or deal out more cards
      if @stock.cards.empty?
        if @tableau.length == 13
          @status = :end_of_game_win
        else
          @status = :end_of_game_lose
        end

      else
        add_tableau_column_from_stock
        @status = :check_game_status
      end

    else
      @status = :choose_mobile
    end
  end

  ############################################################################
  # Initial tableau is 5x5; max tableau will fit in 5x11 (row,col).
  # Tableau has (row,col) coordinates:
  #   [0,4] [0,3] [0,2] [0,1] [0,0]
  #   :     :     :     :     [1,0]
  #   :     :     :     :     [2,0]
  #   :     :     :     :     [3,0]
  #   [4,4] [4,3] [4,2] [4,1] [4,0]
  def populate_tableau_from_stock
    @tableau = {}
    (0..4).each{|col|
      (0..4).each{|row|
        @tableau[ [row,col] ] = [@stock.cards.pop]
      }
    }
    @max_tableau_column_index = 4
  end

  ############################################################################
  def add_tableau_column_from_stock
    @max_tableau_column_index += 1
    col = @max_tableau_column_index
    (0..4).each{|row|
      @tableau[ [row,col] ] = [@stock.cards.pop] unless @stock.cards.empty?
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
  def find_filler_cells(rowcol=nil)
    rowcol ||= @mobile[@mobile_index]
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

    # Find filler cell to the far-bottom of the target column
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
  def next_card_in_list(which_list)
    which_list == :mobile ? mobile_next : filler_next
  end

  ############################################################################
  def previous_card_in_list(which_list)
    which_list == :mobile ? mobile_previous : filler_previous
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
    @tableau.delete(rowcol)			# Cell now empty

    @status = :choose_filler
  end

  ############################################################################
  def fill_empty_mobile_cell
    rowcol = @filler[@filler_index]		# Source cell (the selected filler cell)
    irowicol = @mobile[@mobile_index]		# Dest cell (the tableau gap; the selected mobile cell)

    # Move all cards in selected cell (rowcol) into empty cell (irowicol)
    @tableau[irowicol] = @tableau.delete(rowcol)

    @status = :choose_stock
  end

  ############################################################################
  def fill_empty_filler_cell
    irowicol = @filler[@filler_index]		# Dest cell (the selected filler cell)

    unless @stock.cards.empty?
      # Move card from top of the stock into empty cell (irowicol)
      @tableau[irowicol] = [@stock.cards.pop]

    else					# Back-fill from the tableau
      find_filler_cells(irowicol)		# @filler should have length 0 or 1
      unless @filler.empty?
        @tableau[irowicol] = @tableau.delete(@filler.first)	# Back fill with this cell
      end
    end

    @status = :start_cycle
  end

  ############################################################################
  # Only call this method at the completion of a game
  def save_completed_game_summary
    rec = [
      @tableau.length,				# Number of cells
      @stock.icards_to_game_id,			# Game ID
      Time.now.strftime("%F %T %z"),		# Datestamp  (FIXME: Use UTC?)
      Etc.getlogin,				# Username
    ].join(", ")
    File.open(FPATH_SCORES, "a"){|f| f.puts rec}  # File append. Not thread-safe
  end

  ############################################################################
  def self.save_object(object, cycle)
    fpath = sprintf("%s/%s.%02d.%s", DIR, BASENAME, cycle, SERIAL_OBJECT)
    s = SERIAL_OBJECT.dump(object)
    File.write(fpath, s)
  end

  ############################################################################
  def self.load_object(fname)
    s = File.read(fname)
    return SERIAL_OBJECT.load(s)
  end

end

