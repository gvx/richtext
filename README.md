**richtext** is a text and image formatting library for the
[LÖVE](http://love2d.org/) framework.

# usage

    local rich = require 'richtext'

    rt = rich:new{"Hello {green}world{red}, {smile} {big}Big text.", 200,
                  black = {0, 0, 0}, green = {0, 255, 0},
                  big = love.graphics.newFont(20), red = {255, 0, 0},
                  smile = love.graphics.newImage('smile.png')}

    function love.draw()
        rt:draw(10, 10)
    end
    
or

    local rich = require 'richtext'
    
    local initialcolor = {255,255,255,255}
    
    local textmacros = {}
    textmacros.black = {0, 0, 0}
    textmacros.green = {0, 255, 0}
    textmacros.red = {255, 0, 0}
    textmacros.big = love.graphics.newFont(20)
    textmacros['smile.png'] = love.graphics.newImage('smile.png')

    rt = rich:new( {"Hello {green}world{red}, {smile} {big}Big text.", 200, textmacros }, initialcolor )

    function love.draw()
        rt:draw(10, 10)
    end

# features

* automatically pads images to [PO2](http://love2d.org/wiki/PO2_Syndrome),
  without any alignment problems

* wraps words and images together

# current issues

* richtext is still not well-tested

* word wrapping might not be optimally done, because it always splits the first
  word, which might lead to a lot of splitting (the end result is fine, though)

* words keep their final space in wrapping, which may cause words to be wrapped
  just a bit too soon

* any initial text color (other than white) has to be specified manually by
  starting text


# license

Copyright (c) 2010 Robin Wellner, (c) 2014 Florian Fischer

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
