; imglib2 scripting using clojure: opens and shows an image
; Graeme Ball (2013)
; Public Domain (CC0)

(import ij.IJ)
(import net.imglib2.img.Img)
(import io.scif.img.ImgOpener)
(import net.imglib2.img.display.imagej.ImageJFunctions)

(def img (.openImg (new ImgOpener) "/Users/graemeb/Documents/testData/Lena.tif"))
(def i (.iterator img))
(. ImageJFunctions show img)
