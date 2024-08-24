pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--main

--transparency black❎ pink🅾️
palt(0,false)
palt(14,true)

cw=20 --card width
ch=28 --card heigth

function _init()
 turncount=0
 isturnstart=false
 isturnplay=false
 
 maxene=0
 ene=maxene
 
 pdeck={}
 fill_deck(40)
 
 phand={}
 for i=1,5 do draw_card() end
 hancur=1 --hand cursor pos
 phand[hancur].sel=true
 
 start_turn()
 
 --gen_spr_hex(2,10)
end

function _update60()
	
	if isturnplay then
	
	 if btnp(⬅️) then
	  sel_hand("⬅️")
	 elseif btnp(➡️) then
	  sel_hand("➡️")
	 end
	 
	 if btnp(🅾️) then
	   play_card()
	 end
	 
	 if btnp(❎) then
	  isturnplay=false
	  isturnpass=true
	 end
	
	elseif isturnpass then
	
	 if btnp(🅾️) then
	  isturnpass=false
	  isturnplay=true
	 end
	 
	 if btnp(❎) then
	  isturnpass=false
	  start_turn()
	 end
	 
	elseif isturnstart then
	
	 if btnp(🅾️) then
	  maxene+=1
	  ene=maxene
	 elseif btnp(❎) then
	  ene=maxene
	  draw_card()
	 end
	 
	 --check if 🅾️/❎ was pressed
	 if band(btnp(),0x30)>0 then
	  isturnstart=false
	  isturnplay=true
	 end
	
	end
	
end

function _draw()
 cls(1)
 
 render_ene()
 
 render_hand()
 
 if isturnstart then
  rectfill(20,50,107,70,0)
  print("turn "..turncount,21,51,7)
  print("🅾️: energize",43,58,7)
  print("❎: draw",43,64,7)
 end
 
 if isturnpass then
  rectfill(20,50,107,70,0)
  print("end your turn?",29,51,7)
  print("❎: end",43,58,7)
  print("🅾️: continue",43,64,7)
 end
 
end


function getspr(sprdata)
 for j=1,16 do
  for i=1,16 do
   sset(16+i-1,j-1,hex2num(sprdata[i+(j-1)*16]))
  end
 end
end





function add_to_hand(hand,card)
 local newcard={name=card[1],cost=card[2],pwr=card[3],tou=card[4],fx=card[5],gfx=card[6],sel=false}
 add(hand,newcard)
 return hand
end

function sel_hand(dir)
 if #phand > 0 then
  if dir == "⬅️" then
   if hancur > 1 then
    phand[hancur].sel=false
    hancur-=1
    phand[hancur].sel=true
   end
  elseif dir == "➡️" then
   if hancur < #phand then
    phand[hancur].sel=false
    hancur+=1
    phand[hancur].sel=true
   end
  end
 end
end

function play_card()
 --temporarily just erases the
 --card
 
 --if there're cards in hand
 if #phand>0 then
  --if enough energy
  if phand[hancur].cost<=ene then
		 --subtract energy
		 ene-=phand[hancur].cost
		 
		 --remove card from hand
		 deli(phand,hancur)
		 if hancur>#phand then
		  hancur-=1
		 end
		 if #phand>0 then
		  phand[hancur].sel=true
		 end
		end
	end
	
end


function fill_deck(n)
--temporary function
--fills decks with n rnd cards
 local cardsn=#cards
 
 for i=1,n do
  add(pdeck,cards[flr(rnd(cardsn+1))])
 end
end


function draw_card()
--draws a card from top of deck
--to hand
 local drawncard=deli(pdeck,1)
 add_to_hand(phand,drawncard)
end


function start_turn()
 turncount+=1
 isturnstart=true
end
-->8
--render


function render_hand()
 local len=#phand
 if len > 0 then
  for k,v in pairs(phand) do
   render_card(64-(cw/2*len)+(cw*(k-1)+k),98,v)
  end
 end
end


