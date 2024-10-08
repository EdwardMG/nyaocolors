fu! s:setup()
ruby << RUBY
$nyao_colors = Cycler.new(
  Ev.globpath(Var["&rtp"], "colors/*.vim").split("\n").map {|p| p.split('/').last.split('.').first },
  ->(color) {
    Ex.colorscheme color
    SimpleNotify.puts color
    Ex.redraw!
  },
  -> (_) { SimpleNotify.clear }
)

Ex.command "ColorCycle ruby $nyao_colors.cycle"

class NyaoColorBG
  def self.start
    c = Cycler.new(
      (0..255).to_a,
      ->(bg) {
        cmd = "hi Normal ctermbg=#{bg} | hi nonText ctermbg=#{bg}"
        Ex[cmd]
        SimpleNotify.puts cmd.sq
        Ex.redraw!
        cmd
      },
      ->(cmd) {
        p = "/Users/edwardgallant/.vim/pack/eg/opt/nyaocolors/plugin/nyao-colors-out.vim"
        File.write(p, cmd+"\n", mode:'a')
        SimpleNotify.clear
      },
      {
        'n' => ->(cycler) {
          cycler.i += 10
          cycler.i = 0 if cycler.i > cycler.end
          cycler.out = cycler.action[cycler.els[cycler.i]]
        },
        'h' => ->(cycler) {
          cycler.i -= 10
          cycler.i = cycler.end if cycler.i < 0
          cycler.out = cycler.action[cycler.els[cycler.i]]
        }
      }
    )
    c.cycle
  end
end

class NyaoColor
  HighlightInfo = Struct.new(:name, :cterm, :ctermfg, :ctermbg)
  def highlight_info groupname
    Ex.silent 'redir => g:nyao_color'
    Ex.silent "hi #{groupname}"
    Ex.silent 'redir END'
    r = Var['g:nyao_color'].split(' ')
    HighlightInfo.new(
      r[0],
      r.select {|x| x.start_with? 'cterm=' }[0]&.split('=')&.last,
      r.select {|x| x.start_with? 'ctermfg=' }[0]&.split('=')&.last,
      r.select {|x| x.start_with? 'ctermbg=' }[0]&.split('=')&.last,
    )
  end

  def reinit hl_group
    @hl_group          = hl_group
    hi                 = highlight_info @hl_group
    @cterm_state       = hi.cterm || "NONE"
    @fg                = hi.ctermfg || "NONE"
    @bg                = hi.ctermbg || "NONE"
    @change_background = false
  end

  def initialize
    id                 = Ev.synstack(Ev.line('.'), Ev.col('.')).last
    @hl_group          = Ev.synIDattr(id, "name")
    hi                 = highlight_info @hl_group
    @cterm_state       = hi.cterm || "NONE"
    @fg                = hi.ctermfg
    @bg                = hi.ctermbg
    @change_background = false
  end

  def cterm(state)
    if state
      "cterm=#{state}"
    else
      "cterm=NONE"
    end
  end

  def ctermbg(color)
    if color
      "ctermbg=#{color}"
    else
      "ctermbg=NONE"
    end
  end

  def syntax_under_cursor
    c = Cycler.new(
      (0..255).to_a,
      ->(color) {
        if @change_background
          @bg = color
        else
          @fg = color
        end
        cmd = "hi #{@hl_group} ctermfg=#{@fg} #{ctermbg @bg} #{cterm @cterm_state}".strip
        Ex[cmd]
        SimpleNotify.puts cmd.sq
        Ex.redraw!
        cmd
      },
      ->(cmd) {
        p = "/Users/edwardgallant/.vim/pack/eg/opt/nyaocolors/plugin/nyao-colors-out.vim"
        File.write(p, cmd+"\n", mode:'a')
        SimpleNotify.clear
      },
      {
        'n' => ->(cycler) {
          cycler.i += 10
          cycler.i = 0 if cycler.i > cycler.end
          cycler.out = cycler.action[cycler.els[cycler.i]]
        },
        'h' => ->(cycler) {
          cycler.i -= 10
          cycler.i = cycler.end if cycler.i < 0
          cycler.out = cycler.action[cycler.els[cycler.i]]
        },
        'b' => ->(cycler) {
          @cterm_state = @cterm_state == 'bold' ? 'NONE' : 'bold'
          cycler.out = cycler.action[@fg]
        },
        'g' => ->(cycler) {
          @change_background = !@change_background
          cycler.out = cycler.action[@fg]
        },
        'i' => ->(cycler) {
          @cterm_state = @cterm_state == 'italic' ? 'NONE' : 'italic'
          cycler.out = cycler.action[@fg]
        },
        'u' => ->(cycler) {
          @cterm_state = @cterm_state == 'underline' ? 'NONE' : 'underline'
          cycler.out = cycler.action[@fg]
        },
        'd' => ->(cycler) {
          color = Ev.input('number: ')
          cycler.i = cycler.els.find {|e| e == color.to_i }
          cycler.out = cycler.action[color]
        },
        '1' => ->(cycler) {
          reinit "Normal"
          @change_background = true
          cycler.i = cycler.els.find {|e| e == @bg.to_i }
          cycler.out = cycler.action[@bg]
        },
        '2' => ->(cycler) {
          reinit "EndOfBuffer"
          @change_background = true
          cycler.i = cycler.els.find {|e| e == @bg.to_i }
          cycler.out = cycler.action[@bg]
        },
        '3' => ->(cycler) {
          reinit "TabLineFill"
          @change_background = true
          cycler.i = cycler.els.find {|e| e == @bg.to_i }
          cycler.out = cycler.action[@bg]
        },
        '4' => ->(cycler) {
          reinit "TabLineSel"
          @change_background = true
          cycler.i = cycler.els.find {|e| e == @bg.to_i }
          cycler.out = cycler.action[@bg]
        },
        '5' => ->(cycler) {
          reinit "TabLine"
          @change_background = true
          cycler.i = cycler.els.find {|e| e == @bg.to_i }
          cycler.out = cycler.action[@bg]
        },
        '6' => ->(cycler) {
          reinit "VertSplit"
          @change_background = true
          cycler.i = cycler.els.find {|e| e == @bg.to_i }
          cycler.out = cycler.action[@bg]
        },
        '7' => ->(cycler) {
          reinit "CursorLine"
          @change_background = true
          cycler.i = cycler.els.find {|e| e == @bg.to_i }
          cycler.out = cycler.action[@bg]
        },
        '8' => ->(cycler) {
          reinit "CursorLineNr"
          @change_background = false
          cycler.i = cycler.els.find {|e| e == @fg.to_i }
          cycler.out = cycler.action[@bg]
        },
        '9' => ->(cycler) {
          reinit "Visual"
          Ex.normal! 'Vj'
          @change_background = true
          cycler.i = cycler.els.find {|e| e == @bg.to_i }
          cycler.out = cycler.action[@bg]
        },
      }
    )
    c.i = @fg.to_i
    c.cycle
  end
end
RUBY
endfu

call s:setup()

nno \\c :ColorCycle<CR>
nno \c :ruby NyaoColor.new.syntax_under_cursor<CR>
nno \b :ruby NyaoColorBG.start<CR>

" set notermguicolors
" set t_Co=256
" set background=dark
" highlight Normal ctermbg=NONE
" highlight nonText ctermbg=NONE
" highlight Normal ctermbg=blue
