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
      if @game.status == :start_cycle
        @game.start_cycle
        @game.check_game_status
        @view.show_with_marked_cells(@game, :mobile) unless @game.status == :check_game_status

      elsif @game.status == :check_game_status
        @game.check_game_status
        @view.show_with_marked_cells(@game, :mobile) unless @game.status == :check_game_status

      elsif [:end_of_game_win, :end_of_game_lose].include?(@game.status)
        @view.show_with_marked_cells(@game, :mobile)
        exit 0

      elsif @game.status == :choose_mobile
        e = @event.get
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
          if @game.filler.empty?
            @game.status = :start_cycle
          else
            @view.show_with_marked_cells(@game, :filler)
          end
        end

      else	# :choose_filler
        e = @event.get
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
        end

      end	# if

    end		# while
  end

end

