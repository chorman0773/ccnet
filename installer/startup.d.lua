---
--This file is not specifically part of ccnet, 
-- but is a standarized file which all installable projects will use during installation to setup various
-- During installation, if /startup exists and does not match the contents of this file, then /startup will be copied to /startup.d/startup.orig, and this file will be copied to /startup
--
--
--[[
  Copyright (c) 2019 Connor Horman.
  
  This Startup Script for Computer Craft is distributed under the MIT License:
   
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
]]

local function recursiveExecIn(dir)
  for _,t in ipairs(fs.list("/startup.d")) do
    if fs.isDir(t) then
      recursiveExecIn(t);
    else
      shell.run(t);
    end
  end
end

if fs.isDir("/startup.d") then
  recursiveExecIn("/startup.d")
end
