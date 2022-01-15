--[[
	Bibel TV Mediathek
	Vers.: 0.2
	Copyright
        (C) 2021-22 bazi98 & SatBaby

        App Description:
        There the player links are respectively read about the recent news clips of the German Television "Bibel TV"
        from the Bibel TV library, displays and allows them to play with the neutrino-movie player.

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

        Copyright (C) for the linked videos and for the Bibel TV-Logo by Bibel TV or the respective owners!
        Copyright (C) for the Base64 encoder/decoder function by Alex Kloss <alexthkloss@web.de>, licensed under the terms of the LGPL

]]

local json = require "json"

-- Auswahl -
local subs = {
	{'Genre%3EHighlights', 'Highlights'},
	{'Genre%3ESerien', 'Serien'},
	{'Genre%3ESpielfilme', 'Spielfilme'},
	{'Genre%3ENeuste%20Videos', 'Neuste Videos'},
	{'Genre%3EDokumentationen', 'Dokumentationen'},
	{'Genre%3EDerzeit%20im%20Trend', 'Derzeit im Trend'},
	{'Genre%3EMagazin', 'Magazine'},
	{'Genre%3EMusik', 'Musik'}
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
	bibeltv = decodeImage("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAYAAADEtGw7AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAUeSURBVEhLhZRrbFRFFMfPzH3u3n10d/ukD2hZXo1IUUARFAxKVFKESAxRhA8EQ+IXP5hg4gdCTIz6RYgENAbTSIIJqY0JqGiCIU1IgUJK2lpoK33Qdlva3e7u3b3ve2ecrRvASNN/Mplkzp1f7jn/OQfBAnL1HJCp443IGzwMdob3pGdOE+GVXv/izbT4yROFi/u8oo6G7UzPe8T486Ct3jqgTd7d7+hpfzE8rxYGEwcbqbTiWhEum4rhzGjG7+oZvhieVwuCAWEG5z3ieNR1PKAeTxC3IBd4e+wccnP9tdQcfxGBPYj98S555VGnGC9wGRgDIS4gQoAiBJitx2WNt0lE691AiRvHYtllKbJkjHfU3hjy+j7D5FozkNAkdbwfrL+PnsX+tZPCol0uYJFdZSCPeUULwEIGBNx0DxC9T6D6XzUkc/4gmJ3vgjdbAvzSzz2t8WteHR2SEEnFBQmC/kg2hK1Lx4BObKfe9Pd23/7LoHWlCGUwyrGFKBBKpGgZJtMtNZSqr4LVewjZPesdE/HZSd5Flhr0y+Mcd+T9t4lrUmJmjDLHpBEkcDLHJeowmdgE1GgAe8K2VPtpjFOrbb1QjUh/pGLMA6f7A2TfPOyZI8tyKZlLjyqqkau+yiuN58M1GwZQtvccwlJUMSavr7GS13chL7FTDKTj/qiLRZ9oYhwaTo9RGQtenZZmVbDoeHUTdlhGtVrSkDMJkdha+V0sN7QpdZt+DtW/0Kc4CWPOBW3kKkvTxlayN2Ynu9ZTd/oAtQd3yGFT8cd81EiZwAf8yM65YKspGqgUQJ10kZZUVD689iIQviW8avct3hfKCMFKotSsL7jySKmbp0AIVPJW8nYVsZPbvPzgAUnu3+grD0hcqJbZnwcnOwhqAmxdbegQwo3fyWWrrzAzp8TwYi+6Zk+RNGf3/+UMHVOQM7Kc2PePgHfvTVSySqbgB8T5AAhr8dluC1DFH1iOf4FKXuvhK/epxasP9R+wM/qtSO2Bxdjr3w00+Q4FfYVlBqT8lIU4Ogli0AcEN4AUFkHgZhygeBTE+HlqaT+i0kP3hIo3jCLqX7CbaEVE669Azo1tiMvuQZB/2bZQMDfl4vw0STs5gwZLsyWEvV/bKJ9VKqJICgsROcyS4HUdPNJJobQV+bZeQpHmUb5klYvc2XYBae3PUv3KPoRzr1Mk1eYeaEL2vmE7Vribk6paBclYJ4vdzVrKpA59/mKoOnKDWOM7OE5/Ti4NyL6Iz0MkM81a/woWl5xi3XuN+2hvedTTb3+CcGKv7ZZWpO484DLD5gzl6luk2OqvlNqNv1FzuImjE+sc3aUeLGuPPvXWKWZYB6Bw0kwna528GuOUqgB1U3E7MZBwR4c7eUdDmBheUDMeSFombxJY3h5aufWElRrpCFSvU5W6l/BM4ldEWNFYUyNAFLGG0uVFW7tcdaIfSVW/O5k7h9V7QzsdfVomOYGXMQKeU+pnsah8aUN0yCeKQ0LplgtybOlE5ZaPCcA3YGUmMGU8Vt45MswNIA8CDc2Fk/zsjeMdUvnmfvBW/AK5mSYI8RcVQTQwwhwbNFInwr6jbJSdYe9pPFC/uXCpqMLwYRs7oYV9To8eU3TDh5QP1qWYjW2ID3yKBf8tzMteMTy/7PQIf/+nnScSrdXG0JmYMdCy++Rs19lwMTyvFhz0iBNYJQSeODYijoUosXn2R49l9GQtCMaC7HFKdRunrDwplTadDsW3twkldQ8b4ckC+AcQKJUELKe0WwAAAABJRU5ErkJggg==")
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

-- decode Unicode Character
function conv_str(_string)
	if _string == nil then return _string end
        _string = string.gsub(_string,'\\','');
	_string = string.gsub(_string,'u00c4','Ä');
	_string = string.gsub(_string,'u00e4','ä');
	_string = string.gsub(_string,'u00e0','à');
	_string = string.gsub(_string,'u00e2','â');
	_string = string.gsub(_string,'u00e5','å');
	_string = string.gsub(_string,'u0105','ą');
	_string = string.gsub(_string,'u00e1','á');
	_string = string.gsub(_string,'u00c1','Á');
	_string = string.gsub(_string,'u0200','ȁ');
	_string = string.gsub(_string,'u0107','ć');
	_string = string.gsub(_string,'u00e7','ç');
	_string = string.gsub(_string,'u00c9','É');
	_string = string.gsub(_string,'u0119','ę');
	_string = string.gsub(_string,'u00e6','æ');
	_string = string.gsub(_string,'u00e8','è');
	_string = string.gsub(_string,'u00e9','é');
	_string = string.gsub(_string,'u00ea','ê');
	_string = string.gsub(_string,'u00eb','ë');
	_string = string.gsub(_string,'u00ee','î');
	_string = string.gsub(_string,'u00ed','í');
	_string = string.gsub(_string,'u00ef','ï');
	_string = string.gsub(_string,'u00cd','i');
	_string = string.gsub(_string,'u00ec','Ì');
	_string = string.gsub(_string,'u00ce','Î');
	_string = string.gsub(_string,'u00f1','ñ');
	_string = string.gsub(_string,'u0144','ń');
	_string = string.gsub(_string,'u00d6','Ö');
	_string = string.gsub(_string,'u00f4','ô');
	_string = string.gsub(_string,'u00f3','ó');
	_string = string.gsub(_string,'u00d6','Ö');
	_string = string.gsub(_string,'u00f6','ö');
	_string = string.gsub(_string,'u0153','œ');
	_string = string.gsub(_string,'u0159','ř');
	_string = string.gsub(_string,'u015b','ś');
	_string = string.gsub(_string,'u00df','ß');
	_string = string.gsub(_string,'u00fa','ú');
	_string = string.gsub(_string,'u00dc','Ü');
	_string = string.gsub(_string,'u00fa','ú');
	_string = string.gsub(_string,'u00fb','û');
	_string = string.gsub(_string,'u00dc','ü');
	_string = string.gsub(_string,'u00fc','ü');
	_string = string.gsub(_string,'u016f','ů');
	_string = string.gsub(_string,'u017c','ż');
	_string = string.gsub(_string,'u2019','’');
	_string = string.gsub(_string,'u00e7','ç');
	_string = string.gsub(_string,'u015e','S');
	_string = string.gsub(_string,'u015f','ş');
	_string = string.gsub(_string,'u201e','„');
	_string = string.gsub(_string,'u201c','“');
	_string = string.gsub(_string,'u00d8','ø');
	_string = string.gsub(_string,'u00a0',' ');
	_string = string.gsub(_string,'u0142','ł');
	_string = string.gsub(_string,'u00b0','°');
	_string = string.gsub(_string,'u0302','̂ ');
	_string = string.gsub(_string,'u031e','̞');
	_string = string.gsub(_string,'u0301','́');
	_string = string.gsub(_string,'u201d','́');
	_string = string.gsub(_string,'u2018','‘');
	_string = string.gsub(_string,'u2013','–');
	_string = string.gsub(_string,'u2026','…');
	_string = string.gsub(_string,'u00bf','¿');
	_string = string.gsub(_string,'u00bb','»');
	_string = string.gsub(_string,'u00ab','«');
	_string = string.gsub(_string,'u00f8','ø');
	_string = string.gsub(_string,'u2026','…');
	_string = string.gsub(_string,'u00aa','ª');
	return _string
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
			local data  = getdata('http://bibeltv.c.nmdn.net/api/v1.0/media/video.json?appType=smarttv&catsFullName=' .. id .. '&pagerSize=99&pagerIndex=1&flavors=false&drm=false',nil)
			if data then
				for  item in data:gmatch('{(.-)}')  do
					local link,name = item:match('"id":(.-),"title":"(.-)",') 
					seite = 'http://bibeltv.c.nmdn.net/api/v1.0/media/video/' .. link .. '.json?appType=smarttv&flavors=true' 
					local subitle = item:match('"subtitle":"(.-)",') 
					if subitle == nil then
						title = conv_str(name)
					else
						title = subitle .. " : " .. conv_str(name)
					end
					if seite and title then
						add_stream( conv_str(title), seite, seite)
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
	local dx = 800;
	local dy = 500;
	local x = ((SCREEN['END_X'] - SCREEN['OFF_X']) - dx) / 2;
	local y = ((SCREEN['END_Y'] - SCREEN['OFF_Y']) - dy) / 2;

	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, icon="" , show_footer=false };
	local ct = ctext.new{parent=wh, x=35, y=5, dx=780, dy=490, text = epg , font_text=FONT['MENU'], mode = "ALIGN_SCROLL | ALIGN_TOP"};
        wh:setCaption{title="Bibel TV", alignment=TEXT_ALIGNMENT.CENTER};

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
  local m=menu.new{name="Bibel TV", icon=bibeltv}

  for i,r in  ipairs(p) do
    m:addItem{type="forwarder", action="set_pmid", id=i, icon="streaming", name=string.sub(r.title, 1, 60), hint=r.from, hint_icon="hint_reload"}
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
	local video_url = js_data:match('"url":"(.-)"')

	local epg1 = js_data:match('"descriptionLong":"(.-)"') 
	if epg1 == nil then
		epg1 = "Bibel TV stellt für diese Sendung keinen EPG-Text bereit."
	end
	local title = js_data:match('"title":"(.-)"')
	if title == nil then
		title = p[pmid].title
	end
	local subitle = js_data:match('"subtitle":"(.-)",') 
	if subitle == nil then
		title = conv_str(title)
	else
		title = subitle .. " : " .. conv_str(title)
	end

	local duration = js_data:match('"duration":(.-)%.')

	if video_url then 
		epg = conv_str(title) .. '\n\n' .. conv_str(epg1)  .. '\n\n' .. sec_to_min(duration)
		vPlay:setInfoFunc("epgInfo")
                url = conv_str(video_url) 
	vPlay:PlayFile("Bibel TV",url,conv_str(title));
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
	sm = menu.new{name="Bibel TV", icon=bibeltv}
	sm:addItem{type="separator"}
	sm:addItem{type="back"}
	sm:addItem{type="separatorline"}
	local d = 0 -- directkey
	for i,v in  ipairs(subs) do
		d = d + 1
		local dkey = godirectkey(d)
		sm:addItem{type="forwarder", name=v[2], action="fill_playlist",id=v[1], hint=v[2] .. ' aus der Bibel TV-Mediathek', directkey=dkey }
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
