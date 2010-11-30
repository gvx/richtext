-- richtext library

--[[
Copyright (c) 2010 Robin Wellner

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source
   distribution.
]]

-- issues/bugs:
--  * still under-tested
--  * word wrapping might not be optimal
--  * words keep their final space in wrapping, which may cause words to be wrapped too soon

rich = {}
rich.__index = rich

function rich.new(t) -- syntax: rt = rich.new{text, width, resource1 = ..., ...}
	local obj = setmetatable({parsedtext = {}, resources = {}}, rich)
	obj.framebuffer = love.graphics.newFramebuffer()
	obj:extract(t)
	obj:parse(t)
	obj:render(t[2])
	return obj
end

function rich:draw(x, y)
	local firstR, firstG, firstB, firstA = love.graphics.getColor()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.framebuffer, x, y)
	love.graphics.setColor(firstR, firstG, firstB, firstA)
end

function rich:extract(t)
	for key,value in pairs(t) do
		if type(key) == 'string' then
			local meta = type(value) == 'table' and value or {value}
			self.resources[key] = self:initmeta(meta) -- sets default values, does a PO2 fix...
		end
	end
end

function rich:parse(t)
	local text = t[1]
	-- look for {tags} or [tags]
	for textfragment, foundtag in text:gmatch'([^{]*){(.-)}' do
		table.insert(self.parsedtext, textfragment)
		table.insert(self.parsedtext, self.resources[foundtag] or foundtag)
	end
	table.insert(self.parsedtext, text:match('[^}]+$'))
end

local metainit = {}

local log2 = 1/math.log(2)
function metainit.Image(res, meta)
	meta.type = 'img'
	local w, h = res:getWidth(), res:getHeight()
	if not rich.nopo2 then
		local neww = math.pow(2, math.ceil(math.log(w)*log2))
		local newh = math.pow(2, math.ceil(math.log(h)*log2))
		if neww ~= w or newh ~= h then
			local padded = love.image.newImageData(wp, hp)
			padded:paste(love.image.newImageData(res), 0, 0)
			meta[1] = love.graphics.newImage(padded)
		end
	end
	meta.width = meta.width or w
	meta.height = meta.height or h
end

function metainit.Font(res, meta)
	meta.type = 'font'
end

function metainit.number(res, meta)
	meta.type = 'color'
end

function rich:initmeta(meta)
	local res = meta[1]
	local type = (type(res) == 'userdata') and res:type() or type(res)
	if metainit[type] then
		metainit[type](res, meta)
	else
		error("Unsupported type")
	end
	return meta
end

local function wrapText(parsedtext, fragment, lines, maxheight, x, width, i, fnt)
	-- find first space, split again later if necessary
	local n = fragment:find(' ', 1, true)
	local newx
	if n then
		parsedtext[i] = fragment:sub(1, n)
		table.insert(parsedtext, i+1, fragment:sub(n+1))
		newx = x + fnt:getWidth(fragment:sub(1, n-1))
	end
	if not n or newx > width and x > 0 then -- wrapping
		lines[#lines].height = maxheight
		maxheight = 0
		x = 0
		table.insert(lines, {})
	end
	return maxheight, x
end

local function renderText(parsedtext, fragment, lines, maxheight, x, width, i)
	local fnt = love.graphics.getFont() or love.graphics.newFont(12)
	if x + fnt:getWidth(fragment) > width then -- oh oh! split the text
		maxheight, x = wrapText(parsedtext, fragment, lines, maxheight, x, width, i, fnt)
	end
	local h = math.floor(fnt:getHeight(parsedtext[i]))
	maxheight = math.max(maxheight, h)
	return maxheight, x + fnt:getWidth(parsedtext[i]), {parsedtext[i], x = x, type = 'string', height = h, width = fnt:getWidth(parsedtext[i])}
end

local function renderImage(fragment, lines, maxheight, x, width)
	local newx = x + fragment.width
	if newx > width and x > 0 then -- wrapping
		lines[#lines].height = maxheight
		maxheight = 0
		x = 0
		table.insert(lines, {})
	end
	maxheight = math.max(maxheight, fragment.height)
	return maxheight, newx, {fragment, x = x, type = 'img'}
end

local function doRender(parsedtext, width)
	local x = 0
	local lines = {{}}
	local maxheight = 0
	for i, fragment in ipairs(parsedtext) do -- prepare rendering
		if type(fragment) == 'string' then
			maxheight, x, fragment = renderText(parsedtext, fragment, lines, maxheight, x, width, i)
		elseif fragment.type == 'img' then
			maxheight, x, fragment = renderImage(fragment, lines, maxheight, x, width)
		elseif fragment.type == 'font' then
			love.graphics.setFont(fragment[1])
		end
		table.insert(lines[#lines], fragment)
	end
	lines[#lines].height = maxheight
	return lines
end

local function doDraw(lines)
	local y = 0
	for i, line in ipairs(lines) do -- do the actual rendering
		y = y + line.height
		for j, fragment in ipairs(line) do
			if fragment.type == 'string' then
				love.graphics.print(fragment[1], fragment.x, y - fragment.height)
				if rich.debug then
					love.graphics.rectangle('line', fragment.x, y - fragment.height, fragment.width, fragment.height)
				end
			elseif fragment.type == 'img' then
				local colorMode = love.graphics.getColorMode()
				love.graphics.setColorMode('replace')
				love.graphics.draw(fragment[1][1], fragment.x, y - fragment[1].height)
				if rich.debug then
					love.graphics.rectangle('line', fragment.x, y - fragment[1].height, fragment[1].width, fragment[1].height)
				end
				love.graphics.setColorMode(colorMode)
			elseif fragment.type == 'font' then
				love.graphics.setFont(fragment[1])
			elseif fragment.type == 'color' then
				love.graphics.setColor(unpack(fragment))
			end
		end
	end
	return y
end

function rich:render(width, nofb)
	width = width or math.huge -- if not given, use no wrapping
	local firstFont = love.graphics.getFont() or love.graphics.newFont(12)
	local firstR, firstG, firstB, firstA = love.graphics.getColor()
	local lines = doRender(self.parsedtext, width)
	love.graphics.setFont(firstFont)
	if not nofb then
		self.framebuffer:renderTo(function () self.height = doDraw(lines) end)
	else
		self.height = doDraw(lines)
	end
	love.graphics.setFont(firstFont)
	love.graphics.setColor(firstR, firstG, firstB, firstA)
end
