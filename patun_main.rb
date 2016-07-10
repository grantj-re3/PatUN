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
$: << File.expand_path(".", File.dirname(__FILE__))

require "patun"
require "patun_view"
require "patun_controller"
require "patun_event"

##############################################################################
# Main
##############################################################################
patience_game_model = PatUn.new
view = PatUnView.new(patience_game_model)
event = PatUnEvent.new

controller = PatUnController.new(patience_game_model, view, event)
controller.event_loop

