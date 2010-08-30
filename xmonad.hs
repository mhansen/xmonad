import qualified Data.Map as M
import qualified XMonad.StackSet as W
import XMonad
import XMonad.Config.Desktop
import XMonad.Config.Gnome
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Accordion
import XMonad.Layout.Column
import XMonad.Layout.Tabbed
import XMonad.Prompt
import XMonad.Prompt.AppendFile
import XMonad.Prompt.Man
import XMonad.Prompt.Shell
import XMonad.Util.EZConfig

myManageHook :: ManageHook
myManageHook = composeAll (
    [ resource =? "Do" --> doFloat  --gnome do
    , isFullscreen --> doFullFloat  --don't interfere with fullscreen video
    ])

fullscreenVideo :: [ManageHook]
fullscreenVideo = [ isFullscreen --> (doF W.focusDown <+> doFullFloat) ]

main = xmonad $ gnomeConfig
    { modMask = mod4Mask -- Windows Key
    , borderWidth = 1
    , normalBorderColor  = "#dddddd"
    , focusedBorderColor = "#ff0000"
    , layoutHook = desktopLayoutModifiers (myLayout)
    , manageHook = myManageHook <+> manageHook gnomeConfig
    , terminal = "~/.xmonad/gnome-terminal-wrapper"
    } 
    `additionalKeysP`
    [ ("M-c", spawn "google-chrome")
    , ("M-n", appendFilePrompt defaultXPConfig "/home/moon/notes")
    , ("M-m", manPrompt defaultXPConfig)
    , ("M-s", shellPrompt defaultXPConfig)
    ]


myLayout = tiled ||| Mirror tiled ||| Full ||| simpleTabbed 
  where
    tiled = Tall nmaster delta ratio --partitions the screen into two panes
    nmaster = 1 -- default numer of windows in the master pane
    ratio = 1/2 -- default proportion of screen occupied by master pane
    delta = 3/100 -- percent of screen to incrememnt by when resizing panes
