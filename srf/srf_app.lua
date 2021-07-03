--[[
	SRF-App
	Vers.: 0.10 
        (c) satbaby and bazi98, 2016 - 2020

        App Description:
        The program evaluates broadcasts from the SRF mediathek and provides videos for 
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

        Copyright (C) for the linked videos and for the Logos by SRF or the respective owners!
        Copyright (C) for fBase64 encoder/decoder function by Alex Kloss,<alexthkloss@web.de> licensed under the terms of the LGPL2
]]

local json = require "json"

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
        srf = decodeImage("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACoAAAAcCAYAAAAX4C3rAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAVESURBVFhH3VhrbBRVFP5mdzu726WtfSx9rPYJ0lJL24ixUBM18U8rSaNA0NQfCEGiMTFWUaNEDagEjEKMJP4gBgLSQqLRtLagEkNiVBATqW2hEKTpk3bpg4XtvroznnvvTPfZggST1S85M3vvPXPON+dx77TSj4DqRhIkJDakNiSpXuQRUVWbSkwYWCQZyUQXg+Cb+Pi/E72Ver6zNS99y5spl9dBNILw0ewMFHj5XYKRRKYVI+0TNq6jwM+FVboAsyN+SxQHI6z8tw6VtIPwaKN4UPkzzFc44hJlpnxw4t4Nm5FVWztLlLkFEZVgwumNz3MijjX1yKurFw/OQhCd6DqH87vfI7d5fMxIGO6yovKjbdo4Pi5+tg+u33rIukmbmYOobM/EyhOHkFJSCFOyiFw0jkhpdFWxbNfbKNvyqpiMwozPj7EfTuCnVWvIZQbNqLCUOVDfc0oozIGfN27C8OetFBaWPYGYGlXZW6cnIb2inJNUZij1gXAJIEjCjEgscmpYJrR1JqqiwGSWkfd4Har3fEL5YOmmJwwhl8K20I8QelYvJB1RRFkFBVDXe1obA62ORTgiL8BROR0tsg2HZZnuMq+jaBy1ZKGZ1g6SdO/4WJslq3KAyjq2B1orq/EF6TKburDx6P4OIpakaQnctOutOYX8IRZBC+zUQgVIRr62GgmLPYfoO5CGQvy+dYs2C9iKl8CckquNQjDLqdymBQs1sZPtbPLHajMypqFq5WDJNOLsm++j8oO3+MzyA7vhHXLC3T+C7m3bMX3lMhlkR250cgRY3G6gDzV7PhUTBM/l8/C7hslyZL0XPfcs/INOSJKwJdE56Z6YwODeQ5xHOKKICqojzR2zRDOqqoEqIkB1U9D4BFSqw7bcCkiBSEMcxNKUJuORA1/CsapBn0JgnFKvxCZv8ab1pBBeEtTSqoIBTpTNh4IR8zTbctx9l3C84mFM9lAkpqZ40bMmkFNTYc7MwGr/EFWyi5sKhxIMYuGjjyGv4UlIRiNvipG27/HH1tcpIsmaVgg8khJRYA3GhcKkRTcaMRFlYDV5o+sivit/kHrVhfvf2Yns2hrYlhTAll/AdbLrHsJwB30khoE5CbpcCDidMNvtdGIEcabpRaruTFqNfi3gr4PN8I2Mh1JPd89VGosRv+qY52TSFSXaWty0G/hQ2vQSbdbb+ax7YBRf5edg+c5dKHtNNM7X2aXwjY1iZct+3LOugdKowtXTi/b7KmGmZmGwlt+Nuq5f+O9jVSvgOnuBPIRIiS6J3VFiC4fgwRCuo5/o9dPvATogx+k1ppGydJGmAVzYu48MRm4hzJ+JnJx5ownTQ4M8QrbiApS+8HLcY9NotfKSCJd4JBliiLJ9dDWlrtHrxdMk67zTeMrrwVqvG0Xrn9G0iOiHO+IaZTXu6xuDm1LKYCIyJa9sRtrSZTSKTf+tIoooO5dof8vKgNFsjhEYjPAMX8HxmlokKelcPyxrfGfgz9Nx2f5AFYJeH59PLS5C6ooSqKTLdHSw40V4vDmMjTC+O4MUzR+7KlhQUoRrnd2Y7PwTU52dJF1wdfZi7OQp/Lp2A3yXRukNjeRiBnJGJlSPQvrnMNTyDSTVQFZUXgJ+13UErl7ja8mFi+E8dhKKx4dkh4PPjbS3IzjpJf2wt50DcZqJuXfTlb1tkN+ZIfZ5Jwrdwq86xGce7ZMEsQWFnAb5V1dQG+lNwmZEvbKxIHlbRG8H+rPxHIbb1dfn04+PuF3/zzFfVPS18PX59OPjDhH99/HfIcqqJf5f0okl2r90WEcnMoC/AV65PC5JSsCtAAAAAElFTkSuQmCC")
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

