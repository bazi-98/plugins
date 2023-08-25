--[[
	arte concert
	Vers.: 1.6.2 vom 25.08.2023
	Copyright (C) 2016-2022, bazi98
	Copyright (C) 2009 - for the Base64 encoder/decoder function by Alex Kloss

        Addon Description:
        The addon evaluates Videos from the arte concert media library and 
        provides the videos for playing with the neutrino media player on.

        This addon is not endorsed, certified or otherwise approved in any 
        way by ARTE GEIE.

        The plugin respects arte's General Terms and Conditions of Use, 
        which prohibits the publishing or making publicly available of any 
        software, app or similar which allows the livestream / videos to 
        be fully or partially definitely and permanently downloaded.

        The copyright (C) for the linked videos, descriptive texts and for 
        the arte concert logo are owned by arte or the respective owners!

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
]]

local json  = require "json"

--[[
    langue version

    Mit der Auswahl der Sprachoptionen wird die Sprache des Video und der Texte festgelegt.
    Avec le choix des options de langue langue de la vidéo et le texte du message est défini.

    langue = "de" -- > deutsch
    langue = "fr" -- > français
]]

langue = "de" -- default = "de" 

-- selection menu
local subs = {
{'MUA', 'POP'},
{'MET', 'Metal'},
{'HIP', 'HIP-Hop'},
{'MUE', 'Electronic'},
{'JAZ', 'Jazz'},
{'MUD', 'Int. Music'},
{'CLA', 'Classic'},
{'OPE', 'Opera'},
{'BAR', 'Barock'},
{'ADS', 'Performance'}
}

--[[
     Die Abfrage ist durch arte auf 100 Sendungen begrenzt
     La requête est limitée à 100 éléments par arte
]]

limit = "100"

