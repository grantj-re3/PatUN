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

  END_OF_GAME_STATUS = [:end_of_game_win, :end_of_game_lose]

  ############################################################################
  # Contructor for controller
  def initialize(game, view, event)
    @game = game			# The model object
    @view = view
    @event = event
  end

  ############################################################################
  def event_loop
    while !END_OF_GAME_STATUS.include?(@game.status)
      if @game.status == :start_cycle
        @game.start_cycle
        @game.check_game_status
        @view.show_with_marked_cells(:mobile) unless @game.status == :check_game_status

      elsif @game.status == :check_game_status
        @game.check_game_status
        @view.show_with_marked_cells(:mobile) unless @game.status == :check_game_status

      else	# :choose_mobile & :choose_filler
        e = @event.get
        case e[:event]

        when :event_quit
          return {:quit_without_asking => true}

        when :event_new_game
          return {:new_game => true}

        when :event_undo
          @game.undo_cycle

        when :event_game_id
          s_game_id = e[:data]
          if CardPack.cm_game_id_to_icards(s_game_id)
            return {:quit_without_asking => false, :game_id => s_game_id}
          else
            puts "Invalid Game ID: \"#{s_game_id}\""
          end

        when :event_up
          which_list = @game.status.to_s.sub(/^choose_/, "").to_sym
          @game.next_card_in_list(which_list)
          @view.show_with_marked_cells(which_list)

        when :event_down
          which_list = @game.status.to_s.sub(/^choose_/, "").to_sym
          @game.previous_card_in_list(which_list)
          @view.show_with_marked_cells(which_list)

        when :event_select
          if @game.status == :choose_mobile
            @game.mobile_join_cells

            @game.find_filler_cells
            if @game.filler.empty?
              @game.status = :start_cycle
            else
              @view.show_with_marked_cells(:filler)
            end
          else
            @game.fill_empty_mobile_cell
            @game.fill_empty_filler_cell
          end
        end

      end	# if

    end		# while
    @game.save_completed_game_summary if END_OF_GAME_STATUS.include?(@game.status)
    {:quit_without_asking => false}
  end

end

