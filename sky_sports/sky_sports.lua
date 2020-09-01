--[[
	Sky Sports News
	Vers.: 0.5
	Copyright (C) 2017, bazi98 & SatBaby
	Copyright (C) 2017-2020, bazi98

        App Description:
        There the player links are respectively read about the recent news clips of the British Television "Sky Sports News"
        from the UK Sky Sports library, displays and allows them to play with the neutrino-movie player.

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

        Copyright (C) for fBase64 encoder/decoder function by Alex Kloss,<alexthkloss@web.de> licensed under the terms of the LGPL2
        Copyright (C) for the linked videos and for the Sky Sports-Logos by Sky or the respective owners!
]]

local json = require "json"

	home_url       = "http://www.skysports.com/"
	base_url       = "http://www.skysports.com/watch/" -- default
--	base_url       = "http://uk-sport-web.cf.sky.com"  -- only for testing
	player_url     = "https://player.ooyala.com/hls/player/all/"

-- Range
-- with the removal of the "--" the selection is activated
local subs = {
	{'video', 'Featured'},
	{'video/sports/football', 'Football'},
	{'video/sports/cricket', 'Cricket'},
	{'video/sports/darts', 'Darts'},
	{'video/sports/rugby-union', 'Rugby-Union'},
	{'video/sports/rugby-league', 'Rugby-League'},
	{'video/sports/snooker', 'Snooker'},
	{'video/sports/gaa', 'Gaelic Games'},
--	{'video/sports/nfl', 'NFL'},
--	{'video/sports/golf', 'Golf'},
--	{'video/sports/tennis', 'Tennis'},
--	{'video/sports/boxing', 'Boxing'},
--	{'video/sports/basketball', 'Basketball'},
--	{'video/sports/equestrian', 'Equestrian'},
--	{'video/sports/wwe', 'WWE'},
--	{'video/sports/olympics', 'Olympics'},
--	{'video/sports/sailing','Sailing'},
--	{'video/sports/ufc', 'UFC'},
--	{'video/sports/netball', 'Netball'},
--	{'video/sports/racing', 'Racing'},
--	{'video/sports/f1', 'Formel 1'}
}

-- Quality level in which the program is to be displayed
qual = "3600.m3u8"
--  300.m3u8 --> 320x180 & bandwidth="507000" ( DSL < 1000 )
--  600.m3u8 --> 640x360 & bandwidth="859000" ( DSL < 1000 )
--  900.m3u8 --> 640x360 & bandwidth="1239000" ( DSL < 1000 )
--  1500.m3u8 --> 1280x720 & bandwidth="1900000" ( DSL > 1500 )
--  2200.m3u8 --> 1280x720 & bandwidth="2697000" ( DSL > 3000 )
--  3600.m3u8 --> 1920x1080 & bandwidth="4272000" ( DSL > 6000 )
--  7830.m3u8 --> 1920x1080 & bandwidth="9054000" ( DSL > 12000 )



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
	sky_sport = decodeImage("data:image/png;base64,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")
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

-- function Base64 encoder/decoder

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

-- convert html
function conv_str(_string)
	if _string == nil then return _string end
	_string = string.gsub(_string,"&amp;","&");
	_string = string.gsub(_string,"&quot;","'");
	_string = string.gsub(_string,"&#039;","'");
	_string = string.gsub(_string,"&#x27;","'");
	_string = string.gsub(_string,"&#8211;","–");
	_string = string.gsub(_string,"&#8212;","—");
	_string = string.gsub(_string,"&#8216;","‘");
	_string = string.gsub(_string,"&#8217;","’");
	_string = string.gsub(_string,"&#8230;","…");
	_string = string.gsub(_string,'&#8243;','″');
	_string = string.gsub(_string,"&#233;","é");
	return _string
end

function fill_playlist(id)
	p = {}
	for i,v in  pairs(subs) do
		if v[1] == id then
			sm:hide()
			nameid = v[2]	
			local data  = getdata( base_url .. id ,nil)
			if data then
				for  item in data:gmatch('<div class="polaris%-tile__media%-wrap">(.-)</a>')  do
					local name,link = item:match('alt="(.-)".-<a href="(/watch.-)" class') 
					seite = home_url .. link 
					title = nameid .. ': ' .. name
					if seite and title then
						add_stream( conv_str(name), seite, conv_str(title))
					end
				end
			end
			select_playitem()
		end
	end
end

-- epg-display function
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
	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title=" ", icon=sky_sport, has_shadow="true", show_header="true", show_footer="false"};  -- with out footer
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
--local m=menu.new{name="Sky Sports", icon=""} -- only text
  local m=menu.new{name="", icon=sky_sport}    -- only icon,default

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
	local video_url = js_data:match('id%="sdc%-article%-video%-(.-)"')
	local epg1 = js_data:match('<p class="sp%-player__summary">(.-)</p>') 
	if epg1 == nil then
		epg1 = "Sky Sports does not provide an EPG text for this broadcast."
	end
	local title = js_data:match('<title>(.-)|')

	local duration_h,duration_m,duration_s = js_data:match('duration%"%:%"PT(.-)H(.-)M(.-)S"') -- e.g. "duration":"PT0H1M48S"

	if duration_h == nil then
		duration_h = "00"
	end
	if duration_m == nil then
		duration_m = "00"
	end
	if duration_s == nil then
		duration_s = "00"
	end

	if title == nil then
		title = p[pmid].title
	end

	if video_url then
		epg = conv_str(title) .. '\n\n' .. conv_str(epg1) .. '\n\nDuration: ' ..  duration_m .. ":" .. duration_s
		vPlay:setInfoFunc("epgInfo")
                url = player_url .. video_url ..'/media/' .. qual
	vPlay:PlayFile("Sky Sports",url,conv_str(title));
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
	sm = menu.new{name="", icon=sky_sport }
	sm:addItem{type="separator"}
	sm:addItem{type="back"}
	sm:addItem{type="separatorline"}
	local d = 0 -- directkey
	for i,v in  ipairs(subs) do
		d = d + 1
		local dkey = godirectkey(d)
		sm:addItem{type="forwarder", name=v[2], action="fill_playlist",id=v[1], hint=v[2] .. '-Clips from Sky Sports', directkey=dkey }
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
