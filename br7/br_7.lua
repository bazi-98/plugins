--[[
	BR Mediathek
	Vers.: 0.4
	Copyright
        (C) 2021-23 bazi98

	License: 

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

        Copyright (C) for the linked videos and for the BR Mediathek-Logo by BR or the respective owners!
]]

-- Auswahl -> e.g. http://hbbtv-mediathek.br.de/programme/2022-04-08T05:00:00.000Z

local subs = {
{(os.date ("%Y-%m-%d")) , (os.date("%A")) , (os.date ("%d.%m.%Y")) },
{(os.date("%Y-%m-%d", os.time() - 3600*24)) , (os.date("%A", os.time() - 3600*24)), (os.date("%d.%m.%Y", os.time() - 3600*24)) },
{(os.date("%Y-%m-%d", os.time() - 3600*48)) , (os.date("%A", os.time() - 3600*48)), (os.date("%d.%m.%Y", os.time() - 3600*48)) },
{(os.date("%Y-%m-%d", os.time() - 3600*72)) , (os.date("%A", os.time() - 3600*72)), (os.date("%d.%m.%Y", os.time() - 3600*72)) },
{(os.date("%Y-%m-%d", os.time() - 3600*96)) , (os.date("%A", os.time() - 3600*96)), (os.date("%d.%m.%Y", os.time() - 3600*96)) },
{(os.date("%Y-%m-%d", os.time() - 3600*120)) ,(os.date("%A", os.time() - 3600*120)), (os.date("%d.%m.%Y", os.time() - 3600*120)) },
{(os.date("%Y-%m-%d", os.time() - 3600*144)) ,(os.date("%A", os.time() - 3600*144)), (os.date("%d.%m.%Y", os.time() - 3600*144)) }
}

function translate_weekday(_string)
	if _string == nil then return _string end
		_string = string.gsub(_string,'Monday','Montag');
		_string = string.gsub(_string,'Tuesday','Dienstag');
		_string = string.gsub(_string,'Wednesday','Mittwoch');
		_string = string.gsub(_string,'Thursday','Donnerstag');
		_string = string.gsub(_string,'Friday','Freitag');
		_string = string.gsub(_string,'Saturday','Samstag');
		_string = string.gsub(_string,'Sunday','Sonntag');
	return _string
end 
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

