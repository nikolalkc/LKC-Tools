--[[
  ReaScript Name: Folder items
  Author: BFO, LKC
  REAPER: 5+
  Version: 1.03
  Provides:
   [Main] LKC - Toggle faint peaks in folders.lua
   [Main] LKC - Toggle tint items with track color.lua
  About:
    # Simulates folder items behaviour from Cubase.
]]

--[[
 * Changelog:
 * v1.03 (2018-08-24)
	+Provides fix
 * v1.02 (2018-08-24)
	+Version fix
 * v1.01 (2018-08-24)
	+Added utility scripts
 * v1.0 (2018-08-24)
  + Initial Release
]]

--This scripts creates and maintains folder items in the style of Cubase or Studio One
--ver. pre1

-- USER VARIABLES ----------------------------------------------------------
  
  --nikolalkc
  item_luminance = 0.8
  
  --selecting folder item selects all child items
  userChildrenSelection = true --defauklt true
  
  --include one folder item from the start to the end of the last item in a children
  --this needs some more tweaking
  wholeItemEnabled = false --defautl false
  
  --if the whole item is enabled, draw whole items from project start
  drawWholeFromProjectStart = true --default true
  
  --position of folder items
  partialItemsPosition = 0 -- 0..1 ; 0=top, 1=bottom, default 0
  partialItemsHeight = 0.5 -- 0..1 ; 0=minimal height, 1=full track height, default 0.5
  wholeItemPosition = 0.5  --same as above, default 0.5
  wholeItemHeight = 0.5    --same as above, default 0.5
  
  --custom prefix and suffix for the name of the folder item
  g_namePrefix = "[" --default ""
  g_nameSuffix = "]" --default ""
  
  
  --stretch text in folder item
  --bad for CPU
  stretchText = false --default false
  
  --script frequency in seconds
  scriptStep = 0.1 --default 0.1
  
  --how many times will be the folder name repeated in the empty item notes
  --high numbers bad for CPU as well
  nameLength = 1 --default 1

-- END USER VARIABLES-------------------------------------------------------

--NIKOLALKC EDIT
white = reaper.ColorToNative(40,10,50)|0x1000000 --white

--colors utility---------------------------------------------------------------------------------------------
function MakeItemColorDark(item)
	local color = reaper.GetDisplayedMediaItemColor(item)
	local R, G, B = reaper.ColorFromNative(color|0x1000000)
	local new_r, new_g, new_b = Luminance(item_luminance, R, G, B)
	local con_r, con_g, con_b = Convert_RGB(new_r,new_g,new_b)
	local new_color = reaper.ColorToNative(con_r,con_g,con_b)|0x1000000
	ApplyColor_Items(new_color,item)
end

function Convert_RGB(ConvertRed,ConvertGreen,ConvertBlue)
	red = math.floor(ConvertRed*255 )
	green = math.floor(ConvertGreen*255 )
	blue =  math.floor(ConvertBlue*255 )
	ConvertedRGB = reaper.ColorToNative (red, green, blue)
	return red, green, blue
end

function hex2rgb(hex)
	  hex = hex:gsub("#","")
	  hex2rgbR = tonumber("0x"..hex:sub(1,2))
	  hex2rgbG = tonumber("0x"..hex:sub(3,4))
	  hex2rgbB = tonumber("0x"..hex:sub(5,6))
end

absolute_luminance = true
function Luminance(change, red, green, blue)
  local hue, sat, lum = rgbToHsl(red/255, green/255, blue/255)
  if absolute_luminance == true then
	lum = change
  else
    lum = lum + change
  end
  local r, g, b = hslToRgb(hue, sat, lum)
  if r<=0 then r = 0 end ; if g<=0 then g = 0 end ; if b<=0 then b = 0 end
  if r>=1 then r = 1 end ; if g>=1 then g = 1 end ; if b>=1 then b = 1 end
  return r, g, b
end

