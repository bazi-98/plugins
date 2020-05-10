--[[
	N24 DOKU
	Vers.: 0.1
	Copyright
        (C) 2019  bazi98

        App Description:
        There the player links are respectively read about the recent documentaries of the German Television "N24 DOKU"
        from the Welt library, displays and allows them to play with the neutrino-movie player.

	License: GPL

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public
	License as published by the Free Software Foundation; either
	version 2 of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public
	License along with this program; if not, write to the
	Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
	Boston, MA  02110-1301, USA.

        Copyright (C) for the linked videos and for the Logo by the WeltN24 GmbH, Berlin or the respective owners!
]]

local json = require "json"

-- Date / Time
heute=(os.date ("%Y-%m-%d"))
gestern = (os.date("%Y-%m-%d", os.time() - 3600*24))
vorgestern = (os.date("%Y-%m-%d", os.time() - 3600*48))
morgen = (os.date("%Y-%m-%d", os.time() + 3600*24))
uebermorgen = (os.date("%Y-%m-%d", os.time() + 3600*48))

-- Auswahl -- evtl auch https://www.welt.de/onward/most-watched/broadcast/
local subs = {
	{'https://www.welt.de/live-tv/epg/n24doku/'..vorgestern..'/', 'vorgestern'},
	{'https://www.welt.de/live-tv/epg/n24doku/'..gestern..'/', 'gestern'},
	{'https://www.welt.de/live-tv/epg/n24doku/'..heute..'/', 'heute'},
	{'https://www.welt.de/live-tv/epg/n24doku/'..morgen..'/', 'morgen'}
}

--Objekte
function script_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*/)")
end

function init()
	n = neutrino();
	p = {}
	func = {}
	pmid = 0
	stream = 1
        tmpPath = "/tmp"
	n24_doku = decodeImage("data:image/png;base64,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")
end

function add_stream(t,u,f)
  p[#p+1]={title=t,url=u,from=f,access=stream}
end

function getdata(Url,outputfile)
	if Url == nil then return nil end
	if Curl == nil then
		Curl = curl.new()
	end
	local ret, data = Curl:download{url=Url,A="Mozilla/5.0;",followRedir=true,o=outputfile }
	if ret == CURL.OK then
		return data
	else
		return nil
	end
end

-- function from http://lua-users.org/wiki/BaseSixtyFour

-- character table string
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- decode
function dec(data)
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
    	if (x == '=') then return '' end
    	local r,f='',(b:find(x)-1)
    	for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
    	return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
    	if (#x ~= 8) then return '' end
    	local c=0
    	for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
    	return string.char(c)
	end))
end

function decodeImage(b64Image)
	local imgTyp = b64Image:match("data:image/(.-);base64,")
	local repData = "data:image/" .. imgTyp .. ";base64,"
	local b64Data = string.gsub(b64Image, repData, "");

	local tmpImg = os.tmpname()
	local retImg = tmpImg .. "." .. imgTyp

	local f = io.open(retImg, "w+")
	f:write(dec(b64Data))
	f:close()
	os.remove(tmpImg)

	return retImg
end

-- UTF8 in Umlaute wandeln
function conv_str(_string)
	if _string == nil then return _string end
        _string = string.gsub(_string,'\\','');
	_string = string.gsub(_string,"&amp;","&");
	_string = string.gsub(_string,"&quot;","'");
	_string = string.gsub(_string,"&#039;","'");
	_string = string.gsub(_string,"&#x27;","'");
	_string = string.gsub(_string,"&#x60;","`");
	return _string
end

function fill_playlist(id) --- > begin playlist
	p = {}
	for i,v in  pairs(subs) do
		if v[1] == id then
			sm:hide()
			nameid = v[2]	
			local data  = getdata( id ,nil)
			if data then
				for  item in data:gmatch('<a class="o%-link c%-epg%-item(.-" href=.-)<div class="c%-epg%-item__image u%-display%-%-is%-hidden')  do
					local link,title = item:match('href="(.-html)">(.-)</a>') 
					seite = 'https://www.welt.de' .. link 
					epg1 = item:match('c%-epg%-item__text">(.-)</div>')
					if seite and title then
						add_stream( conv_str(title), seite, conv_str(epg1))
					end
				end
			end
			select_playitem()
		end
	end
end --- > end of playlist

-- epg-Fenster
local epg = ""
local title = ""