function add_stream(t,u,f,l)
  p[#p+1]={title=t,url=u,from=f,length=l,access=stream}
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


-- Duration
function sec_to_min(_string)
	local seconds = tonumber(_string) -- json therefore returns time in msec
		if seconds <= 0 then
		return "00:00:00";
	else
		hours = string.format("%02.f", math.floor(seconds/3600));
		mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
--		return hours..":"..mins..":"..secs -- hours, minutes and seconds are displayed
		return " " ..mins.. " Min." -- only minutes are displayed, default
	end
end

function conv_str(_string)
	if _string == nil then return _string end
	_string = string.gsub(_string,'\\n',' ');
	_string = string.gsub(_string,'\\','');
	_string = string.gsub(_string,"&Auml;","Ä");
	_string = string.gsub(_string,"&auml;","ä");
	_string = string.gsub(_string,"&#xE4;","ä");
	_string = string.gsub(_string,"&#xD6;","Ö");
	_string = string.gsub(_string,"&#xF6;","ö");
	_string = string.gsub(_string,"&Ouml;","Ö");
	_string = string.gsub(_string,"&ouml;","ö");
	_string = string.gsub(_string,"&Uuml;","Ü");
	_string = string.gsub(_string,"&uuml;","ü");
	_string = string.gsub(_string,"&#xFC;","ü");
	_string = string.gsub(_string,"&szlig;","ß");
	_string = string.gsub(_string,"&egrave;","è");
	_string = string.gsub(_string,"&eacute;","é");
	_string = string.gsub(_string,"&#xE7;","ç ");
	_string = string.gsub(_string,"&#xE9;","é");
	_string = string.gsub(_string,"&#xEB;","ë");
	_string = string.gsub(_string,"&#xEF;","ï");
	_string = string.gsub(_string,"&amp;","&");
	_string = string.gsub(_string,"&ndash;","-");
	_string = string.gsub(_string,"&lt;","<");
	_string = string.gsub(_string,"&gt;",">");
	_string = string.gsub(_string,"&quot;",'"');
	_string = string.gsub(_string,"&apos;","'");
	_string = string.gsub(_string,'&oacute;','ó');
	_string = string.gsub(_string,'&#039;',"'");
	return _string
end

function conv_position(_string)
	if _string == nil then return _string end
	_string = string.gsub(_string,'BR24.-Uhr',"news");
	_string = string.gsub(_string,'BR24.-%d%d%:%d%d',"news");
	return _string
end

function fill_playlist(id)
	p = {}
	for i,v in  pairs(subs) do
		if v[1] == id then
			sm:hide()
			nameid = v[2]	
			local data  = getdata('http://hbbtv-mediathek.br.de/programme/' .. id .. 'T05:00:00.000Z',nil)
			if data then
				for  item in data:gmatch('{.-video.-}')  do
					local url, description1, title1, duration,vid = item:match('/av:(.-)","titletxt":"(.-)",.-"teasertxt":"(.-)".-"techinfo"%:"(.-min)".-"isvid":(.-),') 
                                        url = "http://hbbtv-mediathek.br.de/video/av:" .. url -- e.g -> http://hbbtv-mediathek.br.de/video/av:6213919043ca8800093e78b6
 					if title1 == "Die ganze Sendung" or conv_position(description1) == "news" then
                                                title = description1
                                                description = title1
                                         else
						title = title1
                                                description = description1
                                         end    

 					if url and (description ~= "Tagesschau") and (vid ~= "false") then
						add_stream( conv_str(title), url, conv_str(description), duration ) -- default
--						add_stream( title, url, url, duration ) -- only for testing
					end
				end
			end
			select_playitem()
		end
	end
end

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
	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title="BR-Mediathek", icon="", has_shadow="true", show_header="true", show_footer="false"};  -- with out footer
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
  local m=menu.new{name="BR-Mediathek", icon=""}

  for i,r in  ipairs(p) do
    m:addItem{type="forwarder", action="set_pmid", id=i, icon="streaming", name=string.sub(r.title, 1, 60), hint=r.from, hint_icon="hint_reload"}  -- default
--  m:addItem{type="forwarder", action="set_pmid", id=i, icon="streaming", name=string.sub(r.title, 1, 60), hint=r.title, hint_icon="hint_reload"} -- only for testing with display title in the hint areal
--  m:addItem{type="forwarder", action="set_pmid", id=i, icon="streaming", name=string.sub(r.title, 1, 60), hint=r.url, hint_icon="hint_reload"}   -- only for testing with display url in the hint areal 
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

	local js_data = getdata(url,nil) --> z.B. http://hbbtv-mediathek.br.de/video/av:62711e134ffb1b0008facd2f
	local url = js_data:match('"url":"(http.-mp4)",')
	local description = js_data:match('"detailtxt":"(.-)","isvid')

	if (description == nil or description == '') then
		description = js_data:match('"titletxt":"(.-)",')
	end

	if (description == nil or description == '') then
		description = conv_str(p[pmid].from)
	end

	if title == nil then
		title = conv_str(p[pmid].title)
	end

	if url then
		epg = p[pmid].title .. "\n\n".. conv_str(description)
		vPlay:setInfoFunc("epgInfo")
--		vPlay:PlayFile("BR HD",url,p[pmid].title,url); -- only for testing with display url
		vPlay:PlayFile("BR Mediathek",url,p[pmid].title,p[pmid].from); -- default
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
	sm = menu.new{name="BR-Mediathek", icon=""}
	sm:addItem{type="separator"}
	sm:addItem{type="back"}
	sm:addItem{type="separatorline"}
	local d = 0 -- directkey
	for i,v in  ipairs(subs) do
		d = d + 1
		local dkey = godirectkey(d)
		sm:addItem{type="forwarder", name=translate_weekday(v[2]), action="fill_playlist",id=v[1], hint='BR-Mediathekinhalte für ' .. translate_weekday(v[2]) .. ', d. ' .. v[3], directkey=dkey }
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
