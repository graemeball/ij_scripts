; Graeme Ball, 2013
; A Test Clojure plugin

;(ns test.TestClj
;    (:import (ij ImagePlus)
;        (ij.Process.*))
;    (:gen-class
;     :implements ij.plugin.PlugIn
;     ; Specify methods to expose as public,
;     ; with specific parameter types and return type:
;     :methods [[run [] void]]
;     ; Define a function prefix for the exposed methods
;     :prefix "pub-"))    
  
(import '(ij IJ))
(def gold (IJ/openImage "http://rsb.info.nih.gov/ij/images/AuPbSn40.jpg"))
(.show gold)