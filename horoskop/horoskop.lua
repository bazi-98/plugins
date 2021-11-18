--[[
   LUA-Horoskop-Plugin
   (c) 2019 by bazi98
   Lizenz: GPL 2
   Version 0.07

   Horoskoptexte by Impulsprojekte UG (https://www.horoskopbox.de)
   decodeImage-Funktion by Alex Kloss (http://lua-users.org/wiki/)
]]

-- Eigenen Pfad ermitteln
function script_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*/)")
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


-- Deklaration
baseUrl = "https://www.horoskopbox.de/tageshoroskop/horoskop-heute-"
html = ".html"
tmpPath = "/tmp/horoskop"

horoskop = {}

horoskop[1] = "Widder" 
horoskop[2] = "Stier"
horoskop[3] = "Zwillinge"
horoskop[4] = "Krebs"
horoskop[5] = "Loewe"
horoskop[6] = "Jungfrau"
horoskop[7] = "Waage"
horoskop[8] = "Skorpion"
horoskop[9] = "Schuetze"
horoskop[10] = "Steinbock"
horoskop[11] = "Wassermann"
horoskop[12] = "Fische"

-- Umlaute umwandeln
function conv_str(_string)
	if _string == nil then return _string end
        _string = string.gsub(_string,'\\%s+',' ')
        _string = string.gsub(_string,'<p>','<p>\n')
        _string = string.gsub(_string, "%s%s", "\n")
        _string = string.gsub(_string,'Loewe','Löwe')
        _string = string.gsub(_string,'Schuetze','Schütze')
        _string = string.gsub(_string,'Steinb%?cke','Steinböcke')
        _string = string.gsub(_string,'Wasserm%?nner','Wassermänner')
        _string = string.gsub(_string,'%.','.\n')
        _string = string.gsub(_string,'%!','!\n')
        _string = string.gsub(_string,'%?','?\n')
        _string = string.gsub(_string,'%,',',\n')
        _string = string.gsub(_string,'Liebe%:','Liebe:\n')
        _string = string.gsub(_string,'Liebe</h2>','\nLiebe:\n')
        _string = string.gsub(_string,'Gesundheit%:','Gesundheit:\n')
        _string = string.gsub(_string,'Gesundheit</h2>','\nGesundheit:\n')
        _string = string.gsub(_string,'Beruf%:','Beruf:\n')
        _string = string.gsub(_string,'Beruf</h2>','\nBeruf:\n')
        _string = string.gsub(_string,'Geld%:','Geld:\n')
        _string = string.gsub(_string,'So stehen die Sterne heute für das Sternzeichen','Tageshoroskop für das Sternzeichen ') 
        _string = string.gsub(_string,'<.->','')
	return _string
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

-- Funktionen
function auswahl(k)
	horoskop_icon = decodeImage("data:image/png;base64,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")
	s = tonumber(k)
	kreis = horoskop[s]
	local h = hintbox.new{caption="Horoskop-Info", icon=horoskop_icon, text="Die Sterne werden gelesen...\nBitte warten ..."}
	h:paint()
	os.execute("sleep 3")
	h:hide()

	local data = getdata( baseUrl .. kreis  .. ".html",nil)
		if data then
                        local horoskoptext = data:match('<%!%-%- Horoskop heute Text start%-%->(.-)<%!%-%- Horoskop heute Text ende%-%->')
			if horoskoptext then
	                        horoskoptitel = ("Tageshoroskop für das Sternzeichen " .. kreis)
	                        horoskoptext = conv_str(horoskoptext)
--			        local ret = messagebox.exec{ icon="/var/tuxbox/plugins/horoskop_klein.png",title=horoskoptitel, text=horoskoptext, width="400", mode="ALIGN_SCROLL | DECODE_HTML", buttons={"back"}, timeout="180" };
			        local ret = messagebox.exec{ icon="/var/tuxbox/plugins/horoskop_klein.png",caption=horoskoptitel, text=horoskoptext, width="400", mode="ALIGN_SCROLL", buttons={"back"}, timeout="0" };
			end
                 end
end

-- Menueanzeige
horoskop_icon = decodeImage("data:image/png;base64,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")
local m = menu.new{name="Horoskop", icon=horoskop_icon}
m:addItem{type="back"}
m:addItem{type="separatorline"}

local i
for i = 1, 12 do
        if (i == 1) then
		key = "red"
		icon = "btn_red"
	elseif (i == 2) then
		key = "green"
		icon = "btn_green"
	elseif (i == 3) then
		key = "yellow"
		icon = "btn_yellow"
	elseif (i == 4) then
		key = "blue"
		icon = "btn_blue"
	else
		j = i - 4
		key = tostring (j)
		icon = tostring (j)
	end
	m:addItem{type="forwarder", name=horoskop[i], action="auswahl", id=i, icon=icon, hint="Hier werden die Sterne für das Sternzeichen " .. horoskop[i] .. " befragt", hint_icon="horoskop_hint", directkey=RC[key]}
end
m:exec()
os.execute("rm /tmp/lua*.png");
