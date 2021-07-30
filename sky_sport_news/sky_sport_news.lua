--[[
	Sky Sport News-App
	Vers.: 0.2
	Copyright (C) 2016-2020, bazi98
	Copyright (C) 2021, SatBaby and bazi98

        App Description:
        There the player links are respectively read about the recent news clips of the German Television "Sky Sport News"
        from the Sky News library, displays and allows them to play with the neutrino-movie player.

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

        Copyright (C) for the linked videos and for the Sky Sport-Logo by Sky or the respective owners!
        Copyright (C) for the Base64 encoder/decoder function by Alex Kloss <alexthkloss@web.de>, licensed under the terms of the LGPL
]]

local json = require "json"

-- Auswahl
local subs = { -- 'https://sport.sky.de/' .. id  
	{'fussball/videos', 'Fußball'},
	{'/videos/bundesliga-2', '2.Bundesliga'},
	{'formel1/videos', 'Formel 1'},
	{'handball/videos', 'Handball'},
	{'golf/videos', 'Golf'},
	{'tennis/videos', 'Tennis'},
	{'beach-volleyball/videos', 'Beach-Volleyball'} 
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
	sky_sport = decodeImage("data:image/png;base64,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")
end

function add_stream(t,u,f)
  p[#p+1]={title=t,url=u,from=f,access=stream}
end

function getdata(Url,Postfields,outputfile,pass_headers,httpheaders)
	if Url == nil then return nil end
	if Curl == nil then
		Curl = curl.new()
	end

	if Url:sub(1, 2) == '//' then
		Url =  'http:' .. Url
	end

	local ret, data = Curl:download{ url=Url, A="Mozilla/5.0",maxRedirs=5,followRedir=false,postfields=Postfields,header=pass_headers,o=outputfile,httpheader=httpheaders }
	if ret == CURL.OK then
		if outputfile then
			return 1
		end
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
	return _string
end

function fill_playlist(id) --- > begin playlist
	p = {}
	for i,v in  pairs(subs) do
		if v[1] == id then
			sm:hide()
			nameid = v[2]	
			local data  = getdata('https://sport.sky.de/' .. id ,nil)
			if data then
				for  item in data:gmatch('<h3 class="sdc%-site%-tile__headline">(.-)</a>')  do
					local link,name = item:match('<a href="(.-)" class="sdc%-site%-tile__headline%-link" >.-<span class="sdc%-site%-tile__headline%-text">(.-)</span>') 
					seite = 'https://sport.sky.de' .. link 
					title = name
					if seite and title then
						add_stream( title, seite, seite)
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
	local dx = 800;
	local dy = 500;
	local x = ((SCREEN['END_X'] - SCREEN['OFF_X']) - dx) / 2;
	local y = ((SCREEN['END_Y'] - SCREEN['OFF_Y']) - dy) / 2;

	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, icon="" , show_footer=false };
	local ct = ctext.new{parent=wh, x=35, y=5, dx=780, dy=490, text = epg , font_text=FONT['MENU'], mode = "ALIGN_SCROLL | ALIGN_TOP"};
        wh:setCaption{title="Sky Sport", alignment=TEXT_ALIGNMENT.CENTER};

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

function info(captxt,infotxt, sleep)
	if captxt == version and infotxt==nil then
		infotxt=captxt
		captxt="Information"
	end
	local msg, data = 0,0
	local h = hintbox.new{caption=captxt, text=infotxt}
	h:paint()
	if sleep then
		for i=1,sleep*5,1 do
			msg, data = n:GetInput(500)
			if msg == RC.ok or msg == RC.home then
				break
			end
		end
	else
		repeat
			msg, data = n:GetInput(500)
		until msg == RC.ok or msg == RC.home
	end
	h:hide()
end

function set_pmid(id)
  pmid=tonumber(id);
  return MENU_RETURN["EXIT_ALL"];
end

function skyde(sky_url)
	local video_url = nil
	local data = getdata(sky_url,nil)

	local epg1 = data:match('<meta name="twitter:description" content="(.-)">') 
	local title = data:match('meta name="twitter:title" content="(.-)">')
	local account_id = data:match('data%-account%-id="(.-)"')
	local player_id = data:match('data%-player%-id="(.-)"')
	local video_id = data:match('data%-video%-id="(.-)"')
	local blocked = data:match('class="sdc%-site%-roadblock__message">(.-)<')
	if blocked then info("Login mit Plugin ist nicht möglich  ",blocked, 2) end

	local headers = data:match('data%-auth%-config="(.-})"')
	if headers == nil then return nil,epg1,title end
	headers = headers:gsub('&quot;','"')
	local jnTab = json:decode( headers )
	local header_opt = {}
	if jnTab.headers then
		local i = 1
		for k, v in pairs(jnTab.headers) do
			if k == "Authorization" then
				local vtmp = v:match("(.-)&")
				if vtmp then v = vtmp end
				v = dec(v)
			end
			header_opt[i] = k .. ":" .. v
			i = i + 1
		end
	end
	if jnTab.url == nil then return nil,epg1,title end
	local video_id_tmp = video_id:gsub("ref:","")
	local postdat = 'fileReference=' .. video_id_tmp
	local policy_key = getdata(jnTab.url,postdat,nil,0,header_opt)
	if policy_key then
		local player_url = "https://edge-auth.api.brightcove.com/playback/v1/accounts/"
		local json_url = player_url .. account_id .. "/videos/" .. video_id
		local tmp = policy_key:gsub('"',"")
		header_opt = { 'authorization:Bearer ' .. tmp }

		local js_data = getdata(json_url,nil,nil,0,header_opt)
		jnTab = json:decode( js_data )
		local btmp, br=0,0
		for k, v in pairs(jnTab.sources) do
			if v.codec == "H264" then
				btmp = tonumber(v.avg_bitrate)
				if btmp > br then
					video_url = v.src
					br = btmp
				end
			end
		end
	end
	return video_url,epg1,title
end

function select_playitem()
--  local m=menu.new{name="Sky Sport News", icon=""} -- only text
  local m=menu.new{name="", icon=sky_sport} -- only icon

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

	local video_url,epg1,title = skyde(url)

	if epg1 == nil then
		epg1 = "Sky Sport stellt für diese Sendung keinen EPG-Text bereit."
	end

	if title == nil then
		title = p[pmid].title
	end

	if video_url then
		epg = conv_str(title) .. '\n\n' .. conv_str(epg1) 
		vPlay:setInfoFunc("epgInfo")
		vPlay:PlayFile("Sky Sport",video_url,conv_str(title)," " .. video_url);
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
	sm = menu.new{name="", icon=sky_sport}
	sm:addItem{type="separator"}
	sm:addItem{type="back"}
	sm:addItem{type="separatorline"}
	local d = 0 -- directkey
	for i,v in  ipairs(subs) do
		d = d + 1
		local dkey = godirectkey(d)
		sm:addItem{type="forwarder", name=v[2], action="fill_playlist",id=v[1], directkey=dkey }
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
