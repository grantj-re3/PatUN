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
  # Main-menu keyboard inputs
  S_DOWN	= "4"	# Numeric keypad: left arrow
  S_UP		= "6"	# Numeric keypad: right arrow
  S_SELECT	= "."	# Convenient numeric keypad key
  S_UNDO	= "u"
  S_MORE	= "o"
  S_NEW_GAME	= "n"
  S_QUIT	= "q"

  # More-menu keyboard inputs
  S_GAME_ID	= "g"
  S_RULES	= "r"
  S_CONTINUE	= "c"

  ############################################################################
  # Contructor
  def initialize
    # Place holder for initialising events
  end

  ############################################################################
  # Get events from More-menu
  def get_more
    while true
      printf "Enter command (%s=Game ID, %s=Show Rules, %s=Continue): ", S_GAME_ID, S_RULES, S_CONTINUE
      command = STDIN.readline.strip.downcase

      case command
      when S_GAME_ID
        printf "Enter or paste the Game ID: "
        s_game_id = STDIN.readline.strip.downcase
        return {:event => :event_game_id, :data => s_game_id}

      when S_RULES
        return {:event => :event_show_rules}

      when S_CONTINUE
        return nil
      end

    end
  end

  ############################################################################
  # Get events from Main-menu
  def get
    while true
      printf "Enter command (%s=Prev, %s=Next, %s=Select, %s=Undo, %s=Other, %s=NewGame, %s=Quit): ",
        S_DOWN, S_UP, S_SELECT, S_UNDO, S_MORE, S_NEW_GAME, S_QUIT
      command = STDIN.readline.strip.downcase

      case command
      when S_UP
        return {:event => :event_up}
      when S_DOWN
        return {:event => :event_down}
      when S_SELECT
        return {:event => :event_select}
      when S_UNDO
        return {:event => :event_undo}
      when S_MORE
        event = get_more
        return event if event
      when S_NEW_GAME
        return {:event => :event_new_game}
      when S_QUIT
        return {:event => :event_quit}
      end

    end
  end

  ############################################################################
  # Get events (similar to Main-menu) but when no moves are possible
  # (eg. once the game has been won or lost). This permits S_UNDO even
  # if the player has already lost (in case the player can improve the
  # situation). Hence do not permit events S_DOWN, S_UP & S_SELECT.
  def get_no_move
    while true
      printf "Enter command (%s=Undo, %s=Other, %s=NewGame, %s=Quit): ",
        S_UNDO, S_MORE, S_NEW_GAME, S_QUIT
      command = STDIN.readline.strip.downcase

      case command
      when S_UNDO
        return {:event => :event_undo}
      when S_MORE
        event = get_more
        return event if event
      when S_NEW_GAME
        return {:event => :event_new_game}
      when S_QUIT
        return {:event => :event_quit}
      end

    end
  end

end
