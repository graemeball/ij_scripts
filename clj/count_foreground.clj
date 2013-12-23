; Auto-threshold current image and log foreground pixel count
; Graeme Ball (2013)
; Public Domain (CC0)
;
(import '(ij WindowManager))
(import '(ij IJ))
(def imp (. WindowManager getCurrentImage))
(. IJ run imp "Make Binary" "")
(def nnonzero 
  ((fn count-nonzero [imp] 
    (count
      (filter #(not (zero? %))
        (. (. imp getProcessor) getPixels)))) imp))
(. IJ log (str "number of foreground pixels: " nnonzero))
