--[[
	chefkoch.de-App
	Vers.: 0.02
	Copyright (C) 2017-2020, bazi98

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

        Copyright (C) for the linked videos and the logo by chefkoch.de or the respective owners!
]]

local json = require "json"
local posix	= require "posix"

-- Auswahl
local subs = {
{'video/6,507,0', 'Krasse Kost'}, 
{'video/6,328,0', 'Rikes Backschule'},
{'video/6,327,0', 'Fabios Kochschule'},
{'video/6,329,0', 'Einfach lecker'}, 
--{'magazin/659', 'Lunchdate'},
{'video/6,531,0', 'How To: Küchenbasics'},
{'video/6,330,0', 'Hackn Roll'},
{'video/6,531,0', 'So gehts! '},
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
			local data  = getdata('http://www.chefkoch.de/' .. id .. '/Chefkoch',nil)
			if data then
 				for  item in data:gmatch('<article class.-</article>') do
					local link,title  = item:match('<a href="(.-html)" title="(.-)"') 
					seite = 'http://www.chefkoch.de' .. link
					if seite and title then
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
	local dx = 700;
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
	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title="Chefkoch.TV", icon="", has_shadow="true", show_header="true", show_footer="false"};  -- with out footer
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
     local m=menu.new{name="Chefkoch.TV", icon=""} -- only text

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
 	sm = menu.new{name="Chefkoch.TV", icon=""} -- only text
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
