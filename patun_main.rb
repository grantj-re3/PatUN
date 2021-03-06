#!/usr/bin/ruby
# patun_main.rb
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
# Add dirs to the library path
$: << File.expand_path("lib", File.dirname(__FILE__))

require "cardpack"
require "patun"
require "patun_view"
require "patun_controller"
require "patun_event"

##############################################################################
class GameSelector

  ############################################################################
  def self.main
    # FIXME: Read command line args (eg. Game ID, UI type)
    will_play_game = true
    s_game_id = nil

    while will_play_game
      puts "\nPatUN Patience Card Game - new game\n" + "=" * 35
      if s_game_id && !CardPack.cm_game_id_to_icards(s_game_id)
        puts "Invalid Game ID: \"#{s_game_id}\""
        exit 1
      end
      # Setup the the MVC components
      patience_game_model = PatUn.new(s_game_id)
      view = PatUnView.new(patience_game_model)
      event = PatUnEvent.new

      controller = PatUnController.new(patience_game_model, view, event)
      actions = controller.event_loop	# Run the MVC (ie. play this game ID)

      if actions[:new_game]
        will_play_game = true
        s_game_id = nil

      elsif actions[:game_id]
        will_play_game = true
        s_game_id = actions[:game_id]

      else	# actions[:quit_without_asking]
        will_play_game = false
      end
    end
  end
end

##############################################################################
# Main
##############################################################################
GameSelector.main

