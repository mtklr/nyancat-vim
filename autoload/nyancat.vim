"
" autoload/nyancat.vim - Show Nyancat animation.
"
" Author: MURAOKA Taro <koron.kaoriya@gmail.com>

scriptencoding utf-8

let s:COLUMNS = 80
let s:ROWS = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]
let s:BLOCKS = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
let s:COLORS = [
      \ [ '#000000',  0 ],
      \ [ '#000080',  1 ],
      \ [ '#008000',  2 ],
      \ [ '#008080',  3 ],
      \ [ '#800000',  4 ],
      \ [ '#800080',  5 ],
      \ [ '#808000',  6 ],
      \ [ '#C0C0C0',  7 ],
      \ [ '#808080',  8 ],
      \ [ '#0000ff',  9 ],
      \ [ '#00ff00', 10 ],
      \ [ '#00ffff', 11 ],
      \ [ '#ff0000', 12 ],
      \ [ '#ff00ff', 13 ],
      \ [ '#ffff00', 14 ],
      \ [ '#ffffff', 15 ]
      \]

function! s:Game()
  let doc = s:GameOpen()
  call s:GameMain(doc)
  echo s:GameClose(doc)
endfunction

function! s:GameOpen()
  if !exists("g:nyancat_display_statusline")
    let g:nyancat_display_statusline = 0
  endif
  let s:number_value = &number
  let s:lazyredraw_value = &lazyredraw
  let s:laststatus_value = &laststatus
  let s:cmdheight_value = &cmdheight
  let s:undolevels_value = &undolevels
  let s:list_value = &list
  enew
  set nonumber
  set lazyredraw
  setlocal nofoldenable
  setlocal buftype=nofile noswapfile
  if g:nyancat_display_statusline == 0
    set laststatus=0 cmdheight=1
  endif
  set undolevels=-1
  setlocal nolist
  " Initialize screen buffer
  let doc = {}
  let doc.screenBuffer = []
  let s = repeat(s:BLOCKS[0], s:COLUMNS)
  for i in s:ROWS
    call add(doc.screenBuffer, s)
  endfor
  call s:ColorInit()
  call s:GDocInit(doc)
  return doc
endfunction

function! s:GameMain(doc)
  let running = 1
  while running
    call s:GameDraw(a:doc)
    execute 'sleep ' . a:doc.wait
    let running = s:GDocUpdate(a:doc, getchar(0))
  endwhile
endfunction

function! s:GameDraw(doc)
  execute "%d"
  call append(0, a:doc.screenBuffer)
  redraw
endfunction

function! s:GameClose(doc)
  call s:GDocFinal(a:doc)
  let &number = s:number_value
  let &lazyredraw = s:lazyredraw_value
  let &laststatus = s:laststatus_value
  let &cmdheight = s:cmdheight_value
  let &undolevels = s:undolevels_value
  let &list = s:list_value
  return get(a:doc, 'title', 'GAME END')
endfunction

function! s:ColorInit()
  syntax clear
  let idx = 0
  while idx < len(s:BLOCKS)
    if idx < len(s:COLORS)
      let gcolor = s:COLORS[idx][0]
      let ccolor = s:COLORS[idx][1]
    else
      let gcolor = s:COLORS[0][0]
      let ccolor = s:COLORS[0][1]
    endif
    call s:ColorSet(idx, gcolor, ccolor)
    let idx = idx + 1
  endwhile
endfunction

function! s:ColorSet(idx, gcolor, ccolor)
  if type(a:idx) == 0
    let idx2 = a:idx
  else
    let idx2 = stridx(s:BLOCKS, a:idx)
  endif
  if idx2 < 0 || idx2 >= strlen(s:BLOCKS)
    return
  endif

  let target = s:BLOCKS[idx2]
  let name = 'gameBlock'.idx2
  let target = escape(target, '/\\*^$.~[]')
  execute 'syntax match '.name.' /'.target.'/'
  execute 'highlight '.name." guifg='".a:gcolor."'"
  execute 'highlight '.name." guibg='".a:gcolor."'"
  execute 'highlight '.name." ctermfg='".a:ccolor."'"
  execute 'highlight '.name." ctermbg='".a:ccolor."'"
endfunction

"===========================================================================
" GDoc functions.