function datetotime(s) -- > for example 23.11.2016
    local xday, xmonth, xyear, xhour, xmin, xsec = s:match("(%d+).(%d+).(%d+) (%d+):(%d+):(%d+) ")
    return os.time({day = xday, month = xmonth, year = xyear, hour = xhour, min = xmin, sec = xsec})
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
        arte_concert = decodeImage("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAF4AAAAaCAYAAAA+G+sUAAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAAOwgAADsIBFShKgAAAABh0RVh0U29mdHdhcmUAcGFpbnQubmV0IDQuMC45bDN+TgAADd9JREFUaEPtWWt0VNUVjqVatb6qoPUBiBUTAoiKgFAfoFQR8yBAkIeIooTySEGsq8XXLB9Akrl3JgFEUVuXrVShriXyyNx7JzG+lw/ssgI+cGEEJZn7mDuTAIlJSKbfd+6dyWQyRdsl/dPstc66c88+Z+99vrPP3vvcySCZpfedaswd69Gnj7L03KwmY9IlNwtGDx07isVix4Xuut6r5w5q13OyYnpOZlNd/sCJLruHjhVFPEvO0CcN2Q3Q2wC6od+SebgH+P8B2ffO7K/nDa7VC4Z+a0wZsk7PueTQjwV8h/zuSXb5ln4Rf+BCe33wdLe7h0gHy393jp4/eE8oN7tRzx/0eigns0WfetmT1qyRN5Ify4gdp5dt+2XYX3VzWNYetb2B2SaaLWsP430ieUIQiGMPlledE/Zq02yfut2W1AZL1lrQWi1JPWx51XdMSVtQj43weDw/caclyCzVzrN92mzLH5xr+KquoTyXJYhh0fQGR5BvSRhTrg10WYKisnIm7LoOMu43fcpjsK8Q+lZaXm1y1Be8KOap+WlY0mbYvmCxhRZZrQ7AmHl8T27hksDgRr82CDq69LOZcnChIavT62Vl5EGvejZtom57dfWw1LFHaxmxwsJe+ozRLznxPbkNeJECI/7gWBj3UdintYX9wRjAW2dJylNhH34DUCx0cQwgEqSIpEzConeg/wj5HA8lMczHby1m4x3Pdsj6wpQqfx/btOsE6ohTZFXgQktWvhJ6ZLXeLg/2c1mCYps29TIkpczyQR4awJvjsjJMScmCniB4LZxvyupuG2MxrgN97ZakvXhg/ZaT8fxYyEef6VNzwdf5nmhiXepdEX/VHfgNW5N4bnP1N2OdH8He26kf615CnrNGtDTzkvuE0U3ee/vr0678Qs/LbtVzkGTzBjfV52eV27IyLCwH6zlBAOjTmiyvUmpLWhkUNWKhdYYUvDy2fsfxWNASvB8mIBgbDfvU1y0psIQeGPIHR8Pr7gRvK8YYeHbg2YJTUXLAs+VkYQSo3qv+HCfjISyogwvA76fppS5bAI9NJ5hiM6FHAG9VvHca9HxAuWLhsvYdZLwJWx9Gnx2W1cawpIyJAy9kA3jDp92CcbVYy8FEk7WDcK452LRZnMu1JDdg0YD+FsrAO+SoTaYvkG/L6sIuclIb5Irmvmd0PFt6qj6x/8JQQeYqfdaYYn36yEX63BumHPR4zoaxzxIEsVOSWosFTLce33q+JW89P1pe9ZuwLzBtx/r1xxvewDSMs7GYDnjLOzjON+2XN54k0EoiAsdQgU15Fca3Y1O/Qyh4jCeGfL2k8mrOBf996oRMw/RWjhCTQemA51HHuIepm54EYMOQscD0BzIZBrnxRlmgkKAnPF4AprVHfFVXQP8NsGNClyYpfcUJ8mm/DcuB+QB3qikr49gi5doN9HL0vSvscGzZbHmrspNlAIcChOf5lCFCp19FqO7kZ4QfXTQUMf4rhJdac/qIKxuX5fQ+UJTTO7py7cWY9IVzRLRmADY2XcwNS6/0Bb9eLFrWdtHgxorKPtychjXBs3ga3OEJsioqT8PYLQSLuy8MARkl22+Gl7+JcHIrdQq+rK2Py4iHGvDEggm8I0v9MH6E4SCPxDyxLvkD51rYnerxtFUMSEPw4NtgVwOc7SBAvicey0mUZ/qrM2HDIeqEHZ8ZvsC5LluQgQ2HA9m2X0SGN1JtytBnjNoXystuC+UOajNuHbEPl6i9bEZRYQ2PLI8TlH+4H4nLnZKgWOGmXkigEjyoHUDqpi84C+Ofhmf8Awvcib6PTEn1W3LV+e6UBLEPngnvE6dkIysgAg9dzdiM+9H3pgvwYdurXss5XYB3PZ6ejfHfCDslrelQCgDJlADe9fijAR+P8RxrytofkoEnRfw1Z8CO3eRjkw7Y3m39XZYg5I/rbTnY6vI/7A58t6TqNOPuGSJJOZ6svtBRUfkzd0qC6NFQjrCARCepm7HwLzH2mXpUC41STW9dVi4G8C9zx5NjOUmECEl5AHORiNUDVknNBQ7wiM8+9RNDCtwNXiv1YyPfJmjpPB780QCoQdgqq5+mJuxkSoQaromhzqsO4Wnq1gBSIrmiKEgHPCso8PdQFjb+29RCIELgfQCefCkN8MatI/cxqdLj9cLh+/G+1ygc/rG1fMVbECwWiN1bw0W7UxJU563MBl9Ha8Oi69A262trTnHZghh20P8B47DblSDEypGYy2R1BEf1mjjw2IhWhIwingTXhkOMs0y03UJNuYJcg5NJMCX1NQLniu9GyaEGgCJ3IdfI2guwD819+rQNDKsCeD+rmu7AMydF5KoCrEl4NJ7/ZGnpsgUJjz8a8NFHFwzX87L26RMH7g/NGDP60NKCc+uKp/ZBVn/A9QzE4aDUbSLI8m4bBeOb6BUApiNaoQ53WV3I9KoLAeK7qV7vbIqocmJ2mXpbAnjKk9QNTH7gmY43a9WWB/GcwIMv5tDjyxQkK5SQBEBStzPZu+K7UVfghacmyr/OPgLplpNJwDOhMn+gDF4JPQHojHAs52D832KerieNwMMmcWLThprGFcV9zOJJ26zFBdvDy/L7ut1MLsuFMQJ4NS3wDTjm4DXbAnitvWltdZc4FyfImAZDd5ilb5/qdgmKrnvrF1iEQT0o/e6MAy/kyepLrIywsX9Gg3dqRwg0StQS2kRA+B4VVRDLO7z/J8BjPuR+E/are52mOU3Gb9jbGePjwKuK0EEg4xuGJ/prAe5oV0WCnFCDE8Hx6YC3imddgNr9K4Qb05x93ZVudwZvbfFQAwPThhq7vOpSHLMIGhIkwoWsLHVZCeINFXH+eRj4SqpyqwS3Q1nFfAArKxM6Q40DPMfjnnAJNpf1MwH42vYqi8E/hHECeKssMB6/m8UcSX39h4QacTpYTvJyiNIxtelrN51C4HFBS3g8NkRzsBB4tOFp4PQ9weQer5qSKeHx0JUW+KjsORPVzE4m1FDBpRF92qj9ITRj0bxvhBLH+zamq8vNNdp54O2yeBvFTRFtH2vdPW4i5hzLG5gMOV8i+VwtJrlEY2H4XCwOlx01wkRM4LGBTqhxgedY/H5Q6PBjwV5lBY59NYADeADeq47CIqPiyCO513ieO1EoSEOpyfXoVY16h6PTAd4o1QZaJcpIu0y5HRfL2+EMc9JVa3FCeAXwTnEAXLoDH37isb7GpCGs47tUNaEZY+EZapMIA7K284C0pbc7JUH0LiwcCUntwBWdoNMzPg97A1W4zb2MeTVY4GfwzPzUqoBhB54KL6JhuOqjHu+M8dTZCTy/4QDcT3jEIX9vpEIZh2cjgY9WVP8KC/xaHH0kO36QEwrSUCLUuB7/fcAD9C7JdZdn0wk4VZtR3/NUsqBYkXyzTiYCnwg16ZKrucZznj556PuhvKz65Ibq5mVM3Mkdh4JWLKowfsOMk/PRSRkDI1iZxBBSNkbLgyOwKI9Vpj5jSsE/8uimXrx4IiJScBlkHoH8FjznsT81xseNpV4RZ3HECb7lU54C32v7qmczLEDfO8KzaKtfWRsDQJwXp9imWC8ClxzjfzDwrsfHHYeVGOyI0kbgUteAi5SYkEJOVUOPF7mnO/Cx9UXHhxeOG2zceV1JaPbVz8ebPmdcMUCroHLhTX7NhMKHQquCF/FLH8FC5fMUgQUIywE86nGtDeHjL3WoVlzx3YjlJm6jpRiLpAy5qPPjJajhjQPf1eNJdSsq++BUfSrmyOph08vrfHACNxVgLGZVJXiI/7y0RUqrrjhQsqUf5M0E/0neLFOBt/yvjWLIQAibn9wYFjuB73qBqvXUnAiZz0GP8z1JVrem8/rv9fhYDNff+RNW6DmZraGcrCPxpucO2NBQjrgmK3uEEoYEX/AILh2rw15tLUGGAa1QfJddEjwdC/mr6BO3WHUfnkWMi1wwv5ngpndhhN8vZO09NG4SjrH6WnIIS3g8Q0EK8CRTCuRhXouwRdb+zksa+2PPAQzU8JTpgs+vkR8jDK7CO08Uq6CVzke4zlCDxJ0DXh0A5klqgxeLJ7x1TRx4jk0GnoR8NAyXRVGNYX4rNn1qaoJ1gD9aHS/fc6b7D1SXGB//LKz71csAwmY0AIJj7n4WFr9lBdWFWs4d/3Zl8CzwHkQMDDs8VCr8YCVrn6PthpfX48mSkMA0I9M/mXrbc4B39aQBnsBhs14ln5UOcshVLgsV1pZ+OBF/go5D5Mc/C9MOtGbW3tF121C+EniGK4Qa97OwI6+zWX7lCQE8NxLvqcDzlEH+fZRNPnS+kfpJRSRXhmjKTAd83dyJ/fXcQbV6/uDDxuTLw7jBHjFmjq7R5/x6kTtEeFRI1oYiyy+FkkITyRLJc7b4cwE8d1hGDW+WvsAV8D4kIC2EdhiNyulNTVg0NkJ9y/IFxscrn2QyHg+ci82cQh3hssDo1NxAYnlJD+OY1O8j/FwQLWOy5a03sNyQKydC992mVJPFTXNyEup+yuc6UJXBrrz4u2jl/PNEHc4TGpYDzrg0uYBhi/8/kG/5A5P57cZlCeJGAJ/xsPVGq0K7qtta7IUEPvtrY9JQ3Zo/oRrAtxszx6wx5o//r//+E1fq1eoAhgYsogiL5+fVQquiKntH0b+/4PxfkeUpPk2flP1J6JbMDmvp5J2h3KwOgN+q5w98wR3SQ8eCGLuseTct0fMGfWctm7oBIac5Ocb30DGkXR7PCeaCCbmRR+ZNMYomePSCYS3GnGu7fU3soR+LMjL+BVD9mV5bAsYrAAAAAElFTkSuQmCC")
