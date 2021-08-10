--[[
	arte 7
	Vers.: 2.0.0 vom 10.08.2021
	Copyright (C) 2016-2021, bazi98
        With many references and codessniplets of SatBaby and micha-bbg, great thank you from me to them.

        App Description:
        The addon evaluates Videos from the arte 7 media library and 
        provides the videos for playing with the neutrino media player on.

        This addon is not endorsed, certified or otherwise approved in any 
        way by ARTE GEIE.

        The plugin respects arte's General Terms and Conditions of Use, 
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

        Copyright (C) for the linked videos and for the arte-Logo by arte or the respective owners!
        Copyright (C) for the Base64 encoder/decoder function by Alex Kloss <alexthkloss@web.de>, licensed under the terms of the LGPL
]]

local json  = require "json"

basisurl= "http://www.arte.tv"

--[[
    sprachversion / version linguistique
    Mit der Auswahl der Sprachoptionen wird die Sprache des Video und der Texte festgelegt.
    Avec le choix des options de langue langue de la vidéo et le texte du message est défini.

    langue = "de" -- > deutsch
    langue = "fr" -- > français
]]

langue = "de" -- normal = "de"

--[[
     Mit der Option "Qualität" wird festgelegt mit welcher Auflösung die Videos angezeigt werden sollen.
     Avec l'est défini « qual » à quelle résolution les vidéos à afficher.
]]

qual = 1 -- normal = "1"

-- 1 = HD  für / pour DSL >= 6000
-- 2 = MD  für / pour DSL >= 2000
-- 3 = SD  für / pour DSL <= 2000

-- Auswahlmenue / menu de sélection
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
		if langue == "de" then
				_string = string.gsub(_string,'Monday','Montag');
				_string = string.gsub(_string,'Tuesday','Dienstag');
				_string = string.gsub(_string,'Wednesday','Mittwoch');
				_string = string.gsub(_string,'Thursday','Donnerstag');
				_string = string.gsub(_string,'Friday','Freitag');
				_string = string.gsub(_string,'Saturday','Samstag');
				_string = string.gsub(_string,'Sunday','Sonntag');
		else        
				_string = string.gsub(_string,'Monday','lundi');
				_string = string.gsub(_string,'Tuesday','mardi');
				_string = string.gsub(_string,'Wednesday','mercredi');
				_string = string.gsub(_string,'Thursday','jeudi');
				_string = string.gsub(_string,'Friday','vendredi');
				_string = string.gsub(_string,'Saturday','samedi');
				_string = string.gsub(_string,'Sunday','dimanche');
		end
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
        arte_7 = decodeImage(" data:image/png;base64,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")
end

