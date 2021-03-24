// This macro generates a trail movie (sliding window time-average)
// - uses active image (a stack) and creates a new stack for result
// Copyright: Graeme Ball (graemeball@googlemail.com)
// License: MIT

macro "Stack profile Plot" {
  activIm = getImageID();
  if (nSlices==1)
    exit("Stack required");
  else
    print("working on image: "+getTitle);

  requires("1.34m");
  title = "makeTrailMovie";
  width=100; height=30;
  Dialog.create("makeTrailMovie");
  Dialog.addNumber("Trail Length:", 5);
  Dialog.show();
  title = Dialog.getString();
  trailLen = Dialog.getNumber();

  print("Using "+nSlices+" slices");
  stopat = nSlices-trailLen+2;

  for (i=1; i<stopat; i++) {
    startval = i;
    stopval = i+trailLen-1;
    print(startval,stopval);
    run("Z Project...", "start="+startval+" stop="+stopval+" projection=[Average Intensity]");
    slicename = "trail"+i;
    rename(slicename);
    selectImage(activIm);

  }
  run("Images to Stack");
}
