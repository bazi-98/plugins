--[[
	Anixe Mediathek
	Vers.: 0.2
	Copyright
        (C) 2021 bazi98

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

        Copyright (C) for the linked videos and for the Anixe TV-Logo by Anixe TV or the respective owners!
]]

-- Auswahl -
local subs = {
	{'0', (os.date("%A")) , (os.date ("%d.%m.%Y")) },
	{'1', (os.date("%A", os.time() - 3600*24)), (os.date("%d.%m.%Y", os.time() - 3600*24)) },
	{'2', (os.date("%A", os.time() - 3600*48)), (os.date("%d.%m.%Y", os.time() - 3600*48)) },
	{'3', (os.date("%A", os.time() - 3600*72)), (os.date("%d.%m.%Y", os.time() - 3600*72)) },
	{'4', (os.date("%A", os.time() - 3600*96)), (os.date("%d.%m.%Y", os.time() - 3600*96)) },
	{'5',(os.date("%A", os.time() - 3600*120)), (os.date("%d.%m.%Y", os.time() - 3600*120)) },
	{'6',(os.date("%A", os.time() - 3600*144)), (os.date("%d.%m.%Y", os.time() - 3600*144)) }
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

-- decode Unicode Character
function tounicode(c)
	if c > 8200 then
		return " "
	end

	if c > 383 then
		c=c-256
		return "\xC6" .. string.format('%c', c)
	elseif c > 319 then
		c=c-192
		return "\xC5" .. string.format('%c', c)
	elseif c > 254 then
		c=c-128
		return "\xC4" .. string.format('%c', c)
	elseif c > 191 then
		c=c-64
		return "\xC3" .. string.format('%c', c)
	else
		return string.format('%c', c)
	end
end

function convHTMLentities(summary)
	if summary ~= nil then
		summary = summary:gsub("&#([0-9]+);",function(c) return tounicode(tonumber(c)) end)
		summary = summary:gsub("&#x([%x]+);",function(c) return tounicode(tonumber(c, 16)) end)
	end
	return summary
end

local function unescape(s)
	s = s:gsub('\240[\144-\191][\128-\191][\128-\191]','')
	s = s:gsub('&nbsp;',	'\xA0')
	s = s:gsub('&iexcl;',	'\xA1')
	s = s:gsub('&cent;',	'\xA2')
	s = s:gsub('&pound;',	'\xA3')
	s = s:gsub('&curren;',	'\xA4')
	s = s:gsub('&yen;',		'\xA5')
	s = s:gsub('&brvbar;',	'\xA6')
	s = s:gsub('&sect;',	'\xA7')
	s = s:gsub('&uml;',		'\xA8')
	s = s:gsub('&copy;',	'\xA9')
	s = s:gsub('&ordf;',	'\xAA')
	s = s:gsub('&laquo;',	'\xAB')
	s = s:gsub('&not;',		'\xAC')
	s = s:gsub('&shy;',		'\xAD')
	s = s:gsub('&reg;',		'\xAE')
	s = s:gsub('&macr;',	'\xAF')
	s = s:gsub('&Acirc;',	'\xC2')
	s = s:gsub('&Atilde;',	'\xC3')
	s = s:gsub('&Auml;',	'\xC4')
	s = s:gsub('&Aring;',	'\xC5')
	s = s:gsub('&AElig;',	'\xC6')
	s = s:gsub('&Ccedil;',	'\xC7')
	s = s:gsub('&Egrave;',	'\xC8')
	s = s:gsub('&Eacute;',	'\xC9')
	s = s:gsub('&deg;',		'\xB0')
	s = s:gsub('&plusmn;',	'\xB1')
	s = s:gsub('&sup2;',	'\xB2')
	s = s:gsub('&sup3;',	'\xB3')
	s = s:gsub('&acute;',	'\xB4')
	s = s:gsub('&micro;',	'\xB5')
	s = s:gsub('&para;',	'\xB6')
	s = s:gsub('&cedil;',	'\xB8')
	s = s:gsub('&sup1;',	'\xB9')
	s = s:gsub('&ordm;',	'\xBA')
	s = s:gsub('&raquo;',	'\xBB')
	s = s:gsub('&frac14;',	'\xBC')
	s = s:gsub('&frac12;',	'\xBD')
	s = s:gsub('&frac34;',	'\xBE')
	s = s:gsub('&iquest;',	'\xBF')
	s = s:gsub('&acirc;',	'\xE2')
	s = s:gsub('&times;',	'\xD7')
	s = s:gsub('&divide;',	'\xF7')

	s = s:gsub('&lt;',		'<')
	s = s:gsub('&gt;',		'>')
	s = s:gsub('&amp;amp;',	'&') -- broken code
	s = s:gsub('&amp;',		'&')
	s = s:gsub('&quot;',	'"')

	s = s:gsub('&#776;', '\xCC\x88' )
	s = s:gsub('&#8232;',   '' )
	-- broken code --
	s = s:gsub('\xC3\xC3',		'\xC3')
	s = s:gsub('\x82\xC2',		'')
	s = s:gsub('\xC2\x80',		'')
	s = s:gsub('\xC3\x80',		'')
	s = s:gsub('\xC3\x82\xE2',	'"')
	s = s:gsub('\xC3\x82',		'')
	s = s:gsub('\xC3\x9E',		'')
	s = s:gsub('\xC3\x9C\x20',	' ')
	s = s:gsub('\xC3\x93\x20',	' ')
	return s
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

function fill_playlist(id)
	p = {}
	for i,v in  pairs(subs) do
		if v[1] == id then
			sm:hide()
			nameid = v[2]	
			local data  = getdata('http://hbbtv01p.anixe.net/pub/common/js/getmediathekdata.php?day=' .. id .. '&sd=anixehd',nil)
			if data then
				for  item in data:gmatch('<li class.-action(.-)</span></li>')  do
					local url, time, teaser, title = item:match("videourl='(http.-)'.-videolength='(.-)'.-showDetail%(%'(.-)%'%).-<span.-class.-title.->(.-)</span>") 
					if title then
						title = convHTMLentities(title)
						title = unescape(title)
						teaser = convHTMLentities(teaser)
						teaser = unescape(teaser)
						teaser = teaser:gsub('<a href=.-</a>','')
						add_stream( title, url, teaser, time)
					end
				end
			end
			select_playitem()
		end
	end
end

local epg = ""
local title = ""

function epgInfo (xres, yres, aspectRatio, framerate)
	local dx = 700;
	local dy = 500;
	local x = ((SCREEN['END_X'] - SCREEN['OFF_X']) - dx) / 2;
	local y = ((SCREEN['END_Y'] - SCREEN['OFF_Y']) - dy) / 2;

	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, icon="" , show_footer=false };
	local ct = ctext.new{parent=wh, x=35, y=5, dx=680, dy=490, text = epg , font_text=FONT['MENU'], mode = "ALIGN_SCROLL | ALIGN_TOP"};
        wh:setCaption{title="Anixe", alignment=TEXT_ALIGNMENT.CENTER};

	wh:paint()

	repeat
	msg, data = n:GetInput(500)
		if msg == RC.up or msg == RC.page_up then
			ct:scroll{dir="up"};
		elseif msg == RC.down or msg == RC.page_down then
			ct:scroll{dir="down"};
		end
		msg, data = n:GetInput(500)
	until msg == RC.ok or msg == RC.home or msg == RC.info ;
	wh:hide()
