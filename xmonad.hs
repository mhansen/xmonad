import XMonad
import XMonad.Config.Gnome
import qualified XMonad.StackSet as W
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders

myManageHook :: ManageHook
myManageHook = composeAll (
    [ resource =? "Do" --> doIgnore 
    , isFullscreen --> doFullFloat
    ])


fullscreenVideo :: [ManageHook]
fullscreenVideo = [ isFullscreen --> (doF W.focusDown <+> doFullFloat) ]

main = xmonad gnomeConfig
    { modMask = mod4Mask
    , manageHook = manageHook gnomeConfig <+> myManageHook
    }
