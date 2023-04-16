--[[
	Welt-Mediathek
	Vers.: 0.1
	Copyright
        (C) 2023  fritz

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

-- Auswahl
local subs = {
	{'https://www.welt.de/mediathek/reportage/automobile/', 'Automobile'},
	{'https://www.welt.de/mediathek/dokumentation/gesellschaft', 'Gesellschaft'},
	{'https://www.welt.de/mediathek/dokumentation/history', 'History'},
	{'https://www.welt.de/mediathek/magazin/', 'Magazin'},
	{'https://www.welt.de/mediathek/dokumentation/natur-und-wildlife', 'Natur und Wildlife'},
	{'https://www.welt.de/mediathek/dokumentation/space/', 'Space'},
	{'https://www.welt.de/mediathek/dokumentation/katastrophen/', 'Katastrophen'},
	{'https://www.welt.de/mediathek/dokumentation/technik-und-wissen', 'Technik und Wissen'}
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
	welt = decodeImage(" data:image/png;base64,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")
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
				for  item in data:gmatch('Topic">(.-href.-)</li>')  do
					local link,title = item:match('<a href="(/mediathek/.-html)".-title="(.-)" class') 
					seite = 'https://www.welt.de' .. link 
					duration = item:match('videoDuration">(.-)</span>')
					if duration == nil then
						duration = "unbekannt"
					end

					if seite and title then
						add_stream( conv_str(title), seite, 'Dauer: ' ..duration) -- default
--						add_stream( conv_str(title), seite, seite) -- only for testing
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
	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title=" ", icon=welt, has_shadow="true", show_header="true", show_footer="false"};  -- with out footer
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
--local m=menu.new{name="Welt", icon=""} -- only text
  local m=menu.new{name="", icon=welt} -- only icon

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
	video_url = js_data:match('"sources":.-m3u8.-{"src":"(https://weltn24lfthumb.-mp4)"') 
	if video_url == nil then
	   video_url = js_data:match('"sources":.-{"src":"(https://weltn24lfthumb.-mp4)"') 
	end
	if video_url == nil then
	   video_url = js_data:match('"sources":.-{"src":"(https://vod.-mp4)"') 
	end
	if video_url == nil then
		print("Video URL not  found")
 		os.execute('msgbox icon=/usr/share/tuxbox/neutrino/icons/info.png title="WELT" size=26 timeout=60 popup="Die Sendung ist aus rechtlichen Gründen online nicht verfügbar"');
	end

	local epg1 = js_data:match('"description" data%-qa="Intro">.-<p>(.-)</p>') 
	if epg1 == nil then
		epg1 = "Welt stellt für diese Sendung keinen EPG-Text bereit."
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
	        vPlay:PlayFile("Welt",url,conv_str(title), duration);
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
	sm = menu.new{name="", icon=welt}
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