end

function set_pmid(id)
  pmid=tonumber(id);
  return MENU_RETURN["EXIT_ALL"];
end

function select_playitem()
  local m=menu.new{name="Anixe", icon=""}

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

	if title == nil then
		title = p[pmid].title
	end

	if (p[pmid].from == nil or p[pmid].from == '') then
		p[pmid].from = "Keine EPG-Information verfügbar"
	end

	if url then
		epg = p[pmid].title .. "\n\n"..p[pmid].from .. "\n\nDauer : ".. sec_to_min(p[pmid].length)

		vPlay:setInfoFunc("epgInfo")
--		vPlay:PlayFile("Anixe HD",url,p[pmid].title,url); -- only for testing with display url
		vPlay:PlayFile("Anixe HD",url,p[pmid].title); -- default
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
	sm = menu.new{name="Anixe-Mediathek", icon=""}
	sm:addItem{type="separator"}
	sm:addItem{type="back"}
	sm:addItem{type="separatorline"}
	local d = 0 -- directkey
	for i,v in  ipairs(subs) do
		d = d + 1
		local dkey = godirectkey(d)
		sm:addItem{type="forwarder", name=translate_weekday(v[2]), action="fill_playlist",id=v[1], hint='Mediathekinhalte für ' .. translate_weekday(v[2]) .. ', d. ' .. v[3], directkey=dkey }
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