function rgbToHsl(r, g, b) -- values in-out 0-1
      local max, min = math.max(r, g, b), math.min(r, g, b)
      local h, s, l
      l = (max + min) / 2
      if max == min then
        h, s = 0, 0 -- achromatic
      else
        local d = max - min
        if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
        if max == r then
          h = (g - b) / d
          if g < b then h = h + 6 end
        elseif max == g then h = (b - r) / d + 2
        elseif max == b then h = (r - g) / d + 4
        end
        h = h / 6
      end
      return h, s, l or 1
end

function hslToRgb(h, s, l) -- values in-out 0-1
  local r, g, b
  if s == 0 then
	r, g, b = l, l, l -- achromatic
  else
	function hue2rgb(p, q, t)
	  if t < 0   then t = t + 1 end
	  if t > 1   then t = t - 1 end
	  if t < 1/6 then return p + (q - p) * 6 * t end
	  if t < 1/2 then return q end
	  if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
	  return p
	end
	local q
	if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
	local p = 2 * l - q
	r = hue2rgb(p, q, h + 1/3)
	g = hue2rgb(p, q, h)
	b = hue2rgb(p, q, h - 1/3)
  end
  return r,g,b
end

function ApplyColor_Items(new_color,item)
	reaper.SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR",new_color)
	reaper.UpdateItemInProject(item)
end
--colors utility end---------------------------------------------------------------------------------------------

--END NIKOLALKC EDIT

if not wholeItemEnabled then
    partialItemsPosition = 0 --default 0
    partialItemsHeight = 1  --default 1
end

r = reaper

function msg(m)
reaper.ShowConsoleMsg(m.."\n")
end

--------------------------------------------------------------------------

function fillInName(item, text)
    local item = item
    local text = text
    local textLong = ""
    local i
    
    --text = ""..text..""
    textLong = g_namePrefix..text..g_nameSuffix
    for i=1, nameLength-1 do
        textLong = textLong .. "  . . . . . . . . . . . . . . . . . . . .  " .. text         
    end --for
    
    if stretchText then
        local _,chunk =  reaper.GetItemStateChunk(item, "", 0)
        chunk = string.gsub(chunk, ">", "<NOTES\n|"..textLong.."\n>\nIMGRESOURCEFLAGS 2\n>")
        reaper.SetItemStateChunk(item, chunk, 0)
    else
        reaper.ULT_SetMediaItemNote(item, textLong)
    end
                      
    
end

---------------------------------------------------------------------------
function contains(parentItem, item)
--returns true is item is inside parentItem timewise

      local parentItem = parentItem
      local item = item
      
      local parentIn = reaper.GetMediaItemInfo_Value( parentItem,"D_POSITION") - 0.000000000001
      local parentOut = parentIn + reaper.GetMediaItemInfo_Value( parentItem,"D_LENGTH") + 0.000000000002
      local itemIn = reaper.GetMediaItemInfo_Value( item,"D_POSITION") 
      local itemOut = itemIn + reaper.GetMediaItemInfo_Value( item,"D_LENGTH")
      
       
      if parentIn<=itemIn and itemOut<=parentOut then
          return true
      else
          return false
      end 
end --functions

----------------------------------------------------------------------------

function emptyItemExists(currStart, currEnd, parentTrack )
--returns true is an empty item between currStart and currEnd on track already exists
-- -1=create new item
-- 0-do not create new empty item
-- 1-new empty item cut from start
-- 2-new empty item cut from end
 
    local currStart, currEnd, parentTrack = currStart, currEnd, parentTrack
    local i, item
    local returnValue = false
    
    --toto je asi doveci
    --local margin = 5 --px
    --local marginTime = margin / reaper.GetHZoomLevel()
    
    local margin = 0.0000000000001
        
    for i=0, reaper.CountTrackMediaItems(parentTrack)-1 do
        item = r.GetTrackMediaItem(parentTrack, i)
        if item~=nil then
          --if item is empty
          if r.CountTakes(item)==0 then
              local itemStart = reaper.GetMediaItemInfo_Value( item,"D_POSITION")
              local itemEnd = itemStart + reaper.GetMediaItemInfo_Value( item,"D_LENGTH")
              if (currStart-margin<=itemStart) and (itemStart<=currStart+margin) and (currEnd-margin<=itemEnd) and (itemEnd<=currEnd+margin) then
                  AA = currStart
                  return true
              end --if
              
          end --if
        end --if item
    end --for 
    return false