function add_stream(t,u,e)
  p[#p+1]={title=t,url=u,epg=e,access=stream}
end

function getdata(Url,outputfile)
	if Url == nil then return nil end
	if Curl == nil then
		Curl = curl.new()
	end
	local ret, data = Curl:download{url=Url,A="Mozilla/5.0 (Linux mips; U;HbbTV/1.1.1 (+RTSP;DMM;Dreambox;0.1a;1.0;) CE-HTML/1.0; en) AppleWebKit/535.19 no/Volksbox QtWebkit/2.2",followRedir=true,o=outputfile }
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

-- url-string umwandeln / convertir
function conv_url(_string)
	if _string == nil then return _string end
       _string = string.gsub(_string,'\\','');
		if qual < 2 then -- = HD
				_string = string.gsub(_string,'master.m3u8','index_1_av.m3u8');
		elseif qual > 2 then -- = qual = 3 = SD
				_string = string.gsub(_string,'master.m3u8','index_2_av.m3u8');
				_string = string.gsub(_string,'2200_','800_');
		else  -- = qual = 2 = MD
				_string = string.gsub(_string,'master.m3u8','index_0_av.m3u8');
				_string = string.gsub(_string,'2200_','1500_');
		end				
 	return _string
end

-- Umlaute umwandeln / convertir trémas
function uml_str(_string)
	if _string == nil then return _string end
        _string = string.gsub(_string,'\\','');
	_string = string.gsub(_string,'"','');
	_string = string.gsub(_string,'#039;','’');
	_string = string.gsub(_string,'u00e4','ä');
	_string = string.gsub(_string,'u00e0','à');
	_string = string.gsub(_string,'u00e2','â');
	_string = string.gsub(_string,'u00e5','å');
	_string = string.gsub(_string,'u0105','ą');
	_string = string.gsub(_string,'u00e1','á');
	_string = string.gsub(_string,'u00c4','Ä');
	_string = string.gsub(_string,'u00c0','À');
	_string = string.gsub(_string,'u00c1','Á');
	_string = string.gsub(_string,'u0200','ȁ');
	_string = string.gsub(_string,'u00c7','Ç');
	_string = string.gsub(_string,'u0107','ć');
	_string = string.gsub(_string,'u00e7','ç');
	_string = string.gsub(_string,'u00c9','É');
	_string = string.gsub(_string,'u0119','ę');
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
	_string = string.gsub(_string,'u00f4','ô');
	_string = string.gsub(_string,'u00f3','ó');
	_string = string.gsub(_string,'u00d6','Ö');
	_string = string.gsub(_string,'u00f6','ö');
	_string = string.gsub(_string,'u0153','œ');
	_string = string.gsub(_string,'u0159','ř');
	_string = string.gsub(_string,'u015b','ś');
	_string = string.gsub(_string,'u00df','ß');
	_string = string.gsub(_string,'u00fa','ú');
	_string = string.gsub(_string,'u00fa','ú');
	_string = string.gsub(_string,'u00fb','û');
	_string = string.gsub(_string,'u00dc','ü');
	_string = string.gsub(_string,'u00fc','ü');
	_string = string.gsub(_string,'u016f','ů');
	_string = string.gsub(_string,'u017c','ż');
	_string = string.gsub(_string,'u2019','’');
	_string = string.gsub(_string,'u00e7','ç');
	_string = string.gsub(_string,'lt;','');
	_string = string.gsub(_string,'amp;','+');
	_string = string.gsub(_string,'quot;','"');
	_string = string.gsub(_string,'gt;','');
	_string = string.gsub(_string,'br /','');
	_string = string.gsub(_string,'&','');
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
	_string = string.gsub(_string,'u02026','…');
	_string = string.gsub(_string,'u00bb','»');
	_string = string.gsub(_string,'u00ab','«');
	_string = string.gsub(_string,'u00f8','ø');
	_string = string.gsub(_string,'u2026','…');
	_string = string.gsub(_string,'u00aa','ª');
	return _string
end 

function fill_playlist(id)
	p = {}
	for i,v in  pairs(subs) do
		if v[1] == id then
			sm:hide()
			nameid = v[2]	
			local data  = getdata('http://www.arte.tv/hbbtv-mw/api/1/epg/' .. id .. '?authorizedAreas=ALL,DE_FR,EUR_DE_FR,SAT&lang=' .. langue ,nil)
			if data then
				for  item in data:gmatch('"id"(.-)"geoblocking"')  do
					title, subtitle, seite, description, code, label = item:match('"title":.-"(.-)", "subtitle":(.-),.-"program_id":.-"(.-)",.-"description":.-"(.-)",.-"code": "(FULL_VIDEO)",.-"playable":.-(true),.-"video_url"') 
					if subtitle == " null" or subtitle == nil then
						title = title
					else
						title = title .. " - " .. subtitle
					end
					if title and label == "true" and code == "FULL_VIDEO" then -- Restriction necessary due to exclusion of snippets or only live videos  
						add_stream( uml_str(title), seite , uml_str(description) ) 
					end
				end
			end
			select_playitem()
		end
	end

end

function set_pmid(id)
  pmid=tonumber(id);
  return MENU_RETURN["EXIT_ALL"];
end

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
	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title=title, icon="", has_shadow=true, show_footer=false};
	dy = dy + wh:headerHeight()

	local ct = ctext.new{parent=wh, x=20, y=0, dx=0, dy=dy, text = epg, font_text=FONT['MENU'], mode = "ALIGN_SCROLL | DECODE_HTML"};
 	h = ct:getLines() * n:FontHeight(FONT['MENU'])
	h = (ct:getLines() +4) * n:FontHeight(FONT['MENU'])
	if h > SCREEN.END_Y - SCREEN.OFF_Y -20 then
		h = SCREEN.END_Y - SCREEN.OFF_Y -20
	end
 	wh:setDimensionsAll(x,y,dx,h)
	ct:setDimensionsAll(20,0,dx,h)
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

