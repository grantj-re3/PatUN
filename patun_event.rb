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
class PatUnEvent
  S_UP     = "6"	# Numeric keypad: right arrow
  S_DOWN   = "4"	# Numeric keypad: left arrow
  S_SELECT = "."	# Convenient numeric keypad key
  S_QUIT   = "q"

  ############################################################################
  # Contructor
  def initialize
    # Place holder for initialising events
  end

  ############################################################################
  def get
    while true
      printf "\nEnter command (%s=Next, %s=Prev, %s=Select, %s=Quit): ", S_UP, S_DOWN, S_SELECT, S_QUIT
      command = STDIN.readline.strip.downcase

      case command
      when S_QUIT
        return {:event => :event_quit}
      when S_UP
        return {:event => :event_up}
      when S_DOWN
        return {:event => :event_down}
      when S_SELECT
        return {:event => :event_select}
      end

    end
  end

end
