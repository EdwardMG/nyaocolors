fu! s:setup()
ruby << RUBY
class NyaoColors
  attr_accessor :colors
  def initialize
    @colors = Ev.globpath(Var["&rtp"], "colors/*.vim").split("\n").map {|p| p.split('/').last.split('.').first }
    @i = 0
    @end = @colors.length-1
  end

  def set
    Ex.colorscheme @colors[@i]
    SimpleNotify.puts @colors[@i]
  end

  def n
    @i += 1
    @i = 0 if @i > @end
    set
    Ex.redraw!
  end

  def p
    @i -= 1
    @i = @end if @i < 0
    set
    Ex.redraw!
  end

  def cycle
    loop do
      c = Ev.getcharstr
      case c
      when 'j'
        n
      when 'k'
        p
      else
        SimpleNotify.clear
        break
      end
    end
  end
end

Ex.command "ColorCycle ruby NyaoColors.new.cycle"

RUBY
endfu

call s:setup()