function select_playitem()
  local m=menu.new{name=" ", icon=arte_7}
  for i,r in  ipairs(p) do
    m:addItem{type="forwarder", action="set_pmid", id=i, icon="streaming", name=r.title, hint=r.epg, hint_icon="hint_reload"}
  end

  repeat
    pmid=0
    m:exec()

    if pmid==0 then
      return
    end

    local vPlay = nil
    local seite=func[p[pmid].access](p[pmid].url)
    if seite~=nil then
      if  vPlay  ==  nil  then
	vPlay  =  video.new()
      end

	if seite then
		local js_seite = getdata('https://api.arte.tv/api/player/v1/config/'.. langue .. '/'.. seite .. '?lifeCycle=1',nil) -- apicall
                if js_seite ~= nil then
			local jnTab = json:decode(js_seite)
			local video_url = nil
			if jnTab.videoJsonPlayer.VSR and jnTab.videoJsonPlayer.VSR.HLS_XQ_1 then 
				video_url = jnTab.videoJsonPlayer.VSR.HLS_XQ_1.url
			elseif jnTab.videoJsonPlayer.VSR and jnTab.videoJsonPlayer.VSR.HTTP_MP4_SQ_1 then
				video_url = jnTab.videoJsonPlayer.VSR.HTTP_MP4_SQ_1.url
			elseif jnTab.videoJsonPlayer.VSR and jnTab.videoJsonPlayer.VSR.HTTP_SQ_1 then
				video_url = jnTab.videoJsonPlayer.VSR.HTTP_SQ_1.url
			elseif jnTab.videoJsonPlayer.VSR and jnTab.videoJsonPlayer.VSR.HLS_SQ_1 then
				video_url = jnTab.videoJsonPlayer.VSR.HLS_SQ_1.url
			elseif jnTab.videoJsonPlayer.VSR and jnTab.videoJsonPlayer.VSR.RTMP_SQ_1 then
				video_url = jnTab.videoJsonPlayer.VSR.RTMP_SQ_1.streamer .. jnTab.videoJsonPlayer.VSR.RTMP_SQ_1.url
			end

			if jnTab.videoJsonPlayer.VTI then
				title = jnTab.videoJsonPlayer.VTI
			else
				title = p[pmid].title 
			end

			if jnTab.videoJsonPlayer.subtitle then
				subtitle = jnTab.videoJsonPlayer.subtitle
			else
				subtitle = " "
			end

				local videoplayed = false
				if title and video_url then
					if jnTab.videoJsonPlayer.VDE then
						    epg = jnTab.videoJsonPlayer.VDE 
                                                    if langue == "fr" then
						         epg = subtitle .. '\n\n' .. epg .. '\n\nTemps de lecture (mn.) : ' .. jnTab.videoJsonPlayer.VDU 
						    elseif langue == "de" then
						         epg = subtitle .. '\n\n' .. epg .. '\n\nSpieldauer (Min.) : ' .. jnTab.videoJsonPlayer.VDU
                                                    end
						vPlay:setInfoFunc("epgInfo")

 					elseif jnTab.videoJsonPlayer.V7T then
						    epg = jnTab.videoJsonPlayer.V7T 
                                                    if langue == "fr" then
						         epg = subtitle .. '\n\n' .. epg .. '\n\nTemps de lecture (mn.) : ' .. jnTab.videoJsonPlayer.VDU 
						    elseif langue == "de" then
						         epg = subtitle .. '\n\n' .. epg .. '\n\nSpieldauer (Min.) : ' .. jnTab.videoJsonPlayer.VDU
                                                    end
						vPlay:setInfoFunc("epgInfo")
 					else
						    epg = p[pmid].epg 
                                                    if langue == "fr" then
						         epg = subtitle .. '\n\n' .. epg .. '\n\nTemps de lecture (mn.) : ' .. jnTab.videoJsonPlayer.VDU 
						    elseif langue == "de" then
						         epg = subtitle .. '\n\n' .. epg .. '\n\nSpieldauer (Min.) : ' .. jnTab.videoJsonPlayer.VDU
                                                    end
						vPlay:setInfoFunc("epgInfo")
					end
					videoplayed = true
					vPlay:PlayFile ("arte HD", conv_url(video_url), uml_str(title) ,uml_str(subtitle));
				end

				if videoplayed == false then
					local infotext = ""
					local t = os.time()
					if jnTab.videoJsonPlayer.custom_msg and jnTab.videoJsonPlayer.custom_msg.type == "error" then
						infotext = jnTab.videoJsonPlayer.custom_msg.msg
					elseif datetotime(jnTab.videoJsonPlayer.VRA) > t or t > datetotime(jnTab.videoJsonPlayer.VRU) then
						local d1,m1,y1,h1,M1,s1 = jnTab.videoJsonPlayer.VRA:match("(%d+).(%d+).(%d+) (%d+):(%d+):(%d+)")
						local d2,m2,y2,h2,M2,s2 = jnTab.videoJsonPlayer.VRU:match("(%d+).(%d+).(%d+) (%d+):(%d+):(%d+)") 
                                                    if langue == "fr" then
						         infotext = "La vidéo est seulement " .. d1 .. "." ..  m1 .. "." ..  y1 .. " - " .. h1 .. ":" ..  M1 .. " heures à " .. d2 .. "." ..  m2 .. "." ..  y2 .. " - " .. h2 .. ":" ..  M2 .. " heures disponible."
                                                    elseif langue == "de" then
						         infotext = "Video ist nur von " .. d1 .. "." ..  m1 .. "." ..  y1 .. " - " .. h1 .. ":" ..  M1 .. " Uhr bis " .. d2 .. "." ..  m2 .. "." ..  y2 .. " - " .. h2 .. ":" ..  M2 .. " Uhr verfügbar."
                                                    end
					end
					local h = hintbox.new{caption="Information", text=infotext}
					h:paint()
					repeat
						msg, data = n:GetInput(500)
					until msg == RC.ok or msg == RC.home
					h:hide()
				end
			end
			epg = ""
			title = ""
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
	sm = menu.new{name=" ", icon=arte_7}
	sm:addItem{type="separator"}
	local d = 0 -- directkey
	for i,v in  ipairs(subs) do
		d = d + 1
		local dkey = godirectkey(d)
		sm:addItem{type="forwarder", name=translate_weekday(v[2]), action="fill_playlist",id=v[1], hint=translate_weekday(v[2]) .. ", " .. v[3], directkey=dkey }
	end
	sm:exec()
end

--Main
init()
func={
  [stream]=function (x) return x end,
}

selectmenu()
--os.execute("rm /tmp/lua*.png"); -- only for testing