end

function add_stream(t,u,e)
  p[#p+1]={title=t,url=u,epg=e,access=stream}
end

function getdata(Url,outputfile)
	if Url == nil then return nil end
	if Curl == nil then
		Curl = curl.new()
	end
	local ret, data = Curl:download{url=Url,A="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36",followRedir=true,o=outputfile }
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

-- convert stream address according to the best quality
function conv_url(_string)
	if _string == nil then return _string end
       _string = string.gsub(_string,'\\','');
 	return _string
end

-- convert special characters
function conv_str(_string)
	if _string == nil then return _string end
        _string = string.gsub(_string,'\\','');
	_string = string.gsub(_string,'#039;','’');
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
	_string = string.gsub(_string,'u00f9','ù');
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
	_string = string.gsub(_string,'&lt;','');
	_string = string.gsub(_string,'&amp;','&');
	_string = string.gsub(_string,'&quot;','"');
	_string = string.gsub(_string,'&gt;','');
	_string = string.gsub(_string,'br /','');
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
	_string = string.gsub(_string,'u00bf',''); -- ¿
	_string = string.gsub(_string,'u00bb','»');
	_string = string.gsub(_string,'u00ab','«');
	_string = string.gsub(_string,'u00f8','ø');
	_string = string.gsub(_string,'u2026','…');
	_string = string.gsub(_string,'u00aa','ª');
	_string = string.gsub(_string,'u0300','̀ ');
	return _string
end 

function fill_playlist(id)
	p = {}
	for i,v in  pairs(subs) do
		if v[1] == id then
			sm:hide()
			nameid = v[2]	
			local data = getdata('https://www.arte.tv/api/rproxy/emac/v3/' .. langue .. '/web/data/MOST_RECENT_SUBCATEGORY/?subCategoryCode=' .. id .. '&page=1&limit=' .. limit .. '',nil) -- Version default
				if data then
				    for  seite, title, subtitle, teaser in data:gmatch('{"id":".-deeplink":"arte://program/(.-)","title":"(.-)",.-subtitle":(.-),"shortDescription":"(.-)",.-}')  do -- Version default
					if subtitle == "null" or subtitle == " null" or subtitle == nil then
						title = title
					else
						title = title .. " - " .. subtitle
					end
					if title then
						add_stream( conv_str(title), seite , conv_str(teaser) ) 
-				        end
				    end
				else
				    return nil
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
	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title=title, icon="", has_shadow="true", show_header="true", show_footer="false"};  -- with out footer
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

