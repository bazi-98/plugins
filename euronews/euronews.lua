--[[
	euronews.de
	Vers.: 0.01
	Copyright (C) 2020, fritz

        Addon Description:
        The addon evaluates Videos from the german euronews website and 
        provides the videos for playing with the neutrino media player on.

        This addon is not endorsed, certified or otherwise approved in any 
        way by Euronews SA.

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

        Copyright (C) for the linked videos and the logo by Euronews SA or the respective owners!
        Copyright (C) for the Base64 encoder/decoder function by Alex Kloss <alexthkloss@web.de>, licensed under the terms of the LGPL
]]

local json = require "json"
local posix	= require "posix"

-- Auswahl
local subs = {
{'europe', 'Europa','Die aktuellsten Nachrichten zu Europa'}, 
{'news', 'Welt','Internationale Nachrichten und aktuelle Nachrichten'},
{'business', 'Wirtschaf','Nachrichten zum Weltwirtschafts- und Finanzmarkt'}, 
{'sport', 'Sport','Die aktuellsten Sportnachrichten und Ergebnisse'}, 
{'culture', 'Kultur','News zu Events – Ausstellungen, Konzerte, Künste'}, 
{'science_technology', 'Wissenschaft','News zu Wissenschaft, Innovationen und neue Technologie'}, 
{'travel', 'Reisen','Die aktuellsten Reiseinformationen und -berichte'} 
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
        euronews = decodeImage("data:image/png;base64,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")
end

-- Base64 encoder/decoder function
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- character table string

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

function add_stream(t,u,f)
  p[#p+1]={title=t,url=u,from=f,access=stream}
end

function getdata(Url,outputfile)
	if Url == nil then return nil end
	if Curl == nil then
		Curl = curl.new()
	end

	local ret, data = Curl:download{url=Url,A="Mozilla/5.0;",maxRedirs=5,followRedir=true,o=outputfile }
	if ret == CURL.OK then
		if outputfile then
			return 1
		end
		return data
	else
		return nil
	end
end

-- UTF8 in Umlaute wandeln
function conv_str(_string)
	if _string == nil then return _string end
        _string = string.gsub(_string,'\\','');
        _string = string.gsub(_string,'&amp;','&');
        _string = string.gsub(_string,'&quot;','"');
	_string = string.gsub(_string,"u00c4","Ä");
	_string = string.gsub(_string,"u00e4","ä");
	_string = string.gsub(_string,"u00ea","ê"); 
	_string = string.gsub(_string,"u00d6","Ö");
	_string = string.gsub(_string,"u00f6","ö");
	_string = string.gsub(_string,"u00dc","Ü");
	_string = string.gsub(_string,"u00fc","ü");
	_string = string.gsub(_string,"u00df","ß"); 
	_string = string.gsub(_string,"u2013","–");
	_string = string.gsub(_string,"u00b4","´");
	return _string
end

function fill_playlist(id) --- > begin playlist
	p = {}
	for i,v in  pairs(subs) do
		if v[1] == id then
			sm:hide()
			nameid = v[2]	
			local data  = getdata( 'https://de.euronews.com/rss?level=theme&name=' .. id ,nil) -- z-B. https://de.euronews.com/rss?level=theme&name=
			if data then
				for item in data:gmatch('<item>(.-)</item>')  do
					local title,seite = item:match('<title>(.-)</title>.-<guid>(http.-)</guid>') 
					if seite and title then
						add_stream( conv_str(title), seite, seite)
					end
				end
			end
			select_playitem()
		end
	end
end --- > end of playlist

local epg = ""
local title = ""

function epgInfo (xres, yres, aspectRatio, framerate)
	if #epg < 1 then return end
	local dx = 600;
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
	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title=" ", icon=euronews, has_shadow="true", show_header="true", show_footer="false"};  -- with out footer
	dy = dy + wh:headerHeight()

	local ct = ctext.new{parent=wh, x=20, y=0, dx=0, dy=dy, text = epg, font_text=FONT['MENU'], mode = "ALIGN_SCROLL | DECODE_HTML"};
 	h = ct:getLines() * n:FontHeight(FONT['MENU'])
	h = (ct:getLines() +4) * n:FontHeight(FONT['MENU'])
	if h > SCREEN.END_Y - SCREEN.OFF_Y -20 then
		h = SCREEN.END_Y - SCREEN.OFF_Y -20
	end
 	wh:setDimensionsAll(x,y,dx,h)
        ct:setDimensionsAll(20,0,dx-40,h)
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
--    local m=menu.new{name="euronews", icon=""} -- only text
      local m=menu.new{name=" ", icon=euronews} -- only icon

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
	local video_url = js_data:match('"contentUrl": "(http.-mp4)",')
	local title = js_data:match('"name": "(.-)",')
	local epg1 = js_data:match('"description": "(.-)",') 
	if epg1 == nil then
		epg1 = "euronews stellt für diese Sendung keinen Info-Text bereit."
	end

	if title == nil then
		title = p[pmid].title
	end


	if video_url then
		epg = p[pmid].title .. '\n\n' .. conv_str(epg1) 
		vPlay:setInfoFunc("epgInfo")
                url =  video_url -- z.B. https://video.euronews.com/mp4/med/EN/EU/BX/20/08/28/de/200828_EUBX_12996000_13001976_136000_171654_de.mp4
                vPlay:PlayFile("euronews",url,conv_str(p[pmid].title));
	else
		print("Video URL not found")
 		os.execute('msgbox icon=/usr/share/tuxbox/neutrino/icons/error.png title="Sorry:" size=26 timeout=60 popup="Das Video ist auf der euronews-Seite nicht mehr verfügbar, \nbitte einen anderen Beitrag auswählen"');
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
-- 	sm = menu.new{name="euronews", icon=""} -- only name
  	sm = menu.new{name=" ", icon=euronews} -- only icon
	sm:addItem{type="separator"}
	sm:addItem{type="back"}
	sm:addItem{type="separatorline"}
	local d = 0 -- directkey
	for i,v in  ipairs(subs) do
		d = d + 1
		local dkey = godirectkey(d)
		sm:addItem{type="forwarder", name=v[2], action="fill_playlist",id=v[1], hint=v[3], directkey=dkey }
	end
	sm:exec()
end

--Main
init()
func={
  [stream]=function (x) return x end,
}

selectmenu()