-- function base64 to file
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- character table string

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

-- Umlaute umwandeln
function uml_str(_string)
	if _string == nil then return _string end
        _string = string.gsub(_string,'\\','');
	_string = string.gsub(_string,'#039;','’');
        _string = string.gsub(_string,'u00f2','ò');
        _string = string.gsub(_string,'u00e0','à');
        _string = string.gsub(_string,'u00ea','ê');
        _string = string.gsub(_string,'u00ee','î');
        _string = string.gsub(_string,'u00b0','°');
        _string = string.gsub(_string,'u00e9','');
	_string = string.gsub(_string,'u00e4','ä');
	_string = string.gsub(_string,'u00c4','Ä');
	_string = string.gsub(_string,'u00f6','ö');
	_string = string.gsub(_string,'u00d6','Ö');
	_string = string.gsub(_string,'u00dc','Ü');
	_string = string.gsub(_string,'u00fc','ü');
	_string = string.gsub(_string,'u00df','ß');
	_string = string.gsub(_string,'u00e8','è');
	_string = string.gsub(_string,'u00e9','é');
	_string = string.gsub(_string,'u00fa','ú');
	_string = string.gsub(_string,'u00fa','ú');
	_string = string.gsub(_string,'u00cd','i');
	_string = string.gsub(_string,'u2019','’');
	_string = string.gsub(_string,'u0027','’');
	_string = string.gsub(_string,'u00e7','ç');
	_string = string.gsub(_string,'u2013','–');
	_string = string.gsub(_string,'u00ab','"');
	_string = string.gsub(_string,'u00bb','"');
	_string = string.gsub(_string,'u201e','"');
	_string = string.gsub(_string,'u201c','"');
	_string = string.gsub(_string,'u2018','.');
	return _string
end 

-- Url verbessern
function url_str(_string)
	if _string == nil then return _string end
        _string = string.gsub(_string,'/z/','/i/');
        _string = string.gsub(_string,'q60,.mp4.csmil/manifest.f4m','q60,.mp4.csmil/index_5_av.m3u8');
        _string = string.gsub(_string,'q60,.mp4.csmil/master.m3u8','q60,.mp4.csmil/index_5_av.m3u8');
        _string = string.gsub(_string,'q50,.mp4.csmil/manifest.f4m','q60,.mp4.csmil/index_4_av.m3u8');
        _string = string.gsub(_string,'q50,.mp4.csmil/master.m3u8','q60,.mp4.csmil/index_4_av.m3u8');
        _string = string.gsub(_string,'podcast_h264_q10.mp4','podcast_h264_q30.mp4');
	return _string
end

function fill_playlist() --- > begin playlist
--- srf 
	local data = getdata('https://il.srgssr.ch/integrationlayer/2.0/srf/showList/tv/alphabetical?vector=portalplay&pageSize=unlimited',nil) --new api
	if data then
		local jnTab = json:decode(data)
		for k, v in pairs(jnTab.showList) do
			if v.id and v.title and v.lead and (v.numberOfEpisodes >= 1)then
				seite = 'https://www.srf.ch/play/v3/api/srf/production/videos-by-show-id?showId=' .. v.id      -- new api
				add_stream ( uml_str(v.title) , seite , uml_str(v.lead) ) -- standart, es wird die allgemeine Sendungsbeschreibung im Hintfenster angezeigt
--                              add_stream ( uml_str(v.title) , seite , seite )           -- nur zum überprüfen ob id richtig ausgelesen wird, id wird dann im Hintfenster angezeigt
			end
		end
	end
--end srf
end --- > end of playlist

function set_pmid(id)
  pmid=tonumber(id)
  return MENU_RETURN["EXIT_ALL"]
end

-- epg-Fenster
local epg = ""
local title = ""
local subselected = 1

function epgInfo (xres, yres, aspectRatio, framerate)
	if #epg < 1 then return end
	local dx = 800;
	local dy = 400;
	local x = 240;
	local y = 0;

	local hw = n:getRenderWidth(FONT['MENU'],title) + 20
	if hw > 400 then
		dy = hw
	end
	if dy >  SCREEN.END_X - SCREEN.OFF_X - 20 then
		dy = SCREEN.END_X - SCREEN.OFF_X - 20
	end
	local wh = cwindow.new{x=x, y=y, dx=dx, dy=dy, title="", icon=srf, has_shadow="true", show_header="true", show_footer="false"};  -- with out footer
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

function set_subid(k)
	subselected = tonumber(k)
	return MENU_RETURN.EXIT
end

function showsubmenu(js)
	local sm=menu.new{name="", icon=srf}
	subselected = 0
	for i,v in  ipairs(js) do
			if  v.lead  ==  nil  then
				v.lead  =  v.description
			end

		sm:addItem{type="forwarder", action="set_subid", id=i, icon="streaming", name=v.title, hint=v.lead, hint_icon="hint_reload"}
