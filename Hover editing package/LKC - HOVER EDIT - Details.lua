--[[
  ReaScript Name:Hover editing
  Author: LKC
  REAPER: 5+
  MetaPackage: true
  Version: 1.52
  Provides:
   [Main] LKC - HOVER EDIT - Install toggle action.lua
   [Main] LKC - HOVER EDIT - Toggle hovering.lua
   [Main] LKC - HOVER EDIT A - Trim from left.lua
   [Main] LKC - HOVER EDIT B - Split.lua
   [Main] LKC - HOVER EDIT D - Fadein.lua
   [Main] LKC - HOVER EDIT G - Fadeout.lua
   [Main] LKC - HOVER EDIT Q - Untrim left.lua
   [Main] LKC - HOVER EDIT S - Trim from right.lua
   [Main] LKC - HOVER EDIT W - Untrim right.lua
   lkc_hover_edit-fade_split.lua
   lkc_hover_edit-trim.lua
   lkc_hover_edit-untrim.lua
  About:
    Set of scripts that simulate and improve ProTools like editing of audio files.
    Snaps to grid if snapping enabled.
    Supports editing of multiple items at the same time.
    Instructions:
     * Run: Install Toggle Action. This action will save your hover state between REAPER runs.
     * I advise you to create a toolbar icon for "Toggle hovering" script so you can monitor its state.
     * Use "Toggle hovering" script to enable or disable hovering
     * When hovering enabled: Hover your mouse over an item and create edits
     * When hovering disabled: Click with your mouse to move edit cursor and then create edits
]]

--[[
 * Changelog:
   * v1.52 (2019-04-06)
    + Renamed files properly
  * v1.51 (2019-04-05)
    + Fixed package details again
  * v1.5 (2019-04-05)
    + Fixed package details
	+ Info improved
 * v1.4 (2019-04-05)
    + Created install toggle script
    + Added undo blocks
    + Merged scripts
 * v1.3 (2019-03-27)
	+ All scripts can now edit multiple items at once
 * v1.2 (2018-06-24)
	+ Info changed and main added
 * v1.1 (2018-06-24)
	+ Package Created
 * v1.0 (201x-12-28)
	+ Initial Release
--]]