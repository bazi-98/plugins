--[[
	Flux Radio
	Vers.: 0.1
	Copyright (C) 2020, fritz

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

        Copyright (C) for the linked Radioservices and for the Logo by Plattform für regionale Musikwirtschaft GmbH,Berlin or the respective owners!
        Streamquelle: https://fluxmusic.io/api/streams/
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
-- logo
        fluxlogo = decodeImage(" data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHEAAAAYCAYAAADNhRJCAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAALiMAAC4jAXilP3YAAALzSURBVGhD7ZnNjtMwEIDtFHrYO7cWOCEhIV6AI8ce2CvPwAW0HFaqtCyX7gvwDNyR+ga8ARJI3KD0tpUqViu1KhCvx5m06cTj2NmkP6SflGQce8aOx2M7iTiw/0g4KY1JBdLv948Hg8EnTBqoLalB0ZsyNop0aD7A2Y3jWNEsW1k1EkpEmNgSV9fi85absDk4h9nwcaBhR3qvMU4EaDDaohOiEEUn6peOQjORbftgnDibzcR8Pi88oij6gyp7gW5v8tQOvKPQP7Brx7SEjki24R5UYauMDV8dWg5Iy7ryssQ6Cm3mZSennkONEz1aNr2fAk2JupjQnL0W4v3bfJ1X16o5a2KKzSkcXNkAE6V59gIFxDWHmCw6AkMelFKFrTI2QnRsu09Qz97TZUSr1crZ+DuWqoUyJRtdL49RIHz8kJgsikTZgfOqzPkbId6d5JpjItHcLdNpHFXYKmMjVIeWp3D6urNZvaxjqFMo1ImLHy1x906MqXy+y4mNm05vQzzOhEZFnGnnAO2H/xJBo/w2yEusToRR6gKL7TWuSLXlQQRK3NJXyfkJChmi+yh41tfoSIR1j7JYLFAiBI5dmA6zx72ndv21gUGaE4/86my0E/V7I0or2u02SuvoMKydo0frTpPFr7WGw5roSdQJm0thY5M9Lr/w6vEouc7mQnz9Hr5aWZ0Ia4ILLLbXuNZ29tNbTduBbMQ9eZ5c1WVy9eEQiRa4cSq7NexsOHRU+tJIJ/rssPloxGvFnL5CISVgwvsvnOjjFBfJIrHeayS5RHbr2eJcnK7McnVz7IUTQ500mUxQykNtuUxz0ajqCMeM36yvFo4qjSp9MDoqQ6jC1nA4fNzr9b5hconNFq0PcNVZ1L6i/BR4+Udxq2zk26kvtE7ODtwuah7XfmoTkvQfIy0D2Oypn9qJ3JfwDbLT3045RzC3DdD/nJ4N209iX335QMk47++tsNNrom+HgvOm0+lv1597W4T5wunuSufJWzzbgZ1AiBsrPqKxN7ZaHgAAAABJRU5ErkJggg==")
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

function conv_url(_string)
	if _string == nil then return _string end
		_string = string.gsub(_string,'\\','');
		_string = string.gsub(_string,'%%3A',':');
		_string = string.gsub(_string,'%%2F','/');
		_string = string.gsub(_string,'https','http');
		_string = string.gsub(_string,'sslcast','cast');
	return _string
end

function fill_playlist() 
	local data = getdata('https://fluxmusic.io/api/streams/',nil) 
	if data then
    			if  vPlay  ==  nil  then
				vPlay  =  video.new()
				vPlay:zapitStopPlayBack()
    			end
		vPlay:ShowPicture("radiomode.jpg")
		for  item in data:gmatch('"id"(.-)}}')  do
			local title, url,pic = item:match('"title":"(.-)",.-"mp3320":"(http.-)",.-512.-(http.-)",')
			if title then
				add_stream( title, url .. "?#User-Agent=AppleCoreMedia", pic )
			end
    			vPlay:StopPicture()
                end
	end 
end 


function set_pmid(id)
  pmid=tonumber(id);
  return MENU_RETURN["EXIT_ALL"];
end

function select_playitem()
--local m=menu.new{name="Flux-Music", icon=""} -- only text
  local m=menu.new{name="", icon=fluxlogo} -- only logo, default

    	for i,r in  ipairs(p) do
    		m:addItem{type="forwarder", action="set_pmid", id=i, icon="streaming", name=r.title, hint=r.url, hint_icon="hint_reload"}
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

-- geht bestimmt schöner
			bild = p[pmid].from 
	                Curl:download { url = bild, A="Mozilla/5.0;", followRedir = true, o = "/tmp/flux.png"  }
			vPlay:ShowPicture('/tmp/flux.png')
    		        if bild == nil then
    				vPlay:ShowPicture("radiomode.jpg") -- Ersatzbild
    			end
    			vPlay:PlayFile("Flux-Music", url,p[pmid].title, url); -- mit Url auf Infobar
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
os.execute("rm /tmp/*.png");
os.execute("rm /tmp/*.jpg");
