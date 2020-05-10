--[[
	Pokémon TV(light)
	Vers.: 0.2

	Copyright (C) 2020, fritz
	Copyright (C) 2009 - for the Base64 encoder/decoder function by Alex Kloss

        Addon Description:
        The addon evaluates free Videos from the "The Pokémon Company International"
        Website and provides the videos for playing with the neutrino media player on.

        This addon is not endorsed, certified or otherwise approved in any
        way by "The Pokémon Company International".

        The plugin respects The Pokémon Company's General Terms and Conditions of Use,
        which prohibits the publishing or making publicly available of any software,
        app or similar which allows the livestream / videos to be fully or partially
        definitely and permanently downloaded.

        The copyright (C) for the linked videos, descriptive texts and for the logo
        are owned by "The Pokémon Company International" or the respective owners!

	License: GPL
	This program is free software; you can redistribute it and/or modify it under
        the terms of the GNU General Public License as published by the Free Software
        Foundation; either version 2 of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY 
        WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
        PARTICULAR PURPOSE.  

        See the GNU General Public License for more details. You should have received a 
        copy of the GNU General Public License along with this program; if not, write to the
	Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301, USA.
]]


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
        pokemon_tv = decodeImage("data:image/png;base64,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")
end

function add_stream(t,u,f)
  p[#p+1]={title=t,url=u,from=f,access=stream}
end

function getdata(Url,outputfile)
	if Url == nil then return nil end
	if Curl == nil then
		Curl = curl.new()
	end
	local ret, data = Curl:download{url=Url,A="40tude_Dialog/2.0.8.1de",followRedir=true,o=outputfile }

	if ret == CURL.OK then
		return data
	else
		return nil
	end
end

-- datestring in Umlaute wandeln
function date_str(_string)
	if _string == nil then return _string end
	_string = string.gsub(_string,"ganze Sendung","Sendung");
	return _string
end

-- UTF8 in Umlaute wandeln
function conv_str(_string)
	if _string == nil then return _string end
        _string = string.gsub(_string,'\\n',' ');
	_string = string.gsub(_string,"&Auml;","Ä");
	_string = string.gsub(_string,"&auml;","ä");
	_string = string.gsub(_string,"&Ouml;","Ö");
	_string = string.gsub(_string,"&ouml;","ö");
	_string = string.gsub(_string,"&Uuml;","Ü");
	_string = string.gsub(_string,"&uuml;","ü");
	_string = string.gsub(_string,"&szlig;","ß");
	_string = string.gsub(_string,"&egrave;","è");
	_string = string.gsub(_string,"&eacute;","é");
	_string = string.gsub(_string,"&amp;","&");
	_string = string.gsub(_string,"&ndash;","-");
	_string = string.gsub(_string,"&lt;","<");
	_string = string.gsub(_string,"&gt;",">");
	_string = string.gsub(_string,"&quot;","");
	_string = string.gsub(_string,"&apos;","'");
	_string = string.gsub(_string,"&#x00c4","Ä");
	_string = string.gsub(_string,"&#x00e4","ä");
	_string = string.gsub(_string,"&#x00d6","Ö");
	_string = string.gsub(_string,"&#x00f6","ö");
	_string = string.gsub(_string,"&#x00dc","Ü");
	_string = string.gsub(_string,"&#x00fc","ü");
	_string = string.gsub(_string,"&#x00df","ß"); 
	_string = string.gsub(_string,"u00df","ß"); 
	_string = string.gsub(_string,"&#039","'");
	_string = string.gsub(_string,"&#261","ą");
	_string = string.gsub(_string,";","");
	_string = string.gsub(_string,"<.->","");
	return _string
end

-- Base64 encoder/decoder function
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

-- Duration
function sec_to_min(_string)
	local seconds = tonumber(_string/1000) -- the Api therefore provides the time in msec / 1000
		if seconds <= 0 then
		return "00:00:00";
	else
		hours = string.format("%02.f", math.floor(seconds/3600));
		mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
--		return mins..":"..secs  -- Min:Sec
		return hours..":"..mins..":"..secs -- Sdt:Min:Sec
--		return "ca. " ..mins.. " Min. " -- only minutes are displayed
	end
end

function fill_playlist() 
	local data = getdata('https://www.pokemon.com/api/pokemontv/v2/channels/de/',nil) -- for Films with German as sound option = default
--	local data = getdata('https://www.pokemon.com/api/pokemontv/v2/channels/fr/',nil) -- for Films with French as sound option
--	local data = getdata('https://www.pokemon.com/api/pokemontv/v2/channels/uk/',nil) -- for Films with English as sound option
	if data then
		for  item in data:gmatch('{"rating(.-)m3u8"')  do
			local title = item:match('"title":"(.-)",') -- Program title
			local description = item:match('"description":"(.-)",') -- Consignment description
			local url = item:match('"id":"(.-)",') -- Link
			if title then
				add_stream(title,"https://production-ps.lvp.llnw.net/r/PlaylistService/media/" .. url .."/getMobilePlaylistByMediaId",conv_str(description) )
			end
            end
	end
end

-- epg-Fenster
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
--	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title="Pokémon TV", icon="", has_shadow="true", show_header="true", show_footer="false"};  -- with out footer
	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title="", icon=pokemon_tv, has_shadow="true", show_header="true", show_footer="false"};  -- with out footer
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
	until msg == RC.ok or msg == RC.home
	wh:hide()
end

function set_pmid(id)
  pmid=tonumber(id);
  return MENU_RETURN["EXIT_ALL"];
end

function select_playitem()
--local m=menu.new{name="Pokémon TV", icon=""} -- only text
  local m=menu.new{name="", icon=pokemon_tv} -- only logo

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

	local data = getdata(url,nil)
	local url  =  data:match('"HttpLiveStreaming%"%,%"mobileUrl%"%:%"(http.-m3u8)"')
	local duration  =  data:match('"durationInMilliseconds":(.-),')
	if title == nil then
		title = p[pmid].title
	end

	if url then
		epg = p[pmid].title .. "\n\n" .. conv_str(p[pmid].from) .. "\n\n Dauer: " .. sec_to_min(duration)
		vPlay:setInfoFunc("epgInfo")
		vPlay:PlayFile("Pokémon TV",url,p[pmid].title);
	else
		print("Video URL not  found")
	end

   end
  until false
end


--Main
init()
func={
  [stream]=function (x) return x end,
}
fill_playlist()
select_playitem()
os.execute("rm /tmp/lua*.png");
