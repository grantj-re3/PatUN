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
require 'io/console'

class PatUnEvent
  WITHOUT_ENTER_KEY = true	# Most commands do not require user to press ENTER

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

  MAIN_MENU_CHOICES = [
    [:Prev,	S_DOWN],
    [:Next,	S_UP],
    [:Select,	S_SELECT],
    [:Undo,	S_UNDO],
    [:Other,	S_MORE],
    [:NewGame,	S_NEW_GAME],
    [:Quit,	S_QUIT],
  ]

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
      command = get_char

      case command
      when S_GAME_ID
        printf "Enter or paste the Game ID: "
        s_game_id = STDIN.readline.strip
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
  def get(omits=[])
    # Exclude menu options specified in the omits-list
    choices = MAIN_MENU_CHOICES.inject([]){|a,(desc,ch)| a << "#{ch}=#{desc}" unless omits.include?(desc); a}
    while true
      printf "Enter command (%s): ", choices.join(", ")
      command = get_char

      # Do not respond to commands in the omits-list
      choice_pair = MAIN_MENU_CHOICES.rassoc(command)
      next if choice_pair && omits.include?(choice_pair[0])

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
        msg = "Are you sure you want to start a new game? [y/n] "
        is_confirmed(msg) ? (return {:event => :event_new_game}) : next

      when S_QUIT
        msg = "Are you sure you want to quit? [y/n] "
        is_confirmed(msg) ? (return {:event => :event_quit}) : next
      end

    end
  end

  ############################################################################
  # Prompts with a confirmation message. Returns true if confirmed, else returns false.
  def is_confirmed(msg, s_true="y", s_false="n")
    printf "%s", msg
    get_char == s_true
  end

  ############################################################################
  # We want a single character from STDIN (but string length *might* not be 1)
  def get_char
    if WITHOUT_ENTER_KEY
      ch = STDIN.getch
      puts ch
      exit if ch.ord == 3		# Ctl-C to quit

    else
      ch = STDIN.readline
    end
    ch.strip.downcase
  end

end
