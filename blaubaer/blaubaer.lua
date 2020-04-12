--[[
	Käpt'n Blaubär(light)
	Vers.: 0.2
	Copyright (C) 2020, bazi98

        App Description:
        The program evaluates Käpt'n Blaubär-Videos from the WDR mediathek and provides 
        videos for playing with the neutrino mediaplayer.

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

        Copyright (C) for the linked videos and for the Käpt'n Blaubär by WDR or the respective owners!
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

function add_stream(t,u,f,e,d,s)
  p[#p+1]={title=t,url=u,from=f,epg=e,description=d,sonst=s,access=stream}
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


-- UTF8 in Umlaute wandeln
function conv_str(_string)
	if _string == nil then return _string end
        _string = string.gsub(_string,'\\','');
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
	_string = string.gsub(_string,"&#8217;","'");
	_string = string.gsub(_string,"&#8211;",":");
	_string = string.gsub(_string,";","");
	_string = string.gsub(_string,"Lachgeschichte K","K");
	_string = string.gsub(_string,"Lachgeschichte: K","K");
	return _string
end

function url2_str(_string) -- anhand der Länge der Streamadresse die Url mit 960x540 px auswaehlen
	if _string == nil then return _string end
       _string = string.gsub(_string,'//wdradaptiv.-/i/medp/ondemand/weltweit/fsk0/%d+/%d+/,%d+_%d+,%d+_%d+,%.mp4%.csmil/','index_1_av.m3u8');
       _string = string.gsub(_string,'//wdradaptiv.-/i/medp/ondemand/weltweit/fsk0/%d+/%d+/,%d+_%d+,%d+_%d+,%d+_%d+,%d+_%d+,%d+_%d+,%.mp4%.csmil/','index_2_av.m3u8');
       _string = string.gsub(_string,'//wdradaptiv.-/i/medp/ondemand/weltweit/fsk0/%d+/%d+/%,%d+_%d+%,%d+_%d+%,%d+_%d+%,%d+_%d+%,%d+_%d+%,%d+_%d+%,%.mp4%.csmil/','index_2_av.m3u8');
       _string = string.gsub(_string,'//wdradaptiv.-/i/medp/ondemand/weltweit/fsk0/%d+/%d+/,%d+_%d+,%d+_%d+,%d+_%d+,%d+_%d+,%.mp4%.csmil/','index_2_av.m3u8');
 	return _string
end

function fill_playlist() 

--beginn of playlist
				add_stream("Die 3 Bärchen und der blöde Wolf", "http://deviceids-medp.wdr.de/ondemand/164/1643276.js", "http://deviceids-medp.wdr.de/ondemand/164/1643276.js")
	local data = getdata('https://www.wdrmaus.de/_export/videositemap.php5',nil) 
	if data then
		for  item in data:gmatch('<url>(.-)</url>')  do
			local title = item:match('<video:title><!%[CDATA%[(Käp.-)%]') -- Nur Sendunggen mit den Titel "Käpt'n Blaubär" anzeigen
			local seite = item:match('<video:player_loc allow_embed="No"><!%[CDATA%[(.-js)%]')
			if title then
				url = seite
				add_stream(conv_str(title), url, url)
			end
            end
	end
end -- of playlist


function set_pmid(id)
  pmid=tonumber(id);
  return MENU_RETURN["EXIT_ALL"];
end

function select_playitem()
  local m=menu.new{name="Käpt'n Blaubär", icon=""} -- only text

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
	local url_data = js_data:match('"videoURL":"(//.-)master.m3u8')
	blaubaer_url = "https:" .. url_data
	m3u8 = url2_str(url_data)

	local title = js_data:match('"trackerClipTitle":"(.-)",')
	if title == nil then
		title = p[pmid].title
	end

	if blaubaer_url then
              url = blaubaer_url .. m3u8
	vPlay:PlayFile("WDR",url,conv_str(title),url);
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
