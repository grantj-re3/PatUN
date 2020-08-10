# How to play PatUN - the patience card game

## Glossary

- **Stock:** The pile of unused cards with the topmost card face up.
- **Tableau:** Initially a 5x5 grid of cards. All cards are face up.
- **Rank:** The value of the card: A, 2, 3, 4, 5, 6, 7, 8, 9, T, J, Q, K.
- **Build:** A pile of 1-4 cards **of the same rank** located on the
  tableau grid.
- **Mobile "card":** A build which can be moved and joined with one of the
  neighbouring builds (according to the rules below).
- **Filler "card":** A build from the bottom row of the grid or from the
  left-most column of the grid which will fill the space created by
  the moving a mobile card/build.

Similar glossaries:
- https://semicolon.com/Solitaire/Rules/Glossary.html
- https://en.wikipedia.org/wiki/Glossary_of_patience_terms


## Initial steps

- Cards are shuffled.
- Cards are dealt to the tableau into a 5x5 grid.

At this point, each element of the grid is a build, and each build
contains one card. Some of the builds will have the same rank as
other builds.

The objective of the game is to join all builds of the same rank
while following the rules below.


## Rules

`BEGIN-SEQUENCE`

If any mobile cards (or builds) are present, you must:

1. Move a card (or build) to the left or below to join a neighbouring card
   (or build) of the **same rank**. "Left" and "below" includes "diagonally
   left" and "diagonally below" (in other words, top-left, left, bottom-left,
   bottom and bottom-right).
2. The space created by moving the card/build must be filled by one of the
   filler cards/builds. A filler card/build is either:
   * the most distant card/build in the row to the left of the space, or
   * the most distant card/build in the column below the space
3. The topmost card of the stock is placed in the space created by moving
   the filler card/build.

If no mobile cards/builds are present, you must:

- Deal a new column of cards (from the stock) to the left of tableau
  (starting at the top of the grid). The first time you do this you
  will have a 5 row by 6 column grid (assuming you had 5 cards or
  more remaining in the stock to fill a whole column).

`END-SEQUENCE`

Repeat the steps between BEGIN-SEQUENCE and END-SEQUENCE until the game ends.


## The end of the game

The game ends when:

- The stock is exhausted, **and**
- There are no remaining mobile cards/builds


## Objective

The objective of the game is to have 13 builds when the game ends. In
other words:

- a build of 4 aces, and
- a build of 4 twos, and
...
- a build of 4 queens, and
- a build of 4 kings.


## Hints

When planning your sequence of 3 steps given above, you should consider:

- What would be a good location (on the bottom row or left-most column)
  for the topmost (next) card of the stock, and
- What would be a good mobile card to move to achieve this, and
- Is it possible to maintain or increase the number of mobile cards
  while doing this


## Sample moves

