--[[
	Sky Sport News
	Vers.: 0.8
	Copyright
        (C) 2017 bazi98 & SatBaby
        (C) 2017 - 2020  bazi98

        App Description:
        There the player links are respectively read about the recent news clips of the German Television "Sky Sport News"
        from the Sky Sport library, displays and allows them to play with the neutrino-movie player.

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
        Copyright (C) for the linked videos and for the Sky Sport-Logo by Sky Deutschland Fernsehen GmbH & Co. KG or the respective owners!
]]

-- local json = require "json"

  base = "https://sport.sky.de" -- default
--base = "http://de-sport-web.cf.sky.com" -- only for test
  player_base = "https://player.ooyala.com/player/all/" 

-- Auswahl
local subs = {
	{'/videos', 'Top Videos'},
	{'/videos/bundesliga', '1.Bundesliga'},
	{'/videos/bundesliga-2', '2.Bundesliga'},
	{'/videos/dfb-pokal', 'DFB-Pokal'},
	{'/videos/uefa-champions-league', 'Champions League'},
	{'/uefa-europa-league-videos', 'uefa Europa League'},
	{'/videos/premier-league', 'Premier League'},
--	{'/oesterreichische-bundesliga-videos', 'Östr. Bundesliga'},
--	{'/austria-erste-liga-videos', 'Austria 1. Liga'},
	{'/fussball/videos', 'Fußball (Übersicht)'},
	{'/formel1/videos', 'Formel 1'},
	{'/handball/videos', 'Handball'},
	{'/handball/dkb-bundesliga/videos', 'DKB-Bundesliga'},
	{'/handball/velux-ehf-champions-league/videos', 'EHF Champions League'},
	{'/golf/videos', 'Golf'},
	{'/tennis/videos', 'Tennis'}
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

-- Quality level in which the program is to be displayed
qual = "_4200.m3u8"
--  _4200.m3u8 --> 1920x1080 & bandwidth="4200000" ( DSL > 6000 )
--  _3600.m3u8 --> 1920x1080 & bandwidth="3600000" ( DSL > 2000 )
--  _1500.m3u8 --> 1920x1080 & bandwidth="1500000" ( DSL < 2000 )


-- function base64 to file
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

-- function html to utf8 convert
function conv_str(_string)
	if _string == nil then return _string end
	_string = string.gsub(_string,"&amp;","&");
	_string = string.gsub(_string,"&quot;","'");
	_string = string.gsub(_string,"&#039;","'");
	_string = string.gsub(_string,"&#x27;","'");
	_string = string.gsub(_string,"&#x60;","`");
	_string = string.gsub(_string,' %– die Highlights im Video','');
	_string = string.gsub(_string,' %– die Highlights im VIDEO','');
	_string = string.gsub(_string,'die Highlights im Video','Highlights');
	_string = string.gsub(_string,'die Highlights im VIDEO','Highlights');
	_string = string.gsub(_string,"%: komplette Sendung","");
	return _string
end

function fill_playlist(id)
	p = {}
	for i,v in  pairs(subs) do
		if v[1] == id then
			sm:hide()
			nameid = v[2]	
			local data  = getdata( base .. id ,nil)
			if data then
				for  item in data:gmatch('<h3 class="sdc%-site%-tile__headline">(.-)</a>')  do 
					local link,name = item:match('<a href="(.-)" class="sdc%-site%-tile__headline%-link" >.-<span class="sdc%-site%-tile__headline%-text">(.-)</span>') 
					seite = base .. link
					title = conv_str(name)
					if seite and title then
--						add_stream( conv_str(title), seite, nameid .. ': ' .. seite) -- for Test only
						add_stream( conv_str(title), seite, nameid .. ' : ' .. conv_str(title))
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
	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title=title, icon=sky_sport, has_shadow="true", show_header="true", show_footer="false"};  -- with out footer
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
--local m=menu.new{name="Sky Sport News", icon=""} -- only text
  local m=menu.new{name="", icon=sky_sport}        -- only icon, default

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
	local video_url = js_data:match('<div class="sdc%-article%-video__media%-ooyala.-id="sdc%-article%-video%-(.-)" data') -- id="sdc-article-video-

	local epg1 = js_data:match('<meta% name%=%"description"% content%=%"(.-)">') 
	if epg1 == nil then
		epg1 = "Sky Sport stellt für diese Sendung keinen EPG-Text bereit."
	end
	local title = js_data:match('meta name="twitter:title" content="(.-)">')

	if title == nil then
		title = p[pmid].title
	end

	if video_url then 
		epg = conv_str(title) .. '\n\n' .. conv_str(epg1) 
		vPlay:setInfoFunc("epgInfo")
                url = player_base .. video_url .. qual
--              url = 'https://videossportskyde.akamaized.net/' .. video_url ..'/1/dash/1.mpd' -- only for tests with dash
	vPlay:PlayFile("Sky Sport.de",url,conv_str(title));
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
	sm = menu.new{name="", icon=sky_sport}
	sm:addItem{type="separator"}
	sm:addItem{type="back"}
	sm:addItem{type="separatorline"}
	local d = 0 -- directkey
	for i,v in  ipairs(subs) do
		d = d + 1
		local dkey = godirectkey(d)
		sm:addItem{type="forwarder", name=v[2], action="fill_playlist",id=v[1], hint=v[2] .. '- Clips aus der Sky Sport News Redaktion', directkey=dkey }
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
