--[[
	RAI Südtirol-Mediathek(light)
	Vers.: 0.1
	Copyright (C) 2021, bazi98
        with many hints and code snippets from SatBaby, big thanks from my to him

        App Description:
        The program evaluates broadcasts from the Rai Südtirol-Mediathek and provides videos for 
        playing with the neutrino mediaplayer.

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

        Copyright (C) for the linked videos and for the Rai Südtirol-Logo by Rai Südtirol or the respective owners!
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
end

function add_stream(t,u,f,d,s)
  p[#p+1]={title=t,url=u,from=f,date=d,access=stream}
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


-- decode html code to real symbols 
function conv_str(_string)
	if _string == nil then return _string end
	_string = string.gsub(_string,"u00c4","Ä");
	_string = string.gsub(_string,"u00e4","ä");
	_string = string.gsub(_string,"u00d6","Ö");
	_string = string.gsub(_string,"u00f6","ö");
	_string = string.gsub(_string,"u00dc","Ü");
	_string = string.gsub(_string,"u00fc","ü");
	_string = string.gsub(_string,"u00df","ß"); 
	_string = string.gsub(_string,"u00df","ß"); 
	_string = string.gsub(_string,"u00f9","ù"); 
	_string = string.gsub(_string,"u00f2","ò"); 
	_string = string.gsub(_string,"u00e0","à"); 
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
	_string = string.gsub(_string,'u201e','„');
	_string = string.gsub(_string,'u201c','“');
	_string = string.gsub(_string,'u00d8','ø');
	_string = string.gsub(_string,"u2013","-"); 
	_string = string.gsub(_string,"u2019",","); 
	_string = string.gsub(_string,"u039","'");
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
	_string = string.gsub(_string,'u00bf',''); -- ¿
	_string = string.gsub(_string,'u00bb','»');
	_string = string.gsub(_string,'u00ab','«');
	_string = string.gsub(_string,'u00f8','ø');
	_string = string.gsub(_string,'u2026','…');
	_string = string.gsub(_string,'u00aa','ª');
	_string = string.gsub(_string,";","");
        _string = string.gsub(_string,'\\r','');
        _string = string.gsub(_string,'\\n',' ');
        _string = string.gsub(_string,'\\','');
	return _string
end

function fill_playlist() 

        local data = getdata('http://raisudtirol.rai.it/lib/data_mediateca.php?&titolo=&dt=&teca=T&tipo=tv&lang=de',nil) -- begrenzt auf die letzte Tagesschau und Tagesschau 10 nach 10
	if data then
		local url1,title1,datum1,url2,title2,datum2 = data:match('"id":"(.-mp4)","titolo":"(.-)","data":"(.-)",.-"id":"(.-mp4)","titolo":"(.-)","data":"(.-)",')
			datum1 = datum1:gsub("-",".")
			datum2 = datum2:gsub("-",".")
			if (title1 == "Tagesschau 10 nach 10") then
				description1 = "Spätnachrichten "
			else
				description1 = "Nachrichten "
			end
			if (title2 == "Tagesschau 10 nach 10") then
				description2 = "Spätnachrichten "
			else
				description2 = "Nachrichten "
			end

			if url1 and title1 and url2 and title2 then
					add_stream(title1,"http://www.raibz.rai.it/streaming/" .. url1,description1 .. "aus Südtirol und der Welt","Sendung vom " .. datum1)
					add_stream(title2,"http://www.raibz.rai.it/streaming/" .. url2,description2 .. "aus Südtirol und der Welt","Sendung vom " .. datum2)
			end
	end

	local data = getdata('http://raisudtirol.rai.it/lib/data_mediateca.php?&titolo=&dt=&teca=P&tipo=tv&lang=de',nil) -- restl. Sendungen
	if data then
		for  item in data:gmatch('{"id(.-)feedlink".-}')  do
			id,title,description,datum = item:match('":"(.-mp4)","titolo":"(.-)","testo":"(.-),"data":"(.-)"') -- url1,Sendungstitel,Beschreibung,Sendedatum
			url = "http://www.raibz.rai.it/streaming/" .. id -- URL komplett
			if (description == nil or description == '') then
				description = "Keine EPG-Information verfügbar"
			end
			datum = datum:gsub("-",".")
			if url and title then
				add_stream(conv_str(title), url, conv_str(description),"Sendung vom " .. datum)
			end
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
	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title="RAI Südtirol", icon="", has_shadow="true", show_header="true", show_footer="false"};  -- with out footer
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
  local m=menu.new{name="Rai Südtirol-Mediathek", icon=""} -- only text

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

	if title == nil then
		title = p[pmid].title
	end

	if (p[pmid].from == nil or p[pmid].from == '') then
		p[pmid].from = "Keine EPG-Information verfügbar"
	end

	if url then
		epg = p[pmid].title .. "\n\n"..p[pmid].from .. "\n\n"..p[pmid].date
		vPlay:setInfoFunc("epgInfo")
		vPlay:PlayFile("RAI Südtirol",url,p[pmid].title,url);
	else
		print("Video URL not found")
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
