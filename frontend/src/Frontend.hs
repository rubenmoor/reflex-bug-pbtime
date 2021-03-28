{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}

module Frontend where

import           Control.Monad            ((=<<))

import           Obelisk.Configs          ()
import           Obelisk.Frontend         (Frontend (..))
import           Obelisk.Generated.Static (static)
import           Obelisk.Route            (R)

import           Reflex.Dom.Core          (leftmost, InputElement (..), blank, button,
                                           dynText, el, elAttr, getPostBuild,
                                           holdDyn, inputElement,
                                           inputElementConfig_initialValue,
                                           inputElementConfig_setValue,
                                           performEvent, text, (=:))

import           Common.Api               ()
import           Common.Route             (FrontendRoute)
import           Control.Applicative      (Applicative (pure))
import           Control.Category         (Category ((.)))
import           Control.Lens             ((.~))
import           Control.Monad.IO.Class   (MonadIO (liftIO))
import           Data.Default             (Default (def))
import           Data.Function            (($), (&))
import           Data.Functor             (($>), (<$>))
import           Data.Monoid              ((<>))
import qualified Data.Text                as Text
import           Data.Time                (defaultTimeLocale, formatTime,
                                           getCurrentTime)

code inner =
  elAttr "pre" ("style" =: "background-color: lightgray; padding: 5px") $
    el "code" inner

frontend :: Frontend (R FrontendRoute)
frontend = Frontend
  { _frontend_head = do
      el "title" $ text "Reflex bug where setting the value by a post build \
                        \ event doesn't work"
      elAttr "link" (   "href" =: static @"main.css"
                     <> "type" =: "text/css"
                     <> "rel" =: "stylesheet") blank
  , _frontend_body = do
      rec
        pb <- getPostBuild
        postBuildTime <- performEvent $ pb $> liftIO getCurrentTime
        let today = Text.pack . formatTime defaultTimeLocale "%F" <$> postBuildTime
        code $ text
          "pb <- getPostBuild\n\
          \postBuildTime <- performEvent $ pb $> liftIO getCurrentTime\n\
          \let today = Text.pack . formatTime defaultTimeLocale \"%F\" <$>\
          \ postBuildTime"
        el "h3" $ text "dynText: shows date w/o problem, Never shows \"loading\""
        code $ text "dynText =<< holdDyn \"loading\" today"
        dynText =<< holdDyn "loading" today
        el "h3" $ text "inputElement: does not show date, but neither the initial \
                       \ value"
        code $ text
          "foo <- inputElement $\n\
          \def & inputElementConfig_setValue .~ leftmost [today, btn]\n\
          \    & inputElementConfig_initialValue .~ \"loading\""
        foo <- inputElement $
          def & inputElementConfig_setValue .~ leftmost [today, btn]
              & inputElementConfig_initialValue .~ "loading"
        el "h3" $ text "dynText using inputElement foo, weirdly shows the \
                       \ initial value of \"foo\" shortly"
        code $ text "dynText $ _inputElement_value foo"
        dynText $ _inputElement_value foo
        el "h3" $ text "button to set the input value manually"
        code $ text
          "btn <- ($> \"WURSTBROT\") <$> button \"set input value to\
          \ WURSTBROT\""
        btn <- ($> "WURSTBROT") <$> button "set input value to WURSTBROT"
      pure ()
  }
