--[[
 ReaScript Name:Variator
 Author: LKC
 REAPER: 5+
 Extensions: SWS
 Version: 0.3.7
 Provides:
  Data/Lokasenna_GUI/Class - Button.dat
  Data/Lokasenna_GUI/Class - Options.dat
  Data/Lokasenna_GUI/Class - Label.dat
  Data/Lokasenna_GUI/Class - Window.dat
  Data/Lokasenna_GUI/Class - Slider.dat
  Data/Lokasenna_GUI/Class - Frame.dat
  Data/Lokasenna_GUI/Class - Tabs.dat
  Data/Lokasenna_GUI/Core.dat
  Data/variator_mutations.lua
  Data/variator_gui.lua
  Data/layout_horizontal1.lua
  Data/layout_horizontal2.lua
  Data/layout_vertical1.lua
  Data/layout_vertical2.lua
  [Main] LKC - Variator - Mutate.lua
  [Main] LKC - Variator - Mutate using formula 1.lua
  [Main] LKC - Variator - Mutate using formula 2.lua
  [Main] LKC - Variator - Mutate using formula 3.lua
  [Main] LKC - Variator - Mutate using formula 4.lua
  [Main] LKC - Variator - Mutate using formula 5.lua
  [Main] LKC - Variator - Decontaminate.lua
  [Main] LKC - Variator - GUI.lua
 About:
  # LKC Variator

  Mutations cannot be stopped!

  ## Demo Videos

  https://www.youtube.com/watch?v=M7eDuezHG_s

  https://www.youtube.com/watch?v=ZV5fMFslChw

  ## Video Tutorials

  https://www.youtube.com/playlist?list=PLHt0-4EZCM-MpuXZAjdceh5E1t-FQVzl7
]]

--[[
 * Changelog:
   * v0.3.7 (2023-09-26)
    + Fixed broken version 0.3.6
   * v0.3.6 (2023-09-26)
    + Lua 5.4 and REAPER 7 support
   * v0.3.5 (2021-06-22)
    + Added (Un)dock button
   * v0.3.4 (2021-06-22)
    + Fixed paths so it works on ARM version on OSX
   * v0.3.3 (2020-08-20)
    + Docking bug fixed
   * v0.3.2 (2020-08-18)
    + Docking improved (automatically saved)
    + Added option to optimize Chernobyl
    + Added option to snap mutations to grid
    + Added Horizontal 2 layout
    + Some UI bugs fixed
   * v0.3.1 (2020-05-25)
    + Feedback button implemented
    + Beta validator improved
   * v0.3 (2020-05-24)
    + Compiler created
   * v0.2.2 (2020-05-14)
    + Added actions for mutation and decontamination
   * v0.2.1 (2020-05-14)
    + Initial run safety fix
   * v0.2 (2020-05-14)
    + Variator horizontal layout
   * v0.1 (2020-05-11)
    + Initial version

]]
--OS INFO
platform = reaper.GetOS()
if platform == "OSX64" or platform == "OSX32" or platform == "OSX" or platform  == "Other" or platform == "macOS-arm64" then
    separator = [[/]]
else
    separator = [[\]]     --win
end

local bin="x64"
if platform == "Win32" or platform == "OSX32" then bin="x86" end

local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path..[[Data]]..separator..[[variator_gui.lua]])