function epgInfo (xres, yres, aspectRatio, framerate)
	if #epg < 1 then return end 
	local dx = 800;
	local dy = 400;
	local x = 0;
	local y = 0;

	local hw = n:getRenderWidth(FONT['MENU'],title) + 20
	if hw > 400 then
		dy = hw
	end
	if dy >  SCREEN.END_X - SCREEN.OFF_X - 20 then
		dy = SCREEN.END_X - SCREEN.OFF_X - 20
	end
	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title=" ", icon=n24_doku, has_shadow="true", show_header="true", show_footer="false"};  -- with out footer
	dy = dy + wh:headerHeight()

	local ct = ctext.new{parent=wh, x=20, y=0, dx=0, dy=dy, text = epg, font_text=FONT['MENU'], mode = "ALIGN_SCROLL | DECODE_HTML"};
 	h = ct:getLines() * n:FontHeight(FONT['MENU'])
	h = (ct:getLines() +4) * n:FontHeight(FONT['MENU'])
	if h > SCREEN.END_Y - SCREEN.OFF_Y -20 then
		h = SCREEN.END_Y - SCREEN.OFF_Y -20
	end
 	wh:setDimensionsAll(x,y,dx,h)
        ct:setDimensionsAll(20,0,dx-40,h) -- wg. rechts unten runder ecke
	wh:setCenterPos{3}
	wh:paint()

	repeat
		msg, data = n:GetInput(500)
		if msg == RC.up or msg == RC.page_up then
			ct:scroll{dir="up"};
		elseif msg == RC.down or msg == RC.page_down then
			ct:scroll{dir="down"};
		end
	until msg == RC.ok or msg == RC.home or msg == RC.info
	wh:hide()
end

function set_pmid(id)
  pmid=tonumber(id);
  return MENU_RETURN["EXIT_ALL"];
end

function select_playitem()
--local m=menu.new{name="N24 DOKU", icon=""} -- only text
  local m=menu.new{name="", icon=n24_doku} -- only icon

  for i,r in  ipairs(p) do
    m:addItem{type="forwarder", action="set_pmid", id=i, icon="streaming", name=r.title, hint=r.from, hint_icon="hint_reload"}
  end

  repeat
    pmid=0
    m:exec()
    if pmid==0 then
      return
    end

    local vPlay = nil
    local url=func[p[pmid].access](p[pmid].url)
    if url~=nil then
      if  vPlay  ==  nil  then
	vPlay  =  video.new()
      end

	local js_data = getdata(url,nil)
	local video_url = js_data:match('"m3u8".-"src":"(http.-mp4)"') 

	local epg1 = js_data:match('articleBody".-:.-"<p>(.-)</p>') 
	if epg1 == nil then
		epg1 = "N24 DOKU stellt für diese Sendung keinen EPG-Text bereit."
	end
	local title = js_data:match('"alternativeHeadline"% :% "(.-)"%,')

	local duration = js_data:match('<span data%-qa%="VideoDuration">(.-)</span>')

	if title == nil then
		title = p[pmid].title
	end

	if video_url then 
		epg = conv_str(title) .. '\n\n' .. conv_str(epg1) .. '\n\n' .. duration 
		vPlay:setInfoFunc("epgInfo")
                url = video_url
	        vPlay:PlayFile("N24 DOKU",url,conv_str(title), duration);
	else
		print("Video URL not found")
--[[
		epg = 'WELT HD\n\nDie ausgewählte Sendung ist aus rechtlichen Gründen nicht oder nicht mehr online verfügbar als Ersatz wird der aktuelle Livestream von Welt HD gezeigt'
		vPlay:setInfoFunc("epgInfo")
		vPlay:PlayFile("WELT HD","https://live2weltcms-lh.akamaihd.net/i/Live2WeltCMS_1@444563/index_1_av-p.m3u8"," Livestream von WELT HD");

]]
	end
   end
  until false
end

function godirectkey(d)
	if d  == nil then return d end
	local  _dkey = ""
	if d == 1 then
		_dkey = RC.red
	elseif d == 2 then
		_dkey = RC.green
	elseif d == 3 then
		_dkey = RC.yellow
	elseif d == 4 then
		_dkey = RC.blue
	elseif d < 14 then
		_dkey = RC[""..d - 4 ..""]
	elseif d == 14 then
		_dkey = RC["0"]
	else
		-- rest
		_dkey = ""
	end
	return _dkey
end

function selectmenu()
	sm = menu.new{name="", icon=n24_doku}
	sm:addItem{type="separator"}
	sm:addItem{type="back"}
	sm:addItem{type="separatorline"}
	local d = 0 -- directkey
	for i,v in  ipairs(subs) do
		d = d + 1
		local dkey = godirectkey(d)
		sm:addItem{type="forwarder", name=v[2], action="fill_playlist",id=v[1], hint='Manche Sendungen sind aus lizenzrechtlichen Gründen nur zeitweise Online verfügbar!', directkey=dkey }
	end
	sm:exec()
end

--Main
init()
func={
  [stream]=function (x) return x end,
}

selectmenu()
os.execute("rm /tmp/lua*.png");
