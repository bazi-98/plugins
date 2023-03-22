--[[
	WDR:Rockpalast
	Vers.: 1.03

	Copyright (C): 
        2016: bazi98 & SatBaby
        2017 - 2023  bazi98

        App Description:
        The program evaluates Rockpalst-Videos from the WDR mediathek and provides 
        videos for playing with the neutrino mediaplayer.

	License: GPL 2

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

        Copyright (C) for the linked videos and for the Rockpalast-Logo by WDR or the respective owners!
        Copyright (C) for the Base64 encoder/decoder function by Alex Kloss <alexthkloss@web.de>, licensed under the terms of the LGPL

        Evaluation planned for the future:
        https://api.ardmediathek.de/page-gateway/widgets/ard/asset/Y3JpZDovL3dkci5kZS9Sb2NrcGFsYXN0?pageNumber=0&pageSize=99
]]

local json = require "json"

-- Auswahl 
local subs = {
--	{'uebersicht-events-102', 'Test'}, -- testing stuff, default is disabled
	{'rockpalast-index-startseite-100', 'aktuell'},
	{'rockpalast-100', '2021/22'},
	{'rockpalast266', '2020'},
	{'rockpalast264', '2019'},
	{'rockpalast-156', '2018'},
	{'rockpalast-136', '2017'},
	{'rockpalast-106', '2016'},
	{'rockpalast-108', '2015'},
	{'rockpalast-110', '2014'},
	{'rockpalast-112', '2013'},
	{'rockpalast-114', '2012'},
	{'rockpalast-116', '2011'},
	{'rockpalast-118', '2010'},
	{'rockpalast-120', '2009'},
	{'rockpalast-122', '2008'},
	{'rockpalast-124', '2007'},
	{'rockpalast-126', '2006'},
	{'rockpalast-128', '2005'},
	{'rockpalast-132', '2004'}
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
	rockpalast = decodeImage("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAFEAAAAeCAYAAABUgfKPAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABBdEVYdENvbW1lbnQAQ1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcgSlBFRyB2NjIpLCBxdWFsaXR5ID0gOTUKzTKs1gAAABh0RVh0U29mdHdhcmUAcGFpbnQubmV0IDQuMS4xYyqcSwAABOJJREFUaEPtmL2LnFUUxtfdfKBg5wfRIpBVrLRTwUIMUSwFG/UfsJEYCwtF/4KkESytbESw86M1YCGCCApBUBsxEbEQVEIkfsz4e06ee/e83zs7k8mK+4PLPc9zzj333TvvzLyzG5n5fH6Tw5XS13fMy3Oum81mRxnbeHPmJ20Hua6PqfyirLrfyigXxgE9TDxKLDhgBw7tpM+mAf6HLtEBB3jnmQ7Z/n/DYZy+diw74D3idAXvLafFJmN/vo2mWOWFx1Ek7G1G0qAPey48zuhcA15dl/N9tWuhbMzcSxQtgdsUbrPdgZzutgp34mcOF4a1P7ptL5Ss/rCvbR1s2QrsiT1vqsUOR4ldeuBA3mMcJxz9PCR/mLp7YhHYXg9sfHRs07iiJQ6R/tuMU5aDeJ9bGEvdJcuu3zNx+WBZwdLzmmh8di0CB3jBPa7rH6f+2oT9fra1XnQBbP6PLsLEoeG9LhFFe4TlW8v0YOmuD39sn0X6ZNSTc7jbcnHc4JLlnnGf+y2XglaDh6F9IG4A5pXc+WrItc8sx9HmWiBYc7vDpe7CgvrQ81nLDqT1TrjPMpDnsMNQTvs4HGWsd0Z16ilsTaNi/pifYhXYboAdF6C5jEgM4Br1PW1dH5zLTO5R1cAW8TOOA+ULtiq2K32eoOcXjK8sO5CL3+UQTyfo44xjjLvs6/rPMh5k3BmLhnD9Ec8NXKINXiyaOL7ZJyiH+I3WhGOkBTk9wlTQ+jl4SLFLtO75lg4sg6wJ4+6Wl3G6gVNBW/cRi4bIBYTlbgmKp5iLO9/SX0sL4viCYt62VXskGncnc30xYoHJOpLz+SuMeufLcBhkrTpper9mvUl8WR7EMydz1Ajrdr/S44ri4kVyCC1wWJEHuivqhlAfytngJRmWUY/3gGVg7xyTetQXJ5Kmrak/lT3F0P6ZONiD9U+08yJ7hOWQbrZWfFZ+FIC9q5bTaIHDQFpYloaNbyqscrh6+9yhwKmKPHLlM1F1V9t1WatGmroLthr5gjzovTMjA5YV27GG/m9IRALQFyMLtqIe/2/LaWJ166JocKtl0WcsK/I1k3u3xBl55OIQhfXTloE8h8GUFmM1ioVlJXuKuY53LCvtGmE5TS6m+QftxdL4T1lWSh2590uckUfuVcfx8G06b297v0pD711WaHtZs1/cVZaV7A3kyzurgdP9kB98O3Ahn1sG9q5YVuR7PlHijDzWvWwpXT8CbNUeQjH1zynPeExa4L3tkkCewyBrwrJH53MU8kF1ftLab+DUNLm4xFz4d4ozUWDIz7KnGOtex/UuwzunWMi3d5lxSbFwrvEvMUHNt4wvFUcDsxvNuj8sA3kQ+0uT/0sx80PW9eevtMNG3w6uqcijUXn4zJzI9dT84rCxAf4LtlXzu0PFH7lEPfRH6D82AblPNTud94j//hDGA3qYJtcJat902IHcn6oXtgr1Rc5Q/wlT+4mkQv7jaDYFtfEYw1zfcoXotMMR2w2c04a/ef7eqQp25+0sL/ttnK+PWEV7bsCeFxlnFLtcL/JJxg9YcUi2g6KzT6wXsAz9ojrm1HrRRWlYNig+c74Te2sLOT9Vu2rWvd9CcHH1EPczuzrEG3XSfYfYvpYbdW1i7XvvZUPW/CfuxH3NwSGugINDXAE6RNj1x8AitdeHjY1/AZ7yLCcfRYj8AAAAAElFTkSuQmCC")
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

-- UTF8 in Umlaute wandeln
function conv_str(_string)
	if _string == nil then return _string end
	_string = string.gsub(_string,"&amp;","&");
	_string = string.gsub(_string,"&quot;","'");
	_string = string.gsub(_string,"&#039;","'");
	_string = string.gsub(_string,"&#x27;","'");
	_string = string.gsub(_string,"&#x60;","`");
	_string = string.gsub(_string,"Klicke dich hier durch die Sendung","Der WDR stellt für diese Rockpalastsendung keinen Infotext bereit.");
	return _string
end

function fill_playlist(id) --- > begin playlist
	p = {}
	for i,v in  pairs(subs) do
		if v[1] == id then
			sm:hide()
			nameid = v[2]	
			local data  = getdata('https://www1.wdr.de/mediathek/video/sendungen/rockpalast/' .. id .. '.feed',nil)
			if data then
				for  item in data:gmatch('<entry>(.-)</entry>')  do
					local title,seite,summary = item:match('<title>(.-)</title>.-<link.-href="(http.-html)".-<summary>(.-)</summary>') 
					title = conv_str(title)
					if seite and title then
--						add_stream( string.sub(title, 1, 60), seite, summary) -- only for test, shorten to a maximum of 60 characters
						add_stream( title, seite, summary)
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
	local dy = 300;
	local x = 0;
	local y = 0;

	local hw = n:getRenderWidth(FONT['MENU'],title) + 20
	if hw > 400 then
		dy = hw
	end
	if dy >  SCREEN.END_X - SCREEN.OFF_X - 20 then
		dy = SCREEN.END_X - SCREEN.OFF_X - 20
	end
	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title="WDR: Rockpalast", icon="", has_shadow=true, show_footer=false};
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
--  local m=menu.new{name="WDR: Rockpalast", icon=""} -- only text
    local m=menu.new{name="", icon=rockpalast} -- only icon

  for i,r in  ipairs(p) do
    m:addItem{type="forwarder", action="set_pmid", id=i, icon="streaming", name=r.title, hint=conv_str(r.from), hint_icon="hint_reload"}
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
	local js_url = js_data:match('mediaObj.-url":"(http://deviceids.-/ondemand/.-js)"')

	if js_url == "http://deviceids-medp.wdr.de/ondemand/43/433961.js" then
		js_url = "http://deviceids-medp.wdr.de/ondemand/28/285432.js"
	end
	js_data = getdata(js_url,nil)
	video_url1 = js_data:match('mediaResource.-{"videoURL":"(//.-%m3u8)"') 

	if video_url1 == nil then
		video_url1 = "//wdrfsgeo-lh.akamaihd.net/i/wdrfs_geogeblockt@530016/master.m3u8" -- default wdr-livestreamadress
	end

	video_url2 = getdata("http:"..video_url1,nil)
	video_url = video_url2:match('RESOLUTION=1280.-(http.-m3u8)')
	if video_url == nil then
		video_url = video_url2:match('RESOLUTION=960.-(http.-m3u8)')
	end
	if video_url == nil then
		video_url = video_url2:match('RESOLUTION=512.-(http.-m3u8)')
	end

	local epg1 = js_data:match('<meta name="twitter:description" content="(.-)">') 
	if epg1 == nil then
		epg1 = p[pmid].from
	end

	local titel = js_data:match('trackerClipTitle":"(.-)",')
	if title == nil then
		title = p[pmid].title
	end

	if video_url then 
		epg = conv_str(p[pmid].title) .. '\n\n' .. conv_str(epg1) 
		vPlay:setInfoFunc("epgInfo")
	        vPlay:PlayFile("WDR Rockpalast",video_url ,conv_str(titel) );
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
	sm = menu.new{name=" ", icon=rockpalast}
	sm:addItem{type="separator"}
	sm:addItem{type="back"}
	sm:addItem{type="separatorline"}
	local d = 0 -- directkey
	for i,v in  ipairs(subs) do
		d = d + 1
		local dkey = godirectkey(d)
		sm:addItem{type="forwarder", name=v[2], action="fill_playlist",id=v[1], hint="Sendungen des Jahres  " .. v[2], directkey=dkey }
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
