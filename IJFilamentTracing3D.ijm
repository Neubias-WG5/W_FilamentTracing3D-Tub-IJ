// Author: Sébastien Tosi (IRB Barcelona)
// Version: 1.0
// Date: 18/12/2019

// Path to input and output images
inputDir = "/dockershare/667/in/";
outputDir = "/dockershare/667/out/";

// Functional parameters
Scale = 1;
Thr = 5;

arg = getArgument();
parts = split(arg, ",");

setBatchMode(true);

for(i=0; i<parts.length; i++) {
	nameAndValue = split(parts[i], "=");
	if (indexOf(nameAndValue[0], "input")>-1) inputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "output")>-1) outputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "Scale")>-1) Scale=nameAndValue[1];
	if (indexOf(nameAndValue[0], "Thr")>-1) Thr=nameAndValue[1];
}

images = getFileList(inputDir);

for(i=0; i<images.length; i++) {
	image = images[i];
	if (endsWith(image, ".tif")) {
		// Workflow
		run("Tubeness", "sigma="+d2s(Scale,2));
		run("Maximum 3D...", "x=2 y=2 z=2");
		run("Minimum 3D...", "x=2 y=2 z=2");
		Stack.getStatistics(voxelCount, mean, min, max);
		setThreshold(Thr, max);
		setOption("BlackBackground", false);
		run("Convert to Mask", "method=Default background=Light");
		run("Skeletonize (2D/3D)");
		run("Invert LUT");
		// Save output image
		save(outputDir + "/" + image);		
		// Cleanup
		run("Close All");
	}
}

run("Quit");