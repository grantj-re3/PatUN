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
class PatUnController

  ############################################################################
  # Contructor for controller
  def initialize(game, view, event)
    @game = game			# The model object
    @view = view
    @event = event
  end

  ############################################################################
  def event_loop
    while true
      # Get event (eg. user input, mouse click)
      e = @event.get
      if @game.status == :choose_mobile
        case e[:event]

        when :event_quit
          break

        when :event_up
          @game.mobile_next
          @view.show_with_marked_cells(@game, :mobile)

        when :event_down
          @game.mobile_previous
          @view.show_with_marked_cells(@game, :mobile)

        when :event_select
          @game.mobile_join_cells
          @view.show_with_marked_cells(@game, :mobile)

          @game.find_filler_cells
          @view.show_with_marked_cells(@game, :filler)
        end

      else	# :choose_filler
        case e[:event]

        when :event_quit
          break

        when :event_up
          @game.filler_next
          @view.show_with_marked_cells(@game, :filler)

        when :event_down
          @game.filler_previous
          @view.show_with_marked_cells(@game, :filler)

        when :event_select
          @game.fill_empty_mobile_cell
          @game.fill_empty_filler_cell
          @game.find_mobile_cells
          @view.show_with_marked_cells(@game, :mobile)
        end

      end	# if

    end		# while
  end

end

