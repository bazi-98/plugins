--[[
	Icecast Simple Player
	Vers.: 0.1
	Copyright (C) 2019, bazi98

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

        Copyright (C) for the linked Radioservices and for the Logo by Icecast or the respective owners!
        Streamquelle: http://dir.xiph.org/yp.xml
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
        titlelogo = decodeImage(" data:image/png;base64,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")
end

function add_stream(t,u,f)
  p[#p+1]={title=t,url=u,from=f,access=stream}
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
        _string = string.gsub(_string,'&oacute;','ó');
        _string = string.gsub(_string,'&#039;',"'");
	return _string
end

-- ####################################################################
-- function from http://lua-users.org/wiki/BaseSixtyFour

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
-- ####################################################################

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

function fill_playlist() 
	local data = getdata('http://dir.xiph.org/yp.xml',nil) 
	if data then
		for  item in data:gmatch('<entry>(.-)</entry>')  do
			local title,url,genre = item:match('<server_name>(.-)</server_name>.-<listen_url>(.-)</listen_url>.-<genre>(.-)<')
			title = conv_str(title)
			if url then
				add_stream( title, url, genre )
			end
            end
	end 
end 


function set_pmid(id)
  pmid=tonumber(id);
  return MENU_RETURN["EXIT_ALL"];
end

function select_playitem()
    -- local m=menu.new{name="Icecast", icon=""} -- only text
       local m=menu.new{name="", icon=titlelogo} -- only logo

    	for i,r in  ipairs(p) do
    		m:addItem{type="forwarder", action="set_pmid", id=i, icon="streaming", name=r.title, hint=r.from, hint_icon="hint_reload"}
    	end
    	local vPlay = nil
    	repeat
    		pmid=0
    		m:exec()
    		if pmid==0 then return end
    		local url=func[p[pmid].access](p[pmid].url)
    		if url~=nil then
    			if  vPlay  ==  nil  then
    				vPlay  =  video.new()
    				vPlay:zapitStopPlayBack()
    			end
    			if title == nil then
    				title = p[pmid].title
    			end
    			vPlay:ShowPicture("radiomode.jpg") -- reicht je nach Image auch
    			vPlay:PlayFile("Icecast",url,p[pmid].title,url);
    			vPlay:StopPicture()
    		else
    			print("Radio URL not  found")
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
os.execute("pzapit -rz")
os.execute("rm /tmp/lua*.png");
