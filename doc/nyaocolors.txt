*nyaocolors*

INTRODUCTION

Cycle through colourschemes easily to help decide on a new favourite.

Tools to create new colourschemes easily and conveniently, leading to higher
quality and more interesting colourschemes.

Requires rubywrapper plugin.

USAGE

<Commands>

:ColorCycle

Start colourcyle util.

<j> next colourscheme
<k> previous colourscheme

Current colourscheme is displayed in a textbox in centre of screen on each movement. Any other key exits the mode.

:ruby NyaoColor.new.syntax_under_cursor

Start modifying the syntax of the highlight group under the cursor.

<j> next element of 256 colourpallete
<k> previous element of 256 colourpallete
<n> same as <j> but jump by 10 elements
<h> same as <k> but jump by 10 elements
<g> toggle between affecting foreground vs background colour
<b> toggle bold
<i> toggle italic
<u> toggle underline
<d> pick a number 0-255 from 256 colourpallete
<o> Go up the highlight group syntax stack to affect a more general highlight group
<p> Opposite of <o>
<0> use fzf (if installed) to select a highlight group to modify
<1> Change highlight group affected to "Normal"
<2> Change highlight group affected to "EndOfBuffer"
<3> Change highlight group affected to "TabLineFill"
<4> Change highlight group affected to "TabLineSel"
<5> Change highlight group affected to "TabLine"
<6> Change highlight group affected to "VertSplit"
<7> Change highlight group affected to "CursorLine"
<8> Change highlight group affected to "CursorLineNr"
<9> Change highlight group affected to "Visual"

Any other key writes to plugin/nyao-colors-out.vim the highlight command
derived from the above commands. Command is shown in a text box while the mode
is active.

vim:autoindent noexpandtab tabstop=8 shiftwidth=8
vim:se modifiable
vim:tw=78:et:ft=help:norl:
