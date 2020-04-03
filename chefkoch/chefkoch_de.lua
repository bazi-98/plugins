--[[
	chefkoch.de-Video-App
	Vers.: 0.04
	Copyright (C) 2017-2020, bazi98

        Addon Description:
        The addon evaluates Videos from the chefkoch.de Homepage and 
        provides the videos for playing with the neutrino media player on.

        This addon is not endorsed, certified or otherwise approved in any 
        way by Chefkoch GmbH.

        The plugin respects Chefkoch's General Terms and Conditions of Use, 
        which prohibits the publishing or making publicly available of any 
        software, app or similar which allows the livestream / videos to 
        be fully or partially definitely and permanently downloaded.

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

        Copyright (C) for the linked videos and the logo by Chefkoch GmbH or the respective owners!
        Copyright (C) for the Base64 encoder/decoder function by Alex Kloss <alexthkloss@web.de>, licensed under the terms of the LGPL
]]

local json = require "json"
local posix	= require "posix"

-- Auswahl
local subs = {
{'video/6,507,0', 'Krasse Kost'}, 
{'video/6,329,0', 'Einfach lecker'}, 
{'video/6,330,0', 'Hackn Roll'},
{'video/6,459,0', 'Frühlingsküche'}, 
{'video/6,472,0', 'Sommerküche'}, 
{'video/6,467,0', 'Herbstküche'}, 
{'video/6,452,0', 'Winterküche'}, 
{'video/6,462,0', 'Frühstück & Brunch'}, 
{'video/6,460,0', 'Backen'}, 
{'video/6,458,0', 'Desserts & Süßspeisen'}, 
{'video/6,461,0', 'Fingerfood & Snacks'}, 
{'video/6,466,0', 'Grillen'}, 
{'video/6,465,0', 'Salate'}, 
{'video/6,492,0', 'Deutsche Klassiker'}, 
{'video/6,455,0', 'Vegetarisch'}, 
{'video/6,454,0', 'Low Carb'}, 
{'video/6,463,0', 'Italienische Küche'}, 
{'video/6,464,0', 'Türkische Küche'}, 
{'video/6,456,0', 'Vegan'}, 
{'magazin/659', 'Lunchdate'},
{'video/6,328,0', 'Rikes Backschule'},
{'video/6,327,0', 'Fabios Kochschule'},
{'video/6,531,0', 'How To: Küchenbasics'},
{'video/6,531,0', 'So gehts!'},
{'video/6,371,0', 'Luisa lädt ein'},
{'video/6,331,0', 'Pimp my Fast Food'},
{'video/6,332,0', 'Chefkoch.tv Classics'}
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
        chefkoch = decodeImage("data:image/png;base64,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")
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
	_string = string.gsub(_string,"| Chefkoch.de Video","");
	_string = string.gsub(_string,"&#038;","&");
	_string = string.gsub(_string,"&uuml;","ü");
	_string = string.gsub(_string,"&auml;","ä");
	_string = string.gsub(_string,"&ouml;","ö");
	_string = string.gsub(_string,"&szlig;","ß");
	_string = string.gsub(_string,"&amp;","&");
	_string = string.gsub(_string,"&nbsp;"," ");
	_string = string.gsub(_string,"&quot;","'");
	_string = string.gsub(_string,"&gt;",".");
	_string = string.gsub(_string,"&#039;","´");
	_string = string.gsub(_string,"<.->","");
        _string = string.gsub(_string,'\\','');
	return _string
end

function fill_playlist(id) --- > begin playlist
	p = {}
	for i,v in  pairs(subs) do
		if v[1] == id then
			sm:hide()
			nameid = v[2]	
			local data  = getdata('http://www.chefkoch.de/' .. id .. '/Chefkoch',nil) -- z.B. http://www.chefkoch.de/magazin/6,146,0/Chefkoch
			if data then
 				for  item in data:gmatch('<article% class.-</article>') do
					local link,title  = item:match('<a href="(.-)".-title="(.-)"') 
					seite = 'http://www.chefkoch.de' .. link
					local icon  = item:match('image button.-(icon)"') -- nur Beiträge mit Icon haben auch Videos
					if seite and title and icon then
						add_stream( conv_str(title), seite, conv_str(title))
					end
				end
			else
				return nil
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
	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title=" ", icon=chefkoch, has_shadow="true", show_header="true", show_footer="false"};  -- with out footer
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
     local m=menu.new{name=" ", icon=chefkoch} -- only text

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
	local video_url = js_data:match('"og:video:url" content="(http.-mp4)" />')
	local title = js_data:match('<div class="teaser%-box__content">.-<h2>(.-)</h2>')
	local epg1 = js_data:match('<p class="leadtext">(.-)</div>') 
	if epg1 == nil then
		epg1 = "Chefkoch.TV stellt für diese Sendung keinen Info-Text bereit."
	end

	if title == nil then
		title = p[pmid].title
	end


	if video_url then
		epg = conv_str(title) .. '\n\n' .. conv_str(epg1) 
		vPlay:setInfoFunc("epgInfo")
                url =  video_url -- z.B. http://video.chefkoch-cdn.de/ck.de/videos/106-video.mp4
                vPlay:PlayFile("Chefkoch.TV",url,conv_str(title), url);
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
 	sm = menu.new{name=" ", icon=chefkoch} -- only text
	sm:addItem{type="separator"}
	sm:addItem{type="back"}
	sm:addItem{type="separatorline"}
	local d = 0 -- directkey
	for i,v in  ipairs(subs) do
		d = d + 1
		local dkey = godirectkey(d)
		sm:addItem{type="forwarder", name=v[2], action="fill_playlist",id=v[1], hint='Rubrik : '.. v[2], directkey=dkey }
	end
	sm:exec()
end

--Main
init()
func={
  [stream]=function (x) return x end,
}

selectmenu()
