; example script from fiji wiki that displays an image

(import '(ij IJ))
(def gold (IJ/openImage "http://rsb.info.nih.gov/ij/images/AuPbSn40.jpg"))
(.show gold)
