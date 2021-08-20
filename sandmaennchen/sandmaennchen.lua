--[[
	Sanmänchen-App
	Vers.: 0.1 from 20.08.2021
	Copyright (C) 2021, fritz

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

        Copyright (C) for the linked videos and for the Logo by the respective owners!
        Copyright (C) for the Base64 encoder/decoder function by Alex Kloss <alexthkloss@web.de>, licensed under the terms of the LGPL
]]

-- date-functions
function date_from_string(_string) -- generates the correct date from a string in the d.m.Y format e.g. -> 02.12.2016 
    local xday, xmonth, xyear = _string:match("(%d+).(%d+).(%d+)")
    return os.time({day = xday, month = xmonth, year = xyear})
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
        sandmann = decodeImage("data:image/png;base64,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")
end

function add_stream(t,u,f,e)
  p[#p+1]={title=t,url=u,from=f,epg=e,access=stream}
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
        _string = string.gsub(_string,'\\','');
	_string = string.gsub(_string,'.-rdensprache.-','null');
	_string = string.gsub(_string,'#039;','’');
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
	_string = string.gsub(_string,"%s+%s+", "");
	_string = string.gsub(_string,"<.->", "")
	_string = string.gsub(_string,'Unser Sandm.-title":"', '')
	_string = string.gsub(_string,'Unser Sandm.-title:', '')
return _string
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

function fill_playlist()
	local data = getdata('http://itv.mit-xperts.com/rbbsandmann/dyn/index.php',nil) 
	if data then
		for  item in data:gmatch('{(.-)xml')  do
			local title,url = item:match('"title":"(.-)","img".-"vid":"(.-mp4)"')
				title = conv_str(title)
				url = conv_str(url)

			if title ~= "null" then
				add_stream(conv_str(title), url)
			end
            end
	end

end -- > end of playlist


function set_pmid(id)
  pmid=tonumber(id);
  return MENU_RETURN["EXIT_ALL"];
end

function select_playitem()
  local m=menu.new{name="Sandmännchen", icon=""} -- = only name
--local m=menu.new{name="", icon=sandmann} -- = only logo
  for i,r in  ipairs(p) do
    m:addItem{type="forwarder", action="set_pmid", id=i, icon="streaming", name=r.title, hint=r.url, hint_icon="hint_reload"}
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

	if url ~= nil then
		url = p[pmid].url 
	end

	if url then 
		vPlay:PlayFile("Sandmänchen",url, title, url);
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
os.execute("rm /tmp/lua_*.*");