function render_card(x,y,c,parent)
 --args
 --x: int (x position)
 --y: int (y position)
 --c: table (card table)

 local cpx=x --card pos x
 local cpy=y --card pos y
 local z=16  --zoom
 
 --if selected
 if c.sel then
  --draw highlight
  rect(cpx-1,cpy-1,cpx+cw,cpy+ch,8)
  
  --draw tooltip
  --tOOltIplEFTbORDER/rIGHTbORDER
  local cnl=#c.name --cardnamelength
  local tltplb=cpx+(cw/2)-(cnl/2*4)-2
  local tltprb=cpx+(cw/2)+(cnl/2*4)
  if tltplb<0 then
   tltplb+=abs(tltplb)
   tltprb+=abs(tltplb)
  elseif tltprb>127 then
   tltplb-=tltprb-127
   tltprb-=tltprb-127
  end
  rectfill(tltplb ,cpy-9,tltprb ,cpy-2,0)
  print(c.name,tltplb+2,cpy-8,7)
 
 end
 --black border
 rectfill(cpx,cpy,cpx+cw-1,cpy+ch-1,0)
 --card frame
 rectfill(cpx+1,cpy+1,cpx+1+cw-3,cpy+1+ch-3,9)
 --textbox
 rectfill(cpx+2,cpy+19,cpx+2+cw-5,cpy+19+6,10)
 --illustr.
 getspr(c.gfx)
 sspr(16,0,16,16,cpx+2,cpy+2,z,z)
 
 --cost
 circfill(cpx+20,cpy,3,5)
 circfill(cpx+19,cpy,3,6)
 print(c.cost,cpx+20-2,cpy-2,0)
 
 --pwr/tou
 if c.pwr != nil then
  print(c.pwr.."/"..c.tou,cpx+5,cpy+20,0)
 end
end


function render_ene()
 circfill(8,10,6,5)
 circfill(7,10,6,6)
 print("\^w\^t"..ene.."\^-w\^-t/"..maxene,5,5,0)
end
-->8
--card list
cards={
 {"sIMPLE sLIME",1,1,1,"","cccccccbbbccccccccccccccbccccbccccccccccccccbbbccbcccccbcccccbccbbbccccbbccccccccbccccb3bbccccccccccbbbb3bbbcccccccbbbbbb33bbcccccbbbbbbbbbbbbcccc331bbbbb1bbbcc13331bbbbb1bbbbc13331333331bbbbc11333333333bbb11111333333333311111113333333311111111111111111111"},
 {"cOYOTE",2,2,1,"","aaafffffffffffffaafaff4ffff44fffafffaf44ff444fffafffff4444444fffafffff4444444fffffff444044044fffffff444444444ffffff44444444440fffff44444444444fffff4404044f44ffffff4404044ffffffff44440444fffffff440444444ffffff44044444444ffffff4f4444f4444ffff111bb1bbbb1bb111"},
 {"sHADOW cREATURE",4,3,3,"","a00000000000000a0000000000000000000000000000000000080000000080000008800000088000000888000088800000000000000000000000000000000000000000000000000000080000000080000008808080088000000088888888000000000882288000000aaa00222200aaa0aaaaa000000aaaaaa0a0a000000a0a0a"},
 {"bLINDING lIGHT",1,nil,nil,"blind:1","00505a50755575577775a5555755757500577775557aaa55050a555777a7a7a5005a505555aa7aa5050a555577a7a7a5005a5577557aaa7550777755575757577777a5507557575577705a575575575077050575507555757500507a5575057a00007775a755557000577750577aaa7700777700777505775077770577705077"},
 {"mAGIC sHIELD",1,nil,nil,"+health:2","22ccc22cccccc28822c1cccc1cc1c28822c11cc1c111c88822c1c11cccc1888822c1cccc8cc8882222c1c8cccc88c22222c1ccc8c881c22222c1ccc888c1c22222c1cc888881c22222cc1c8c88c1c22222281cccc88cc222222c1cc8cc882222222cc1cccc8882222222cc11c1c8822222222ccc1cc288822222222ccc222882"},
 {"tHUNDER bOLT",2,nil,nil,"damage:1:any","500555005555005555555575570555557557007775500757777000aaa000007700000aaa0000000000000aaa00000000000aaaaa00000000000aaaa0000000000000aaa0000000000000aa00000000000000aaa000a0000000a00aaa0000a00000000aaa000000000aa000aaaa0000000000aaaaaaaa000a000aaaaaaaaaa000"},
 {"sERVICE bOT",1,0,1,"dies:draw:1","1818181668181818818186655681818118166555566818188165555665568181165556655556181865656555585681816556555555561616655658555556866665565555566816568656555665568161186656655555686881656555555661611865565885681618816556588561818118655655556818188165565555568181"},
 {"cASTLE gATE",3,0,5,"defender","6556556556556556666666400466666656556040040565566666404004046666655640400404556566644040040446665654044004404555564404400440445566440440044044665544544004454456554545400454545664454540045454465445554004555445544044400444044554404440044404456440444004440446"},
 {"hANGING fRUIT",2,nil,nil,{"life:2","scry:1"},"0000000000000040000000000000044000000000000044000000000000004000000000000004400000000000022240000000000028882000000000002888200000000004422200000000044444000000000444440000000000444444000000000044444000000000004444000000000004444400000000004444400000000000"},
 {"gIANT mANTIS",3,2,1,"1ststrike","111bb1bbbb1bb11111b11bbbbbb11b111111171bb171111111bb1bbbbbb111111bbb11b33b1111111b7b1b3333b11111b77bb3b33b3b1111b7111333333bb111b71113333331b111b71111333311bb11b713111bb1117bb1b733313333177bbbb73133bbbb77bbb11b711333777bbb313b7177777bbbb13331b11bbbbbb11113"}
}
-->8
--support functions