--		sm:addItem{type="forwarder", action="set_subid", id=i, icon="streaming", name=v.title, hint=v.description, hint_icon="hint_reload"}
	end
	sm:exec()
end

function m3u8_best_url(m3u8_url)
	local data = getdata(m3u8_url)
	local videoUrl = nil
	if data then
		local host = m3u8_url:match('([%a]+[:]?//[_%w%-%.]+)/')
		local lastpos = (m3u8_url:reverse()):find("/")
		local hosttmp = m3u8_url:sub(1,#m3u8_url-lastpos)
		if hosttmp then
			host = hosttmp .."/"
		end
		local res = 0
		for band, res1, res2, url in data:gmatch('BANDWIDTH=(%d+).-RESOLUTION=(%d+)x(%d+).-\n(.-)\n') do
			if url and res1 then
				local nr = tonumber(res1)
				if nr < 2000 and nr > res then
					res=nr
					if host and url:sub(1,4) ~= "http" then
						url = host .. url
					end
					videoUrl = url
				end
			end
		end
	end

	if videoUrl == nil then video_url = m3u8_url end

	return videoUrl
end

function select_playitem()
	local m=menu.new{name="", icon=srf} -- = only name
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
			local continue = false
			local js_data = getdata(url,nil)
			local js = json:decode(js_data)
			if #js.data.data < 1 then
				local h = hintbox.new{ title="Info", text="Leider keine Video gefunden", icon="info"};
				h:exec();
				continue = true
			end
			subselected = 1
			if continue == false and #js.data.data > 1 then
				showsubmenu(js.data.data)
			end
			if subselected == 0 then
				continue = true
			end

			if continue == false then

				local js_url = js.data.data[subselected].urn:match("video:(.-)$")
				js_url = 'https://il.srgssr.ch/integrationlayer/2.0/mediaComposition/byUrn/urn:srf:video:'.. js_url..'.json?onlyChapters=false'

				local js_url_file = getdata(js_url,nil)
				if js_url_file and js_url_file:find("503 Backend") then
					os.execute("sleep 1") -- server zu langsam
					js_url_file = getdata(js_url,nil)
					if js_url_file and js_url_file:find("503 Backend") then js_url_file = nil end
				end
				if js_url_file ~= nil then
					js = json:decode(js_url_file)
				end
				local video_url = nil
				local GeoBlockInfo = ""
				if js and js.chapterList[1] and js.chapterList[1].analyticsMetadata.media_is_geoblocked then
					local block = js.chapterList[1].analyticsMetadata.media_is_geoblocked
					if type(block) == 'boolean' or block:lower() == "true" then
						GeoBlockInfo = "\nGeo Blocking Aktiv!"
					end
				end
				if js.chapterList[1].resourceList and js.chapterList[1].resourceList[4] and js.chapterList[1].resourceList[4].url then
						video_url = js.chapterList[1].resourceList[4].url
				elseif js.chapterList[1].resourceList and js.chapterList[1].podcastHdUrl then
						video_url = js.chapterList[1].podcastHdUrl
				elseif js.chapterList[1].resourceList and js.chapterList[1].resourceList[2] and js.chapterList[1].resourceList[2].url then
						video_url = js.chapterList[1].resourceList[2].url
				elseif js.chapterList[1].resourceList and js.chapterList[1].resourceList[1] and js.chapterList[1].resourceList[1].url then
						video_url = js.chapterList[1].resourceList[1].url
				end
				if js.chapterList[1] then
					if js.chapterList[1] and js.chapterList[1].title then
						title = js.chapterList[1].title
					end
					if js.chapterList[1] and js.chapterList[1].description then
						epg = js.chapterList[1].title .. "\n\n" .. js.chapterList[1].description
						else
						epg = js.chapterList[1].title .. "\n\n" .. js.show.description
					end
				end

				if js.chapterList[1] and js.chapterList[1].lead then
					epg = js.chapterList[1].title .. "\n\n" .. js.chapterList[1].lead
				end

				if title == nil and js.Downloads then
					title = p[pmid].title
				end

				if video_url == nil and js.Downloads then
					video_url = js.Downloads.Download[1].url[1]
				end

				if video_url then
					local m3u8_url = video_url:match('(http.-m3u8)')
					if m3u8_url then
						video_url = m3u8_best_url(m3u8_url)
					end
					epg = epg 
					vPlay:setInfoFunc("epgInfo")
--					vPlay:PlayFile("SRF",url_str(video_url),title,url_str(video_url)); -- nur zum testen mit Url-Anzeige auf der Infobar
					vPlay:PlayFile("SRF",url_str(video_url),title); -- default
				else
					local h = hintbox.new{ title="Info", text="Video URL not  found" .. GeoBlockInfo, icon="info"};
					h:exec();
				end
				epg = ""
				title = ""
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
