fu! s:setup()
ruby << RUBY
$nyao_colors = Cycler.new(
  Ev.globpath(Var["&rtp"], "colors/*.vim").split("\n").map {|p| p.split('/').last.split('.').first },
  ->(color) {
    Ex.colorscheme color
    Ex.redraw!
    SimpleNotify.puts color
  },
  ->() { SimpleNotify.clear }
)

Ex.command "ColorCycle ruby $nyao_colors.cycle"

RUBY
endfu

call s:setup()