function rspr(s,x,y,a,w,h)
 --by gabe_8_bit
 sw=(w or 1)*8
 sh=(h or 1)*8
 sx=(s%8)*8
 sy=flr(s/8)*8
 x0=flr(0.5*sw)
 y0=flr(0.5*sh)
 a=a/360
 sa=sin(a)
 ca=cos(a)
 for ix=sw*-1,sw+4 do
  for iy=sh*-1,sh+4 do
   dx=ix-x0
   dy=iy-y0
   xx=flr(dx*ca-dy*sa+x0)
   yy=flr(dx*sa+dy*ca+y0)
   if (xx>=0 and xx<sw and yy>=0 and yy<=sh-1) then
    pset(x+ix,y+iy,sget(sx+xx,sy+yy))
   end
  end
 end
end

function num2hex(number)
--by vitoralmeidasilva
    local base = 16
    local result = {}
    local resultstr = ""

    local digits = "0123456789abcdef"
    local quotient = flr(number / base)
    local remainder = number % base

    add(result, sub(digits, remainder + 1, remainder + 1))

  while (quotient > 0) do
    local old = quotient
    quotient /= base
    quotient = flr(quotient)
    remainder = old % base

         add(result, sub(digits, remainder + 1, remainder + 1))
  end

  for i = #result, 1, -1 do
    resultstr = resultstr..result[i]
  end

  return resultstr
end


function hex2num(number)
--simple one digit hex to dec
 if ord(number)<97 then
  return tonum(number)
 else
  return ord(number)-87
 end
end


function gen_spr_hex(s,n)
--generates hexcode for n 16x16
--sprites starting on start(s)
--(sprnumber on sheet of topleft
--corner)
 local sprn=s
 printh("sprites generated on "..stat(92).."-"..stat(91).."-"..stat(90).." at "..stat(93)..":"..stat(94).."\n\n","sprhex.txt",true,true)
 
 for l=1,n do
  local sprhex=""
	 local x=(sprn%16)*8
	 local y=flr((sprn/16))*8
	 
	 for j=y,y+15 do
	  for i=x,x+15 do
	   local pxclr=tostr(num2hex(sget(i,j)))
	   sprhex=sprhex..pxclr
	  end
	 end
	 
	 printh("sprn:"..sprn.."\n"..sprhex.."\n\n","sprhex.txt",false,true)
  sprn+=2
  if sprn%16==0 then sprn+=16 end
 end

