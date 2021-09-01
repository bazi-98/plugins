--[[
	shoutcastradio light Version
	Vers.: 0.04
	Copyright (C) 2019-2020, fritz

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

        Copyright (C) for the linked radioservises and for the Logo by shoutcast or the respective owners!
        Copyright (C) for the Base64 encoder/decoder function by Alex Kloss <alexthkloss@web.de>, licensed under the terms of the LGPL
]]

local json = require "json"

-- shortlist from http://api.shoutcast.com/genre/primary?k=[shoutcast_dev_id]&f=xml
-- shortlist from http://api.shoutcast.com/genre/secondary?parentid=0&k=[shoutcast_dev_id]&f=xml
local subs = {
    {"Top500","Top500"},
    {"Alternative","Alternative"},
    {"Blues","Blues"},
    {"Classical","Classical"},
    {"Country","Country"},
    {"Decades","Decades"},
    {"Easy%20Listening","Easy Listening"},
    {"Electronic","Electronic"},
    {"Folk","Folk"},
    {"Inspirational","Inspirational"},
    {"International","International"},
    {"Jazz","Jazz"},
    {"Latin","Latin"},
    {"Metal","Metal"},
    {"Misc","Misc"},
    {"New%20Age","New Age"},
    {"Pop","Pop"},
    {"Public%20Radio","Public Radio"},
    {"R%26B%20and%20Urban","R&B and Urban"},
    {"Rap","Rap"},
    {"Reggae","Reggae"},
    {"Rock","Rock"},
    {"Seasonal%20and%20Holiday","Seasonal and Holiday"},
    {"Soundtracks","Soundtracks"},
    {"Talk","Talk"},
    {"Themes","Themes"}
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
        shoutcast_logo = decodeImage("data:image/png;base64,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")
		local CONF_PATH = "/var/tuxbox/config/"
		local Nconfig	= configfile.new()
		Nconfig:loadConfig(CONF_PATH .. "neutrino.conf")
		local key = Nconfig:getString("shoutcast_dev_id", 'XXXXXXXXXXXXXXXX')
		if key == 'XXXXXXXXXXXXXXXX' then shoutcast_dev_id = "fa1669MuiRPorUBw" else shoutcast_dev_id = key end
end

function sleep(a)
	local sec = tonumber(os.clock() + a)
	while (os.clock() < sec) do
	end
end

-- ####################################################################
-- Base64 encoder/decoder function
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
-- ####################################################################

function add_stream(t,u,f,l)
  p[#p+1]={title=t,url=u,from=f,logo=l,access=stream}
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

-- Umlaute umwandeln
function uml_str(_string)
	if _string == nil then return _string end
        _string = string.gsub(_string,'\\','');
	_string = string.gsub(_string,'#039;','’');
	_string = string.gsub(_string,'&amp;','&');
	_string = string.gsub(_string,"&quot;","'");
	return _string
end

function fill_playlist(id)
	local lom = require("lxp.lom")
	p = {}
	for i,v in  pairs(subs) do
		if v[1] == id then
			sm:hide()
			nameid = uml_str(v[2])	
			local data  = getdata('http://api.shoutcast.com/legacy/genresearch?k=' .. shoutcast_dev_id .. '&genre=' .. id,nil) 
            if data then
				local tab = lom.parse(data)
				for k, v in pairs(tab) do
					if v.tag and v.attr.id then
						local title = v.attr.name
						local seite = v.attr.id
						local genre = ''
						if v.attr.genre then genre = v.attr.genre end
						if v.attr.br then genre = genre .. ' ' .. v.attr.br .. 'k' end
						local logo = ''
						if v.attr.logo then logo = v.attr.logo end
						title = uml_str(title)
						local url = 'http://yp.shoutcast.com/sbin/tunein-station.pls?id=' .. seite .. '&k=' .. shoutcast_dev_id
						add_stream( uml_str(title), url, 'Genre: ' .. uml_str(genre), logo )
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

function select_playitem()
    local m=menu.new{name=" ", icon=shoutcast_logo} 

	for i,r in  ipairs(p) do
		m:addItem{type="forwarder", action="set_pmid", id=i, icon="streaming", name=uml_str(r.title), hint=r.from, hint_icon="hint_reload", logo=r.logo}
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
				vPlay:zapitStopPlayBack()
			end
			local audiourl = nil
			local js_data = nil
			for i=1,5 do
				js_data = getdata(url,nil)
				if js_data then break end
				sleep(1)
			end
			if js_data then
				audiourl = js_data:match('File1=(.-)\n.-Title1')
			end
			if audiourl then
				title = p[pmid].title
				vPlay:ShowPicture("radiomode.jpg")
				vPlay:PlayFile("shoutcast",audiourl, uml_str(title), audiourl); -- default
--  		  	vPlay:PlayFile("shoutcast",url, uml_str(title), p[pmid].logo); -- with logourl on infobar, only for testing
				vPlay:StopPicture()
			else
			print("Radio URL not found")
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
	sm = menu.new{name="", icon=shoutcast_logo}
	sm:addItem{type="separator"}
	sm:addItem{type="back"}
	sm:addItem{type="separatorline"}
	local d = 0
	for i,v in  ipairs(subs) do
		d = d + 1
		local dkey = godirectkey(d)
		sm:addItem{type="forwarder", name=v[2], action="fill_playlist",id=v[1], hint='Radiosender aus der Rubrik : '.. v[2], directkey=dkey }
	end
	sm:exec()
end

--Main
init()
func={
  [stream]=function (x) return x end,
}

selectmenu()
os.execute("pzapit -rz")
os.execute("rm /tmp/lua*.png");
