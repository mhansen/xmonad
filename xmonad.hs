import XMonad
import XMonad.Config.Desktop
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Accordion
import XMonad.Layout.Column
import XMonad.Layout.Tabbed
import XMonad.Layout.Gaps
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.NoBorders
import XMonad.Prompt
import XMonad.Prompt.AppendFile
import XMonad.Prompt.Man
import XMonad.Prompt.Shell
import XMonad.Util.EZConfig
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.BoringWindows
import Data.Ratio ((%))

{-# OPTIONS_GHC -fno-warn-missing-signatures #-}

-----------------------------------------------------------------------------
-- |
-- Module       : XMonad.Config.Gnome
-- Copyright    : (c) Spencer Janssen <spencerjanssen@gmail.com>
-- License      : BSD
--
-- Maintainer   : Spencer Janssen <spencerjanssen@gmail.com>
-- Stability    :  unstable
-- Portability  :  unportable
--
-- This module provides a config suitable for use with the GNOME desktop
-- environment.

import XMonad.Util.Run (safeSpawn)

import qualified Data.Map as M

import System.Environment (getEnvironment)

-- $usage
-- To use this module, start with the following @~\/.xmonad\/xmonad.hs@:
--
-- > import XMonad
-- > import XMonad.Config.Gnome
-- >
-- > main = xmonad gnomeConfig
--
-- For examples of how to further customize @gnomeConfig@ see "XMonad.Config.Desktop".

gnomeConfig = desktopConfig
    { terminal = "gnome-terminal"
    , keys     = gnomeKeys <+> keys desktopConfig
    , startupHook = gnomeRegister >> startupHook desktopConfig }

gnomeKeys (XConfig {modMask = modm}) = M.fromList $
    [ ((modm, xK_p), gnomeRun)
    , ((modm .|. shiftMask, xK_q), spawn "gnome-session-save --kill") ]

-- | Launch the "Run Application" dialog.  gnome-panel must be running for this
-- to work.
gnomeRun :: X ()
gnomeRun = withDisplay $ \dpy -> do
    rw <- asks theRoot
    gnome_panel <- getAtom "_GNOME_PANEL_ACTION"
    panel_run   <- getAtom "_GNOME_PANEL_ACTION_RUN_DIALOG"

    io $ allocaXEvent $ \e -> do
        setEventType e clientMessage
        setClientMessageEvent e rw gnome_panel 32 panel_run 0
        sendEvent dpy rw False structureNotifyMask e
        sync dpy False

-- | Register xmonad with gnome. 'dbus-send' must be in the $PATH with which
-- xmonad is started.
--
-- This action reduces a delay on startup only only if you have configured
-- gnome-session>=2.26: to start xmonad with a command as such:
--
-- > gconftool-2 -s /desktop/gnome/session/required_components/windowmanager xmonad --type string
gnomeRegister :: MonadIO m => m ()
gnomeRegister = io $ do
    x <- lookup "DESKTOP_AUTOSTART_ID" `fmap` getEnvironment
    whenJust x $ \sessionId -> safeSpawn "dbus-send"
            ["--session"
            ,"--print-reply=literal"
            ,"--dest=org.gnome.SessionManager"
            ,"/org/gnome/SessionManager"
            ,"org.gnome.SessionManager.RegisterClient"
            ,"string:xmonad"
            ,"string:"++sessionId]


myTiled = subTabbed $ windowNavigation $ smartBorders $ boringWindows $ desktopLayoutModifiers $ withIM taskRatio taskRoster tiled
  where
    tiled = Tall nmaster delta ratio -- partitions the screen into two panes
    nmaster = 1 -- default numer of windows in the master pane
    ratio = 1/2 -- default proportion of screen occupied by master pane
    delta = 3/100 -- percent of screen to increment by when resizing panes
    taskRatio = (1%6)
    taskRoster = Title "Snippets - Google Docs - Google Chrome"

myTabbed = windowNavigation $ smartBorders $ boringWindows $ desktopLayoutModifiers $ simpleTabbed

main = xmonad $ gnomeConfig
    { modMask = mod4Mask -- Windows Key
    , borderWidth = 1
    , layoutHook = myTiled ||| myTabbed
    , manageHook = composeAll $
        [ manageHook gnomeConfig
        , resource =? "Do" --> doFloat  --gnome do
        , isFullscreen --> doFullFloat  --don't interfere with fullscreen video
        , className =? "Unity-2d-panel" --> doIgnore
        , className =? "Unity-2d-shell" --> doIgnore
        ]
    , terminal = "~/.xmonad/gnome-terminal-wrapper -e ~/.xmonad/tmux-open"
    , startupHook = do
        startupHook gnomeConfig
        spawn "/usr/bin/xcompmgr" -- Nvidia issue: b/12995284
    }
    `additionalKeysP`
    [ ("M-C-h", sendMessage $ pullGroup L)
    , ("M-C-l", sendMessage $ pullGroup R)
    , ("M-C-k", sendMessage $ pullGroup U)
    , ("M-C-j", sendMessage $ pullGroup D)
    , ("M-j", focusDown)
    , ("M-k", focusUp)
    ]