end
__gfx__
00000000e2eeeeeecccccccbbbccccccaaaaaaafffffffffa00000000000000a00505a507555755722ccc22cccccc28850055500555500551818181668181818
00000000272eeeeeccccccccbccccbccaaafffffffffffff00000000000000007775a5555755757522c1cccc1cc1c28855555575570555558181866556818181
007007002772eeeeccccccccccccbbbcaafaff4ffff44fff000000000000000000577775557aaa5522c11cc1c111c88875570077755007571816655556681818
0007700027772eeecbcccccbcccccbccafffaf44ff444fff0008000000008000050a555777a7a7a522c1c11cccc18888777000aaa00000778165555665568181
00077000277772eebbbccccbbcccccccafffff4444444fff0008800000088000005a505555aa7aa522c1cccc8cc8882200000aaa000000001655566555561818
0070070027722eeecbccccb3bbccccccafffff4444444fff0008880000888000050a555577a7a7a522c1c8cccc88c22200000aaa000000006565655558568181
00000000e2272eeeccccbbbb3bbbccccffff444044044fff0000000000000000005a5577557aaa7522c1ccc8c881c222000aaaaa000000006556555555561616
00000000eeeeeeeecccbbbbbb33bbcccffff444444444fff0000000000000000507777555757575722c1ccc888c1c222000aaaa0000000006556585555568666
0000000000000000ccbbbbbbbbbbbbccfff44444444440ff00000000000000007777a5507557575522c1cc888881c2220000aaa0000000006556555556681656
0000000000000000cc331bbbbb1bbbccfff44444444444ff000800000000800077705a575575575022cc1c8c88c1c2220000aa00000000008656555665568161
000000000000000013331bbbbb1bbbbcfff4404044f44fff0008808080088000770505755075557522281cccc88cc2220000aaa000a000001866566555556868
000000000000000013331333331bbbbcfff4404044ffffff00008888888800007500507a5575057a222c1cc8cc88222200a00aaa0000a0008165655555566161
000000000000000011333333333bbb11ff44440444ffffff000008822880000000007775a7555570222cc1cccc88822200000aaa000000001865565885681618
00000000000000001113333333333111f440444444ffffff0aaa00222200aaa000577750577aaa772222cc11c1c882220aa000aaaa0000008165565885618181
0000000000000000111133333333111144044444444fffffaaaaa000000aaaaa007777007775057722222ccc1cc288820000aaaaaaaa000a1865565555681818
00000000000000001111111111111111f4f4444f4444ffffa0a0a000000a0a0a50777705777050772222222ccc222882000aaaaaaaaaa0008165565555568181
65565565565565560000000000000040111bb1bbbb1bb111f0000000000000000000000000000000000000000000000000000000000000000000000000000000
6666664004666666000000000000044011b11bbbbbb11b11f0000000000000000000000000000000000000000000000000000000000000000000000000000000
565560400405655600000000000044001111171bb1711111f0000000000000000000000000000000000000000000000000000000000000000000000000000000
6666404004046666000000000000400011bb1bbbbbb11111f0000000000000000000000000000000000000000000000000000000000000000000000000000000
655640400404556500000000000440001bbb11b33b111111f0000000000000000000000000000000000000000000000000000000000000000000000000000000
666440400404466600000000022240001b7b1b3333b11111f0000000000000000000000000000000000000000000000000000000000000000000000000000000
56540440044045550000000028882000b77bb3b33b3b1111f0000000000000000000000000000000000000000000000000000000000000000000000000000000
56440440044044550000000028882000b7111333333bb111f0000000000000000000000000000000000000000000000000000000000000000000000000000000
66440440044044660000000442220000b71113333331b111f0000000000000000000000000000000000000000000000000000000000000000000000000000000
55445440044544560000044444000000b71111333311bb11f0000000000000000000000000000000000000000000000000000000000000000000000000000000
55454540045454560004444400000000b713111bb1117bb1f0000000000000000000000000000000000000000000000000000000000000000000000000000000
64454540045454460044444400000000b733313333177bbbf0000000000000000000000000000000000000000000000000000000000000000000000000000000
54455540045554450044444000000000b73133bbbb77bbb1f0000000000000000000000000000000000000000000000000000000000000000000000000000000
544044400444044500444400000000001b711333777bbb3100000000000000000000000000000000000000000000000000000000000000000000000000000000
544044400444044504444400000000003b7177777bbbb13300000000000000000000000000000000000000000000000000000000000000000000000000000000
6440444004440446444440000000000031b11bbbbbb1111300000000000000000000000000000000000000000000000000000000000000000000000000000000
