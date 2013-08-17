// http://imagej.1557.n6.nabble.com/Gamma-correction-slider-td3689970.html

importClass(Packages.ij.WindowManager) 
importClass(Packages.ij.gui.GenericDialog) 
importClass(Packages.ij.process.ImageProcessor) 
importClass(Packages.java.awt.event.AdjustmentListener) 

var image = WindowManager.getCurrentImage(); 
if (image != null) { 
        var ip = image.getProcessor(); 
        ip.snapshot(); 
        
        var dialog = GenericDialog("Gamma (1.0)"); 
        dialog.addSlider("gamma", 1, 500, 100); 
        dialog.getNumericFields().lastElement().setVisible(false); 
        var scrollbar = dialog.getSliders().lastElement(); 
        dialog.add(scrollbar); 
        var listener = new AdjustmentListener ({ 
                adjustmentValueChanged : function(event) { 
                        var value = scrollbar.getValue() / 100.0; 
                        dialog.setTitle("Gamma (" + value + ")"); 
                        ip.reset(); 
                        ip.snapshot(); 
                        ip.gamma(value); 
                        image.updateAndDraw(); 
                } 
        }); 
        scrollbar.addAdjustmentListener(listener); 
        dialog.showDialog(); 
        if (dialog.wasCanceled()) { 
                ip.reset(); 
                image.updateAndDraw(); 
        } 
}
