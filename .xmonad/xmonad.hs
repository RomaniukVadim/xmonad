-- Core
import XMonad
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import System.Exit
import Graphics.X11.Xlib
import Graphics.X11.ExtraTypes.XF86
--import IO (Handle, hPutStrLn)
import qualified System.IO
import XMonad.Actions.CycleWS (nextScreen,prevScreen)
import Data.List
 
-- Prompts
import XMonad.Prompt
import XMonad.Prompt.Shell
 
-- Actions
import XMonad.Actions.MouseGestures
import XMonad.Actions.UpdatePointer
import XMonad.Actions.GridSelect
 
-- Utils
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.Loggers
import XMonad.Util.EZConfig
import XMonad.Util.Scratchpad
-- Hooks
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.Place
import XMonad.Hooks.EwmhDesktops

-- Layouts
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.DragPane
import XMonad.Layout.LayoutCombinators hiding ((|||))
import XMonad.Layout.DecorationMadness
import XMonad.Layout.TabBarDecoration
import XMonad.Layout.IM
import XMonad.Layout.Grid
import XMonad.Layout.Spiral
import XMonad.Layout.Mosaic
import XMonad.Layout.LayoutHints

import Data.Ratio ((%))
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.Spacing
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Gaps
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.SetWMName

defaults = defaultConfig {
        terminal	= "terminator"
        --, font	= "xft:Droid Sans Mono:size=8"
        , normalBorderColor   = "#2C323C"
        , focusedBorderColor  = "#51afef"        
        , workspaces          = myWorkspaces
        , modMask             = mod4Mask
        , borderWidth         = 0
        , startupHook         = setWMName "LG3D"
        , layoutHook          = myLayoutHook
        , manageHook          = myManageHook
        , handleEventHook     = fullscreenEventHook
	}`additionalKeys` myKeys

myWorkspaces :: [String]
myWorkspaces =  ["1:web","2:dev","3:term","4:vm","5:media","6:GIMP"] ++ map show [7..9]

-- tab theme default
myTabConfig = defaultTheme {
   activeColor          = "#839496"
  , activeBorderColor   = "#073642"
  , inactiveColor       = "#666666"
  , inactiveBorderColor = "#000000"
 }

-- Color of current window title in xmobar.
xmobarTitleColor = "#c678dd"

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#51afef"

myLayoutHook = gaps [(U,15)] $ toggleLayouts (noBorders Full) $ Mirror tiled ||| mosaic 2 [3,2]  ||| Full ||| tabbed shrinkText myTabConfig
      where 
        tiled = Tall nmaster delta ratio
        nmaster = 1
        delta   = 2/100
        ratio   = 1/2

--myLayoutHook = smartBorders $ avoidStruts $ toggleLayouts (noBorders Full)
    --(smartBorders (tiled ||| mosaic 2 [3,2] ||| Mirror tiled ||| tabbed shrinkText myTab))
    --where
    --    tiled   = layoutHints $ ResizableTall nmaster delta ratio []
    --    nmaster = 1
    --    delta   = 2/100
    --    ratio   = 1/2                              
                              
myManageHook :: ManageHook
	
myManageHook = composeAll . concat $
	[ [className =? "mpv"        --> doFloat]
	, [className =? c --> doF (W.shift "1:web")		| c <- myWeb]
	, [className =? c --> doF (W.shift "2:dev")		| c <- myDev]
	, [className =? c --> doF (W.shift "3:term")	| c <- myTerm]
	, [className =? c --> doF (W.shift "4:vm")		| c <- myVMs]
	, [manageDocks]
	]
	where
	myWeb = ["Firefox","Chrome"]
	myDev = ["Eclipse","Emacs"]
	myTerm = ["Terminator","xterm"]
	myVMs = ["VirtualBox"]
	
	--KP_Add KP_Subtract
myKeys = [
           ((mod4Mask, xK_Right), nextScreen) 
         , ((mod4Mask .|. controlMask, xK_Left ), prevScreen)
         , ((mod4Mask, xK_g), goToSelected defaultGSConfig)
	 , ((mod4Mask, xK_s), spawnSelected defaultGSConfig ["chromium","idea","gvim"])
	 , ((mod4Mask, xK_KP_Add), spawn "amixer set Master 10%+ && ~/.xmonad/getvolume.sh >> /tmp/.volume-pipe")
	 , ((mod4Mask, xK_KP_Subtract), spawn "amixer set Master 10%- && ~/.xmonad/getvolume.sh >> /tmp/.volume-pipe")
         , ((mod4Mask, xK_b     ), sendMessage ToggleStruts)
         , ((mod4Mask, xK_p), spawn "rofi -show run") 
	 , ((mod4Mask, xK_End), spawn "/home/glicone/betterlockscreen/lock.sh --lock dim")
         , ((0 ,xK_Print), spawn "xfce4-screenshooter")
	 , ((0, xF86XK_MonBrightnessDown), spawn "xbacklight -dec 10")
	 , ((0, xF86XK_MonBrightnessUp), spawn "xbacklight -inc 10")
	 , ((mod4Mask .|. shiftMask, xK_t), sendMessage $ ToggleGap U) -- toggle the top gap
	]

main = do
	xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmonad/xmobar.hs"
	xmonad $ defaults {
	logHook =  dynamicLogWithPP $ defaultPP {
            ppOutput = System.IO.hPutStrLn xmproc
          , ppTitle = xmobarColor xmobarTitleColor "" . shorten 100 .wrap "  [ <fc=#ACCECF>" "</fc> ]  "
          , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor "" . wrap "[" "]"
          , ppSep = "   "
          , ppWsSep = " "
          --, ppLayout = const ""
          , ppLayout  = (\ x -> case x of
              "Spacing 6 Mosaic"                      -> "[:]"
              "Spacing 6 Mirror Tall"                 -> "[M]"
              "Spacing 6 Hinted Tabbed Simplest"      -> "[T]"
              "Spacing 6 Full"                        -> "[ ]"
              _                                       -> x )
          , ppHiddenNoWindows = showNamedWorkspaces
      } 
} where showNamedWorkspaces wsId = if any (`elem` wsId) ['a'..'z']
                                       then pad wsId
                                       else ""