let s:PATTERN1 = [
      \[
      \ " .                                                                              ",
      \ "                                                                                ",
      \ "                         '''''''''''''''                                        ",
      \ "   >>>>>>>        >>>>>>'@@@@@@@@@@@@@@@'                                       ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@@$$$$$$$$$$$@@@'                                      ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@$$$$$-$$-$$$$@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$-$$$$$$''$-$$@' ''                                   ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$$$$$$$'**'$$$@''**'                                  ",
      \ "&&&+++++++&&&&&&&&'''++'@$$$$$-$$'***$$$@'***'                                  ",
      \ "++++++++++++++++++**''+'@$$$$$$$$'***''''****'                                  ",
      \ "++++++++++++++++++'**'''@$$$$$$$$'***********'                                  ",
      \ "+++#######++++++++''**''@$$$$$$-'*************'                                 ",
      \ "###################''**'@$-$$$$$'***.'****.'**'                                 ",
      \ "####################''''@$$$$$$$'***''**'*''**'                                 ",
      \ "###=======########====''@@$$$-$$'*%%********%%'                                 ",
      \ "======================='@@@$$$$$$'***''''''**'                                  ",
      \ "===;;;;;;;.=======;;;;'''@@@@@@@@@'*********'                                   ",
      \ ";;;;;;;;;;;;;;;;;;;;;'***'''''''''''''''''''                                    ",
      \ ";;;;;;;;;;;;;;;;;;;;;'**'' '*'     '*' '**'                                     ",
      \ ";;;    .  ;;;.;;;;   ''''  ''       ''  ''                                      ",
      \ "                                                                                ",
      \ "                                                                                ",
      \], [
      \ "                                                                                ",
      \ "                                                                                ",
      \ "                         '''''''''''''''                                        ",
      \ "   >>>>>>>        >>>>>>'@@@@@@@@@@@@@@@'                                       ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@@$$$$$$$$$$$@@@'                                      ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@$$$$$-$$-$$$$@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$-$$$$$$$''-$$@'  ''                                  ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$$$$$$$$'**'$$@' '**'                                 ",
      \ "&&&+++++++&&&&&&&&+++++'@$$$$$-$$$'***$$@''***'                                 ",
      \ "+++++++++++++++++++'+++'@$$$$$$$$$'***''''****'                                 ",
      \ "++++++++++++++++++'*'++'@$$$$$$$$$'***********'                                 ",
      \ "+++#######++++++++'*''''@$$$$$$-$'*************'                                ",
      \ "###################****'@$-$$$$$$'***.'****.'**'                                ",
      \ "###################''**'@$$$$$$$$'***''**'*''**'                                ",
      \ "###=======########==='''@@$$$-$$$'*%%********%%'                                ",
      \ "======================='@@@$$$$$$$'***''''''**'                                 ",
      \ "===;;;;;;;========;;;;;''@@@@@@@@@@'*********'                                  ",
      \ ";;;;;;;;;;;;;;;;;;;;;;'**''''''''''''''''''''                                   ",
      \ ";;;;;;;;;;;;;;;;;;;;;;'**' '*'      **' '**'                                    ",
      \ ";;;  .    ;;;;;;;;    '''   ''      '''  '''                                    ",
      \ "                                                                                ",
      \ "                                                                                ",
      \], [
      \ "                                                                                ",
      \ "                                                               .                ",
      \ "                                                               .                ",
      \ ">>       >>>>>>>>        '''''''''''''''                                        ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>>'@@@@@@@@@@@@@@@'                                       ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@@$$$$$$$$$$$@@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@@$$$$$-$$-$$$$@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$-$$$$$$$''-$$@'  ''                                  ",
      \ "++&&&&&&&++++++++&&&&&&'@$$$$$$$$$'**'$$@' '**'                                 ",
      \ "+++++++++++++++++++++++'@$$$$$-$$$'***$$@''***'                                 ",
      \ "+++++++++++++++++++++++'@$$$$$$$$$'***''''****'                                 ",
      \ "##+++++++########++++++'@$$$$$$$$$'***********'                                 ",
      \ "######################''@$$$$$$-$'*************'                                ",
      \ "###################'''''@$-$$$$$$'***.'****.'**'                                ",
      \ "==#######========#'****'@$$$$$$$$'***''**'*''**'                                ",
      \ "==================='''='@@$$$-$$$'*%%********%%'                                ",
      \ ";;=======;;;;;;;;======'@@@$$$$$$$'***''''''**'                                 ",
      \ ";;;;;;;;;;;;;;;;;;;;;;;''@@@@@@@@@@'*********'                                  ",
      \ ";.;;;;;;;;;;;;;;;;;;;;;'*''''''''''''''''''''                                   ",
      \ ". .;;;;;;        ;;;;;;'**' **'      **' '**'                                   ",
      \ " .                     '''  '''      '''  '''                                   ",
      \ "                                                                                ",
      \], [
      \ "                                                                                ",
      \ "                                                      .   .                     ",
      \ "                                                        .                       ",
      \ ">>       >>>>>>>>        '''''''''''''''                                        ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>>'@@@@@@@@@@@@@@@'                                       ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@@$$$$$$$$$$$@@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@@$$$$$-$$-$$$$@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$-$$$$$$$''-$$@'  ''                                  ",
      \ "++&&&&&&&++++++++&&&&&&'@$$$$$$$$$'**'$$@' '**'                                 ",
      \ "+++++++++++++++++++++++'@$$$$$-$$$'***$$@''***'                                 ",
      \ "+++++++++++++++++++++++'@$$$$$$$$$'***''''****'                                 ",
      \ "##+++++++########++++++'@$$$$$$$$$'***********'                                 ",
      \ "#####################'''@$$$$$$-$'*************'                                ",
      \ "###################''**'@$-$$$$$$'***.'****.'**'                                ",
      \ "==#######========##****'@$$$$$$$$'***''**'*''**'                                ",
      \ "=================='*'=='@@$$$-$$$'*%%********%%'                                ",
      \ ";;=======;;;;;;;;=='==='@@@$$$$$$$'***''''''**'                                 ",
      \ ";;;;;;;;;;;;;;;;;;;;;;;''@@@@@@@@@@'*********'                                  ",
      \ ";;;;;;;;;;;;;;;;;;;;;;'**''''''''''''''''''''                                   ",
      \ "  ;;;;;;;        ;;;;;'**' '*'      '*' '**'                                    ",
      \ "                      '''   ''       ''  '''                                    ",
      \ "                                                                                ",
      \], [
      \ "                                                                                ",
      \ "                                                                                ",
      \ "                                                 .                              ",
      \ "   >>>>>>>        >>>>>>>'''''''''''''''                                        ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>>'@@@@@@@@@@@@@@@'                                       ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@@$$$$$$$$$$$@@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@@$$$$$-$$-$$$$@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$-$$$$$$''$-$$@' ''                                   ",
      \ "&&&+++++++&&&&&&&&+++++'@$$$$$$$$'**'$$$@''**'                                  ",
      \ "+++++++++++++++++++++++'@$$$$$-$$'***$$$@'***'                                  ",
      \ "++++++++++++++++++'''++'@$$$$$$$$'***''''****'                                  ",
      \ "+++#######+++++++'**''''@$$$$$$$$'***********'                                  ",
      \ "#################'****''@$$$$$$-'*************'                                 ",
      \ "##################''''*'@$-$$$$$'***.'****.'**'                                 ",
      \ "###=======########==='''@$$$$$$$'***''**'*''**'                                 ",
      \ "======================='@@$$$-$$'*%%********%%'                                 ",
      \ "===;;;;;;;========;;;;''@@@$$$$$$'***''''''**'                                  ",
      \ ";;;;;;;;;;;;;;;;;;;;;''''@@@@@@@@@'*********'                                   ",
      \ ";;;;;;;;;;;;;;;;;;;;'***''''''''''''''''''''                                    ",
      \ ";;;       ;;;;;;;;  '**' '**      '** '**'                                      ",
      \ "                    '''   ''       ''  '''                                      ",
      \ "                                                                                ",
      \], [
      \ "                                                                                ",
      \ "                                                                                ",
      \ "                                                                                ",
      \ "   >>>>>>>        >>>>>>>'''''''''''''''                                        ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>>'@@@@@@@@@@@@@@@'                                       ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@@$$$$$$$$$$$@@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@@$$$$$-$$''$$$@@' ''                                   ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$-$$$$$'**'-$$@''**'                                  ",
      \ "&&&+++++++&&&&&&&&+++++'@$$$$$$$$'***$$$@'***'                                  ",
      \ "+++++++++++++++++++'+++'@$$$$$-$$'***''''****'                                  ",
      \ "++++++++++++++++++'*'++'@$$$$$$$$'***********'                                  ",
      \ "+++#######++++++++'*''''@$$$$$$$'*************'                                 ",
      \ "###################****'@$$$$$$-'***.'****.'**'                                 ",
      \ "###################''**'@$-$$$$$'***''**'*''**'                                 ",
      \ "###=======########==='''@$$$$$$$'*%%********%%'                                 ",
      \ "======================='@@$$$-$$$'***''''''**'                                  ",
      \ "===;;;;;;;========;;;;''@@@$$$$$$$'*********'                  .                ",
      \ ";;;;;;;;;;;;;;;;;;;;;'*''@@@@@@@@@@'''''''''                   .                ",
      \ ";;;;;;;;;;;;;;;;;;;;'***''''''''''''''''*'                                      ",
      \ ";;;       ;;;;;;;;  '**' '**      '** '**'                  .. .                ",
      \ "                    '''  '''      '''  '''                                      ",
      \ "                                                               .                ",
      \], [
      \ "                                       .                                        ",
      \ "                                                                                ",
      \ "                         '''''''''''''''                                        ",
      \ ">>       >>>>>>>>       '@@@@@@@@@@@@@@@'                                       ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@@$$$$$$$$$$$@@@'                                      ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@$$$$$-$$-$$$$@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$-$$$$$$''$-$$@' ''                                   ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$$$$$$$'**'$$$@''**'                                  ",
      \ "++&&&&&&&++++++++&'''&&'@$$$$$-$$'***$$$@'***'                                  ",
      \ "++++++++++++++++++'*''+'@$$$$$$$$'***''''****'                                  ",
      \ "++++++++++++++++++'**'''@$$$$$$$$'***********'                                  ",
      \ "##+++++++########++'**''@$$$$$$-'*************'                                 ",
      \ "###################''**'@$-$$$$$'***.'****.'**'                                 ",
      \ "####################''''@$$$$$$$'***''**'*''**'                                 ",
      \ "==#######========#####''@@$$$-$$'*%%********%%'                                 ",
      \ "======================='@@@$$$$$$'***''''''**'                                  ",
      \ ";;=======;;;;;;;;====='''@@@@@@@@@'*********'           .                       ",
      \ ";;;;;;;;;;;;;;;;;;;;;'***'''''''''''''''''''          .   .                     ",
      \ ";;;;;;;;;;;;;;;;;;;;;'**'' '*'     '** '**'                                     ",
      \ "  ;;;;;;;        ;;;;''''  ''       ''  ''           .     .                    ",
      \ "                                                                                ",
      \ "                                                      .   .                     ",
      \], [
      \ "                                  .                                             ",
      \ "                                  .                                             ",
      \ "                         '''''''''''''''                                        ",
      \ ">>       >>>>>>>>       '@@@@@@@@@@@@@@@'                                       ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@@$$$$$$$$$$$@@@'                                      ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@$$$$$-$$-$$$$@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$-$$$$$$$''-$$@'  ''                                  ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$$$$$$$$'**'$$@' '**'                                 ",
      \ "++&&&&&&&++++++++&&&&&&'@$$$$$-$$$'***$$@''***'                                 ",
      \ "+++++++++++++++++++'+++'@$$$$$$$$$'***''''****'                                 ",
      \ "++++++++++++++++++'*'++'@$$$$$$$$$'***********'                                 ",
      \ "##+++++++########+'*''''@$$$$$$-$'*************'                                ",
      \ "###################****'@$-$$$$$$'***.'****.'**'                                ",
      \ "###################''**'@$$$$$$$$'***''**'*''**'                                ",
      \ "==#######========####'''@@$$$-$$$'*%%********%%'                                ",
      \ "======================='@@@$$$$$$$'***''''''**'                                 ",
      \ ";;=======;;;;;;;;======''@@@@@@@@@@'*********'   .                              ",
      \ ";;;;;;;;;;;;;;;;;;;;;;'**''''''''''''''''''''                                   ",
      \ ";;;;;;;;;;;;;;;;;;;;;;'**' '*'      **' '**'                                    ",
      \ "  ;;;;;;;        ;;;;;'''   ''      '''  '''  .    .                            ",
      \ "                                                                                ",
      \ "                                                                                ",
      \], [
      \ "                                                                                ",
      \ "                           .                                                    ",
      \ "                           .                                                    ",
      \ "   >>>>>>>        >>>>>>>'''''''''''''''                                        ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>>'@@@@@@@@@@@@@@@'                                       ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@@$$$$$$$$$$$@@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@@$$$$$-$$-$$$$@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$-$$$$$$$''-$$@'  ''                                  ",
      \ "&&&+++++++&&&&&&&&+++++'@$$$$$$$$$'**'$$@' '**'                                 ",
      \ "+++++++++++++++++++++++'@$$$$$-$$$'***$$@''***'                                 ",
      \ "+++++++++++++++++++++++'@$$$$$$$$$'***''''****'                                 ",
      \ "+++#######++++++++#####'@$$$$$$$$$'***********'                                 ",
      \ "######################''@$$$$$$-$'*************'                                ",
      \ "###################'''''@$-$$$$$$'***.'****.'**'                                ",
      \ "###=======########'****'@$$$$$$$$'***''**'*''**'                                ",
      \ "==================='''='@@$$$-$$$'*%%********%%'                                ",
      \ "===;;;;;;;========;;;;;'@@@$$$$$$$'***''''''**'                                 ",
      \ ";;;;;;;;;;;;;;;;;;;;;;;''@@@@@@@@@@'*********'                                  ",
      \ ";;;;;;;;;;;;;;;;;;;;;;;'*''''''''''''''''''''                                   ",
      \ ";;;       ;;;;;;;;     '**' **'      **'.'**'                                   ",
      \ "                       '''  '''      '''  '''                                   ",
      \ "                                                                                ",
      \], [
      \ "                                                                                ",
      \ "                    .                                                           ",
      \ "                  .                                                             ",
      \ "   >>>>>>>        >>>>>>>'''''''''''''''                                        ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>>'@@@@@@@@@@@@@@@'                                       ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@@$$$$$$$$$$$@@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@@$$$$$-$$-$$$$@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$-$$$$$$$''-$$@'  ''                                  ",
      \ "&&&+++++++&&&&&&&&+++++'@$$$$$$$$$'**'$$@' '**'                                 ",
      \ "+++++++++++++++++++++++'@$$$$$-$$$'***$$@''***'                                 ",
      \ "+++++++++++++++++++++++'@$$$$$$$$$'***''''****'                                 ",
      \ "+++#######++++++++#####'@$$$$$$$$$'***********'                                 ",
      \ "#####################'''@$$$$$$-$'*************'                                ",
      \ "###################''**'@$-$$$$$$'***.'****.'**'                                ",
      \ "###=======########=****'@$$$$$$$$'***''**'*''**'                                ",
      \ "=================='*'=='@@$$$-$$$'*%%********%%'                                ",
      \ "===;;;;;;;========;';;;'@@@$$$$$$$'***''''''**'                                 ",
      \ ";;;;;;;;;;;;;;;;;;;;;;;''@@@@@@@@@@'*********'                                  ",
      \ ";;;;;;;;;;;;;;;;;;;;;;'**''''''''''''''''''''                                   ",
      \ ";;;       ;;;;;;;;    '**' '*'  .. .**' '**'                                    ",
      \ "                      '''   ''    . '''  '''                                    ",
      \ "                                  .                                             ",
      \], [
      \ "                                                                                ",
      \ "                                                                                ",
      \ "          .                                                                     ",
      \ ">>       >>>>>>>>        '''''''''''''''                                        ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>>'@@@@@@@@@@@@@@@'                                       ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@@$$$$$$$$$$$@@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@@$$$$$-$$-$$$$@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$-$$$$$$''$-$$@' ''                                   ",
      \ "++&&&&&&&++++++++&&&&&&'@$$$$$$$$'**'$$$@''**'                                  ",
      \ "+++++++++++++++++++++++'@$$$$$-$$'***$$$@'***'                                  ",
      \ "++++++++++++++++++'''++'@$$$$$$$$'***''''****'                                  ",
      \ "##+++++++########'**''''@$$$$$$$$'***********'                                  ",
      \ "#################'****''@$$$$$$-'*************'                                 ",
      \ "##################''''*'@$-$$$$$'***.'****.'**'                                 ",
      \ "==#######========####'''@$$$$$$$'***''**'*''**'                                 ",
      \ "======================='@@$$$-$$'*%%********%%'                                 ",
      \ ";;=======;;;;;;;;=====''@@@$$$$$$'***''''''**'                                  ",
      \ ";;;;;;;;;;;;;;;;;;;;;''''@@@@@@@@@'*********'                                   ",
      \ ";;;;;;;;;;;;;;;;;;;;'***''''''''''''''''''''                                    ",
      \ "  ;;;;;;;        ;;;'**'.'**..    '**''**'                                      ",
      \ "                    '''   ''       ''' '''                                      ",
      \ "                           .                                                    ",
      \], [
      \ "                                                                                ",
      \ "                                                                                ",
      \ "                                                                                ",
      \ ">>       >>>>>>>>        '''''''''''''''                                        ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>>'@@@@@@@@@@@@@@@'                                       ",
      \ ">>>>>>>>>>>>>>>>>>>>>>>'@@@$$$$$$$$$$$@@@'                                      ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@@$$$$$-$$''$$$@@' ''                                   ",
      \ "&&&&&&&&&&&&&&&&&&&&&&&'@$$-$$$$$'**'-$$@''**'                                  ",
      \ "++&&&&&&&++++++++&&&&&&'@$$$$$$$$'***$$$@'***'                                  ",
      \ "+++++++++++++++++++'+++'@$$$$$-$$'***''''****'                                  ",
      \ "++++++++++++++++++'*'++'@$$$$$$$$'***********'                                  ",
      \ "##+++++++########+'*''''@$$$$$$$'*************'                                 ",
      \ "###################****'@$$$$$$-'***.'****.'**'                                 ",
      \ "###################''**'@$-$$$$$'***''**'*''**'                                 ",
      \ "==#######========####'''@$$$$$$$'*%%********%%'                                 ",
      \ "======================='@@$$$-$$$'***''''''**'                                  ",
      \ ";;=======;;;;;;;;=.===''@@@$$$$$$$'*********'                                   ",
      \ ";;;;;;;;;;;;;;;;;;;;.'*''@@@@@@@@@@'''''''''                                    ",
      \ ";;;;;;;;;;;;;;;;;;;;'***''''''''''''''''*'                                      ",
      \ "  ;;;;;;;       .;;;'**' '**      '**''**'                                      ",
      \ "                    '''  '''      '''  '''                                      ",
      \ "                    .                                                           ",
      \],
      \]

