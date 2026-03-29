;; terminal-title-mode, a global Emacs minor mode for setting the window
;; title and icon name of the terminal Emacs is running in.
;; Copyright (C) 2013-2026 Simon Grieger
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License along
;; with this program; if not, write to the Free Software Foundation, Inc.,
;; 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

(define-minor-mode terminal-title-mode
  "Toggle Terminal Title mode.
Interactively with no argument, this command toggles the mode. A positive
prefix argument ARG enables the mode, any other prefix argument disables
it. If called from Lisp, argument omitted or nil enables the mode, `toggle'
toggles the state.

Terminal Title mode is a global minor mode. When enabled, Emacs will set
the terminal's window title and icon name (if Emacs is running in a
terminal), according to the variables `frame-title-format' and
`icon-title-format'. See the function `terminal-title-refresh' for details.

Note that this mode currently only works with terminals of type xterm,
i.e. xterm itself and compatible ones, such as Konsole, GNOME Terminal, and
many others."
  :global t
  :init-value nil
  :lighter nil
  (if terminal-title-mode (add-hook 'post-command-hook 'terminal-title-refresh)
    ;; else
    (remove-hook 'post-command-hook 'terminal-title-refresh)))

(defun terminal-title-refresh ()
  "Refresh the window title and icon name of the selected frame's terminal.

Some notes on precedence regarding different ways of setting the window
title and icon name:

o Normally, the variables `frame-title-format' and `icon-title-format' are
  used to compute the window title or icon name, respectively.

o The calculated frame titles and icon names may be overridden by setting
  the `title' frame parameter explicitly.

o Strictly speaking, if the frame's display is graphical, the `name' frame
  parameter also overrides `frame-title-format' and `icon-title-format', if
  set explicitly. We leave that out here, as, by default, frames on a text
  terminal have their name set to Fn (where n is a number identifying the
  frame), and we have no reliable way of deciding whether the name has been
  set explicitly, or not; unfortunately, Emacs does not seem to set the
  `explicit-name' frame parameter in a terminal frame, as is the case in a
  graphical frame.

o Lastly, the `icon-name' frame parameter may be used to override both the
  `title' frame parameter and the `icon-title-format' when it comes to
  determining the icon name."
  (terminal-title-set-window-title (format-mode-line (or (frame-parameter nil 'title)
                                                         frame-title-format)))
  (terminal-title-set-icon-name (format-mode-line (or (frame-parameter nil 'icon-name)
                                                      (frame-parameter nil 'title)
                                                      icon-title-format))))

(defun terminal-title-set-window-title (title)
  "Set the window title of the selected frame's terminal to TITLE."
  (if (terminal-title-has-terminal)
      (if (equal (substring (terminal-title-get-terminal-type) 0 5) "xterm")
          (terminal-title-send-string (format "\033]2;%s\007" title)))))

(defun terminal-title-set-icon-name (name)
  "Set the icon name of the selected frame's terminal to NAME."
  (if (terminal-title-has-terminal)
      (if (equal (substring (terminal-title-get-terminal-type) 0 5) "xterm")
          (terminal-title-send-string (format "\033]1;%s\007" name)))))

(defun terminal-title-send-string (string)
  "Send STRING to the selected frame's terminal.
Refrains from sending the string if the selected frame's display is not a
terminal."
  (if (terminal-title-has-terminal)
      (send-string-to-terminal string)))

(defun terminal-title-has-terminal ()
  "Check whether Emacs is running in a terminal.
Returns t if the selected frame's display is a terminal, nil otherwise."
  (if (terminal-title-get-terminal-type) t
    ;; else
    nil))

(defun terminal-title-get-terminal-type ()
  "Retrieve the selected frame's terminal type.
Returns a string representing the selected frame's terminal type (similar
to the environment variable TERM), or nil if the selected frame's display
is not a terminal."
  (if (display-graphic-p) nil
    ;; else
    (frame-parameter nil 'tty-type)))
