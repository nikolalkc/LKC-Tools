--[[
 Noindex: true
]]

WIDTH = 410
HEIGHT =  790
-- HEIGHT =  CHECKLIST_HEIGHT + FORMULAS_HEIGHT + 3*PADDING + TITLE_HEIGHT


--PADDING
PADDING = 20


--TOP LEFT ANCHOR POINT
TL_X = 32
TL_Y = 72

--TOP RIGHT ANCHOR POINT
TR_X = 214.0
TR_Y = TL_Y

--TITLE HEIGHT
TITLE_X = 160
TITLE_Y = 28
TITLE_HEIGHT = 50


SECTION_WIDTH = 168
---------------------------------------------
--FORMULAS
FORMULAS_ANCHOR_X = TR_X
FORMULAS_ANCHOR_Y = TR_Y
FORMULAS_HEIGHT = 180

--RESEARCH
RESEARCH_ANCHOR_X = TL_X
RESEARCH_ANCHOR_Y = TL_Y
RESEARCH_FRAME_HEIGHT = 180

--DNA CHECKLIST
CHECKLIST_X = TL_X
CHECKLIST_Y = 270
CHECKLIST_HEIGHT = 485
CHECKLIST_DIRECTION = "v"
CHECKLIST_PADDING = 20
CHECKLIST_WIDTH = SECTION_WIDTH
CHECKLIST_CAPTION = "DNA"

--RADIATION SLIDERS
RADIATION_ANCHOR_X = TR_X
RADIATION_ANCHOR_Y = CHECKLIST_Y
SLIDER_ANCHOR_X = TR_X + 22
SLIDER_ANCHOR_Y = RADIATION_ANCHOR_Y + 5
SLIDER_WIDTH = 120
SLIDER_DIRECTION = "h"
SLIDER_PAD_X = 0
SLIDER_PAD_Y = 40
--------------------------------------------