function! s:GDocInit(doc)
  let a:doc.title = 'nyancat'
  let a:doc.count = 0
  let a:doc.wait = '50m'
  let a:doc.patterns = s:PATTERN1
  call s:ColorSet(',', '#000080', 1)
  call s:ColorSet('.', '#ffffff', 15)
  call s:ColorSet("'", '#000000', 0)
  call s:ColorSet('@', '#fecc97', 14)
  call s:ColorSet('$', '#ff99ff', 13)
  call s:ColorSet('-', '#f9349e', 12)
  call s:ColorSet('>', '#ff0000', 12)
  call s:ColorSet('&', '#ff9000', 14)
  call s:ColorSet('+', '#ffff00', 10)
  call s:ColorSet('#', '#33ff00', 11)
  call s:ColorSet('=', '#0090ff', 9)
  call s:ColorSet(';', '#6535fd', 13)
  call s:ColorSet('*', '#989898', 8)
  call s:ColorSet('%', '#ff9898', 13)
endfunction

function! s:GDocUpdate(doc, ev)
  " Check termination.
  if a:ev
    return 0
  endif

  let curr = a:doc.patterns[a:doc.count]
  let sbuf = a:doc.screenBuffer
  for i in s:ROWS
    let sbuf[i] = curr[i]
  endfor

  let a:doc.count = a:doc.count + 1
  if a:doc.count >= len(a:doc.patterns)
    let a:doc.count = 0
  endif

  return 1
endfunction

function! s:GDocFinal(doc)
  " Finalize game document (ex. save high score, etc).
endfunction

"===========================================================================
" Start the game.

function! nyancat#start()
  call s:Game()
endfunction

" vim:set ts=8 sts=2 sw=2 tw=0 et:
