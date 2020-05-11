
// Size of the ROI
ROI_size = 256;

// Positions
x0 = 280;
y0 = 140;

x1 = 610;
y1 = 400;

x2 = 220;
y2 = 450;

// Number of frames per move between (xi,yi) --> (xi+1, yi+1)
nFrames = 50;

// "Sharpness" of the easing
beta = 30;

// ------------------ Code starts here ------------------
title = getTitle();
setBatchMode(true);

selectWindow(title);
ROImoveEasing(x0, y0, x1, y1, ROI_size, nFrames, beta);
rename("Movie_1");

selectWindow(title);
ROImoveEasing(x1, y1, x2, y2, ROI_size, nFrames, beta);
rename("Movie_2");

selectWindow(title);
ROImoveEasing(x2, y2, x0, y0, ROI_size, nFrames, beta);
rename("Movie_3");

run("Concatenate...", "  title=MainMovie image1=Movie_1 image2=Movie_2 image3=Movie_3 image4=[-- None --]");
setBatchMode("exit and display");



function logisticFunction(x, beta) {
	return 1.0/(1.0 + Math.exp(beta*(0.5-x)));
}


function ROImoveEasing(x0, y0, x1, y1, ROI_size, nFrames, beta){
	title = getTitle();
	run("Select None");
	getDimensions(width, height, channels, slices, frames);
	run("Duplicate...", "title=DataRGB");
	run("RGB Color");

	for (i = 0; i < nFrames; i++) {
		selectWindow("DataRGB");
		run("Select None");
		run("Duplicate...", "title=Movie_frame_"+i);
		makeRectangle(x0 + logisticFunction(i/(nFrames-1), beta)*(x1-x0), y0 + logisticFunction(i/(nFrames-1), beta)*(y1-y0), ROI_size, ROI_size);
		run("Duplicate...", "title=ROI_frame_"+i);
		run("Select All");
		run("Draw", "slice");
		selectWindow("Movie_frame_"+i);
		run("Draw", "slice");
		run("Select All");
		run("Draw", "slice");
	}


	close("DataRGB");
	run("Images to Stack", "name=Movie_full_FOV title=Movie_frame_ use");
	run("Images to Stack", "name=Movie_ROI title=ROI_frame_ use");
	run("Size...", "width="+width+" height="+height+" depth="+nFrames+" constrain average interpolation=None");
	run("Combine...", "stack1=Movie_full_FOV stack2=Movie_ROI");
	rename("ROImove");
}