function select_playitem()
  local m=menu.new{name="", icon=arte_concert}
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
		local js_seite = getdata('https://www.arte.tv/hbbtv-mw/api/1/player/'.. seite .. '?authorizedAreas=ALL,DE_FR,EUR_DE_FR,SAT&lang='.. langue,nil)
                if js_seite ~= nil then
		video_url  =  js_seite:match('streams.-"url": "(http.-mp4)"')
                        duration = js_seite:match('"formated_duration":.-"(.-)"')
                        title = p[pmid].title 
                        epg = p[pmid].epg 

				local videoplayed = false
				if title and video_url then
                                                    if langue == "fr" then
						         epg = epg .. '\n\nTemps de lecture : ' .. duration
						    elseif langue == "de" then
						         epg = epg .. '\n\nSpieldauer : ' .. duration
						    elseif langue ~=  "fr" or langue ~=  "de" then
						         epg = epg .. '\n\nDuration : ' .. duration
                                                    end

						vPlay:setInfoFunc("epgInfo")
					videoplayed = true
					vPlay:PlayFile ("arte HD", conv_url(video_url), conv_str(title) );
				end

				if videoplayed == false then
					local infotext = ""
                                                    if langue == "fr" then
						         infotext = "La vidéo sélectionnée est actuellement indisponible."
                                                    elseif langue == "de" then
						         infotext = "Das ausgewählte Video ist zur Zeit nicht verfügbar."
                                                    elseif langue ~=  "fr" or langue ~=  "de" then
						         infotext = "The selected video is currently unavailable."
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
	sm = menu.new{name="", icon=arte_concert}
	sm:addItem{type="separator"}
	local d = 0 -- directkey
	for i,v in  ipairs(subs) do
		d = d + 1
		local dkey = godirectkey(d)
		sm:addItem{type="forwarder", name=v[2], action="fill_playlist",id=v[1], hint='arte concert: ' .. v[2], directkey=dkey }
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
