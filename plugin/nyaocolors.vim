fu! s:setup()
ruby << RUBY

$nyao_hl_groups = [
  "ColorColumn",
  "Conceal",
  "Cursor",
  "lCursor",
  "CursorIM",
  "CursorColumn",
  "CursorLine",
  "Directory",
  "DiffAdd",
  "DiffChange",
  "DiffDelete",
  "DiffText",
  "EndOfBuffer",
  "ErrorMsg",
  "VertSplit",
  "Folded",
  "FoldColumn",
  "SignColumn",
  "IncSearch",
  "LineNr",
  "LineNrAbove",
  "LineNrBelow",
  "CursorLineNr",
  "CursorLineFold",
  "CursorLineSign",
  "MatchParen",
  "MessageWindow",
  "ModeMsg",
  "MoreMsg",
  "NonText",
  "Normal",
  "Pmenu",
  "PmenuSel",
  "PmenuKind",
  "PmenuKindSel",
  "PmenuExtra",
  "PmenuExtraSel",
  "PmenuSbar",
  "PmenuThumb",
  "PopupNotificatio",
  "Question",
  "QuickFixLine",
  "Search",
  "CurSearch",
  "SpecialKey",
  "SpellBad",
  "SpellCap",
  "SpellLocal",
  "SpellRare",
  "StatusLine",
  "StatusLineNC",
  "StatusLineTerm",
  "StatusLineTermNC",
  "TabLine",
  "TabLineFill",
  "TabLineSel",
  "Terminal",
  "Title",
  "Visual",
  "VisualNOS",
  "WarningMsg",
  "WildMenu"
]

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
        p = "#{ENV["HOME"]}/.vim/pack/eg/opt/nyaocolors/plugin/nyao-colors-out.vim"
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

  def hl_groups_under_cursor
    Ev.synstack(Ev.line('.'), Ev.col('.')).map do |id|
      Ev.synIDattr(id, "name")
    end
  end

  def initialize
    @hl_groups = hl_groups_under_cursor
    @hl_group_cycler = Cycler.new(
      @hl_groups,
      ->(group_name) {
        reinit group_name
        cmd = "hi #{@hl_group} ctermfg=#{@fg} #{ctermbg @bg} #{cterm @cterm_state}".strip
        Ex[cmd]
        SimpleNotify.puts cmd.sq
        Ex.redraw!
        cmd
      },
    )
    @hl_group_cycler.i = @hl_groups.length - 1
    # id                 = Ev.synstack(Ev.line('.'), Ev.col('.')).last
    # @hl_group          = Ev.synIDattr(id, "name")
    @hl_group          = @hl_groups.last
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
        p = "#{ENV["HOME"]}/.vim/pack/eg/opt/nyaocolors/plugin/nyao-colors-out.vim"
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
        'o' => ->(cycler) {
          @hl_group_cycler.p
        },
        'p' => ->(cycler) {
          @hl_group_cycler.n
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
        '0' => ->(cycler) {
          reinit $nyao_hl_groups.fzf.first
          @change_background = false
          cycler.i = cycler.els.find {|e| e == @fg.to_i }
          cycler.out = cycler.action[@fg]
        },

      }
    )
    c.i = @fg.to_i
    c.cycle
  end
end

doc_path = Ev.expand('<sfile>:h:h') + 'doc/'
Ex['silent! exe "helptags '+doc_path+'"']
RUBY
endfu

call s:setup()

if exists('g:nyao_always_add_mappings') && g:nyao_always_add_mappings
  nno \\c :ColorCycle<CR>
  nno \C :Colors<CR>
  nno \c :ruby NyaoColor.new.syntax_under_cursor<CR>
  nno \b :ruby NyaoColorBG.start<CR>
endif

" set notermguicolors
" set t_Co=256
" set background=dark
" highlight Normal ctermbg=NONE
" highlight nonText ctermbg=NONE
" highlight Normal ctermbg=blue
