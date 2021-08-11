--[[
	Bahnwelt TV-App
	Vers.: 0.2
	Copyright
        (C) 2020-2021 fritz

        App Description:
        There the player links are respectively read about the recent video clips of the German Website "bahnwelt-tv.de"
        from the Bahnwelt TV library, displays and allows them to play with the neutrino-movie player.

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

        Copyright (C) for the linked videos and for the Bahnwelt TV-Logo by Bahnwelt TV or the respective owners!
]]

local json = require "json"

-- Auswahl 
local subs = {
	{'bahnziele', 'Bahnziele'},
	{'bahntechnik', 'Bahntechnik'},
	{'bahnnostalgie', 'Bahnnostalgie'}
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
end

function add_stream(t,u,f)
  p[#p+1]={title=t,url=u,from=f,access=stream}
end

function getdata(Url,outputfile)
	if Url == nil then return nil end
	if Curl == nil then
		Curl = curl.new()
	end
--	local ret, data = Curl:download{url=Url,A="Mozilla/5.0;",followRedir=true,o=outputfile } -- only for testing
	local ret, data = Curl:download{url=Url,A="40tude_Dialog/2.0.8.1de",followRedir=true,o=outputfile } 
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
	_string = string.gsub(_string,'&amp;','&');
	_string = string.gsub(_string,'&quot;','"');
	_string = string.gsub(_string,'&#8222;','„');
	_string = string.gsub(_string,"&#039;","'");
	_string = string.gsub(_string,"&#x27;","'");
	_string = string.gsub(_string,"&#x60;","`");
	_string = string.gsub(_string,"<.->","");
	return _string
end

-- Titel bereinigen
function title_str(_string)
	if _string == nil then return _string end
	_string = string.gsub(_string,"<.->","");
	_string = string.gsub(_string,'&quot;','"');
	return _string
end

function fill_playlist(id) --- > begin playlist
	p = {}
	for i,v in  pairs(subs) do
		if v[1] == id then
			sm:hide()
			nameid = v[2]	
			local data  = getdata('https://www.bahnwelt-tv.de/' .. id .. '.html',nil) -- z.B.  https://www.bahnwelt-tv.de/bahnziele.html
			if data then
				for  item in data:gmatch('<a href="BW.-html" title.-/span>')  do -- </td></tr><tr>
					link,title,desciption = item:match('<a href="(BW.-html)".-title=".-">.-<img.-src="Resources/.-jpg".-<h2 class=".-">(.-)</h2>.-<span class=".-">(.-)</span>') 
					if link and title then
						add_stream( title_str(title), 'https://www.bahnwelt-tv.de/' .. link, conv_str(desciption) )
--						add_stream( title_str(title), 'https://www.bahnwelt-tv.de/' .. link, 'https://www.bahnwelt-tv.de/' .. link ) -- only for testing
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
	local dy = 450;
	local x = 0;
	local y = 0;

	local hw = n:getRenderWidth(FONT['MENU'],title) + 20
	if hw > 400 then
		dy = hw
	end
	if dy >  SCREEN.END_X - SCREEN.OFF_X - 20 then
		dy = SCREEN.END_X - SCREEN.OFF_X - 20
	end
	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title="Bahnwelt TV", icon="", has_shadow="true", show_header="true", show_footer="false"};  -- with out footer
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
  local m=menu.new{name="Bahnwelt TV", icon=""} -- only text

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

	local epg1 = p[pmid].from
	if epg1 == nil then
		epg1 = "Bahnwelt TV stellt für diese Sendung keinen EPG-Text bereit."
	end

	local js_data = getdata(url,nil) -- z.b. https://www.bahnwelt-tv.de/BW063.html
--	local title = js_data:match('<title>(.-)</title>') -- only for testing
	local url = js_data:match('<source src="(http.-mp4)"')

	if title == nil then
		title = p[pmid].title
	end

	if url then 
		epg = conv_str(p[pmid].title) .. '\n\n' .. conv_str(epg1)
		vPlay:setInfoFunc("epgInfo")
	vPlay:PlayFile("Bahnwelt TV",url,conv_str(p[pmid].title), url);
	else
		print("Video URL not found")
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
	sm = menu.new{name="Bahnwelt TV", icon=""}
	sm:addItem{type="separator"}
	sm:addItem{type="back"}
	sm:addItem{type="separatorline"}
	local d = 0 -- directkey
	for i,v in  ipairs(subs) do
		d = d + 1
		local dkey = godirectkey(d)
		sm:addItem{type="forwarder", name=v[2], action="fill_playlist",id=v[1], hint=v[2] .. '- Clips aus der Bahnwelt TV Mediathek', directkey=dkey }
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