end --function emptyItemExists

---------------------------------------------------------------------------

function selectChildrenItems(parentTrack, item)

    local parentTrack = parentTrack
    local parentItem = item
    local parentNum, track, m, item, i
    local depth
    
    parentNum = -1 + reaper.GetMediaTrackInfo_Value(parentTrack, "IP_TRACKNUMBER")
    i = 1
    depth = 0
    
    track = reaper.GetTrack(0, parentNum+i)
    depth = 0 --we know that this parent has at least one child 
    while depth>=0 do  
     
        track = reaper.GetTrack(0, parentNum+i)
    if track ~= nil then
      --select  items on the track
      for m=0, reaper.CountTrackMediaItems(track)-1 do
         item = reaper.GetTrackMediaItem(track, m)
         
         if contains(parentItem, item) then
            reaper.SetMediaItemSelected(item, true)
         end 
         
      end --for
      
      --check depth
      depth = depth + reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
      i = i+1
        else 
      depth = -1
    end
    end --while 
    

end --function selectItems

--------------------------------------------------------------------------

function doFolderItem(track)

    local parentTrack = track
    local track, itemStart, itemEnd, itemSel, minStart, maxEnd, emptyNum, trackGUID, prevMergedThis
    local parentNum =r.GetMediaTrackInfo_Value(parentTrack, "IP_TRACKNUMBER")-1
    local i, t =0,0    
    local haveFirstItem = false
    local itemsNum, item, parentName, emptyItem
    local checkedChildrenNum = 0
    local childNum = 0
    local childrenSelection = true
    local merged = {}
    local mPos
         
    
    trackGUID = reaper.GetTrackGUID(parentTrack)
    
    --write into folders array
    folders[trackGUID] = true
    
    --count children num
    i = 0    
    repeat
        childNum = childNum + 1
    if r.GetTrack(0,parentNum+childNum) ~= nil then
      i = i + r.GetMediaTrackInfo_Value(r.GetTrack(0, parentNum+childNum), "I_FOLDERDEPTH")
    else
      childNum = childNum -1
      i = -1
    end
    until i<0
    
  
    
    for t=1, childNum do
          track = r.GetTrack(0, parentNum+t)
                       
              --recursion for folders in folders
              if r.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")==1 then  
                  --recursion returns how many tracks we have had look at inside it          
                  checkedChildrenNum = doFolderItem(track)          
              end --if
              
              t=t+checkedChildrenNum
              
              
              itemsNum =  reaper.CountTrackMediaItems( track )  
            
            
              --fill the array with the first track containing items
              if #merged==0 then
                for i=0, itemsNum-1 do
                    item = reaper.GetTrackMediaItem(track,i)    
                    itemStart = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
                    itemEnd = itemStart +  reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
                    itemSel =  reaper.IsMediaItemSelected( item )
                    table.insert(merged, {itemStart,itemEnd, itemSel})
                end --for i
              
              --or sort-merge the array with the next track
              else
                mPos = 1 --position in the merged array   
                for i=0, itemsNum-1 do    
                    item = reaper.GetTrackMediaItem(track,i)    
                    itemStart =  reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
                    itemEnd = itemStart +  reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
                    itemSel = reaper.IsMediaItemSelected( item )
                          
                    --insert item        
                    while itemStart>merged[mPos][1] do
                        mPos = mPos + 1
                        if merged[mPos]==nil then break end
                    end        
                    table.insert(merged, mPos, {itemStart,itemEnd, itemSel})
                    
                end --for i
              end --if t
              
              
              --flatten the merged array
              if #merged>1 then
                  local changed = false
                  repeat
                    changed = false
                    for i=#merged, 2, -1 do --iterating backwards
                        currItemStart = merged[i][1]
                        prevItemEnd = merged[i-1][2]
                        if currItemStart<=prevItemEnd then
                            merged[i-1][2] = math.max(merged[i][2],merged[i-1][2])
                            merged[i-1][3] = merged[i][3] and merged[i-1][3] --the value after sorting shows wheter all items under this folder itam are selected
                            table.remove(merged, i)
                            changed = true
                        end 
                     end --for
                  until changed==false
              end --if #merged
             
              
              prevMerged[trackGUID] = {true, merged}
              
    end --for   
    
    checkedChildrenNum = i
    
 
    
    --SET EMPTY ITEMs--------------------------------------------------------------
    reaper.PreventUIRefresh(1)
        --set free item positioning for parent track if wholeItem is enabled
        if wholeItemEnabled then
            reaper.SetMediaTrackInfo_Value( parentTrack, "B_FREEMODE", 1 )
        end
        --delete all non-selected empty items on the parent track
        local anySelected = false --any item selected on this track
        itemsNum = reaper.GetTrackNumMediaItems(parentTrack) 
        for i=itemsNum-1, 0, -1 do
            item = r.GetTrackMediaItem(parentTrack, i)
            if item~=nil then
                --if item is empty
                if r.CountTakes(item)==0 then
                    --if item is not selected
                    if not reaper.IsMediaItemSelected( item ) then
                        r.DeleteTrackMediaItem(parentTrack, item)
                    else
                        --select all child items under this item
                        if childrenSelection and userChildrenSelection then
                             selectChildrenItems(parentTrack, item)            
                        end --if  
                    end
                end --if
            end --if item~+nil               
        end --for
        
        
        --if we have any items in children
        if #merged>0 then
            --create new empty items
            _, parentName = reaper.GetSetMediaTrackInfo_String(parentTrack, "P_NAME", "", false)
            local track_color =  reaper.GetTrackColor( parentTrack )
            for i=1, #merged do
                local currStart = merged[i][1]
                local currEnd = merged[i][2]
                --create parent item
                if not emptyItemExists(currStart, currEnd, parentTrack) then
                  local emptyItem = reaper.AddMediaItemToTrack( parentTrack )
				  ApplyColor_Items(track_color,emptyItem) -- nikolalkc edit
				  MakeItemColorDark(emptyItem)
                  reaper.BR_SetItemEdges( emptyItem, merged[i][1], merged[i][2] )
                  --write in the parent name
                  fillInName(emptyItem, parentName)
                  reaper.SetMediaItemInfo_Value( emptyItem, "F_FREEMODE_Y", partialItemsPosition)            
                  reaper.SetMediaItemInfo_Value( emptyItem, "F_FREEMODE_H", partialItemsHeight)
                  --reaper.SetMediaItemSelected( emptyItem,merged[i][3] )
                end --if not emptyItemExists         
            end --for i
            
            --create one start-end empty item, whole item
            if wholeItemEnabled then
              emptyItem =  reaper.AddMediaItemToTrack( parentTrack )
              if drawWholeFromProjectStart then
                reaper.BR_SetItemEdges( emptyItem, 0, merged[#merged][2] )
              else
                reaper.BR_SetItemEdges( emptyItem, merged[1][1], merged[#merged][2] )
              end
              --reaper.ULT_SetMediaItemNote(emptyItem, parentName..suffix)
              reaper.ULT_SetMediaItemNote(emptyItem, " ")
              reaper.SetMediaItemInfo_Value( emptyItem, "F_FREEMODE_Y", wholeItemPosition)            
              reaper.SetMediaItemInfo_Value( emptyItem, "F_FREEMODE_H", wholeItemHeight)
            end --if whole item enabled
           
        
        end --if
    reaper.PreventUIRefresh(-1)
     
    return checkedChildrenNum  
  
end --function duFolderItem

------------------------------------------------------------------------

function cleanFolders()
--ak niektora stopa bola folder a teraz uz nie je, vycisti folder items z nej

  local trackGUID, i
  
  for trackGUID in pairs(folders) do
      if folders[trackGUID]==false then
          
          --delete all empty items
          local track =  reaper.BR_GetMediaTrackByGUID( 0, trackGUID )
          if track~=nil then
            local itemsNum = reaper.GetTrackNumMediaItems(track) 
            for i=itemsNum-1, 0, -1 do
                local item = r.GetTrackMediaItem(track, i)
                if item~=nil then
                    --if item is empty
                    if r.CountTakes(item)==0 then
                       r.DeleteTrackMediaItem(track, item)
                    end --if
                end --if item~+nil               
            end --for
          end
          
          folders[trackGUID] = nil
      end
  end --for trackGUID

end

-----------------------------------------------------------------------

function exit()
    --nikolalkc edit
  reaper.SNM_SetIntConfigVar("showpeaks",2067) --hide faint peaks in folders
  
  
    --clear empty items in folders
    for i=0, reaper.CountTracks()-1 do
        
          track = reaper.GetTrack(0,i)
          
          --unset free item positioning
          reaper.SetMediaTrackInfo_Value( track, "B_FREEMODE", 0 )
          
          --if folder
          if reaper.GetMediaTrackInfo_Value( track, "I_FOLDERDEPTH")>0 then            
                        
              --delete all empty itmes
              for m=r.CountTrackMediaItems( track )-1, 0, -1 do
                  item = r.GetTrackMediaItem( track, m )
                  if item then
                    if r.GetMediaItemNumTakes( item )==0 then
                        r.DeleteTrackMediaItem( track, item )
                    end
                  end --if item
              end --for
              
              
          end --if       
        
    end --for
    r.UpdateArrange()
    
    --set the action state OFF
    r.SetToggleCommandState( sectionID, cmdID, 0 ) -- Set OFF
    r.RefreshToolbar2( sectionID, cmdID ) 

end --function exit()

----------------------------------------------------------------------

function main()

    

    if prevState~=reaper.GetProjectStateChangeCount( 0 ) then
        local trackGUID, track
    
        --mark prevMerged
        for trackGUID in pairs(prevMerged) do
            prevMerged[trackGUID][1] = false
        end --for trackGUID
        
        --mark folders
        for trackGUID in pairs(folders) do
            folders[trackGUID] = false
        end --for trackGUID
    
        tracksNum = r.CountTracks()
        
        if tracksNum>0 then
          
            for t=0, tracksNum-1 do
            
              track = r.GetTrack(0, t)
              
              if r.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")==1 then
                          
                t = t + doFolderItem(track)
    
              end --if
            
            end --for t=0
            
        end --if tracksNum
        
        prevState = reaper.GetProjectStateChangeCount( 0 )
        cleanFolders()
        r.UpdateArrange()
        
    end --if 

   
    r.defer(main)
  
end --function main

-------------------------------------------------------------------------


--set ON the action state
_, _, sectionID, cmdID = r.get_action_context()
r.SetToggleCommandState( sectionID, cmdID, 1 ) -- Set ON
r.RefreshToolbar2( sectionID, cmdID )


prevMerged = {} --stores what empty items should be in the parent track, indexed by track guid
prevState = 0 --reaper.GetProjectStateChangeCount( 0 )
folders = {}
reaper.SNM_SetIntConfigVar("showpeaks",2051)  --nikolalkc edit: show faint peaks in folders
main()
r.atexit(exit)
