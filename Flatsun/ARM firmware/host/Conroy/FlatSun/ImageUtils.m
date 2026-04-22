#import "ImageUtils.h"
#import "Routines.h"

@implementation ImageUtils

+ (void) drawText:(NSString *)text onBmpImage:(NSBitmapImageRep *)image
{	
  Str255 pString;
  
// copy it into a pascal string  
  CopyCStringToPascal([text cString], pString);
  
// prepare to draw  
//  [image lockFocus];	
  TextSize(12);
  TextMode(srcCopy);
  MoveTo(10, 20);
  
// draw it  
  DrawString(pString);
//  [image unlockFocus];
}

+ (void) fillImage:(NSImage *) image withColor:(NSColor *)color
{	
	
}

+ (void) flipBmpImageVertically:(NSBitmapImageRep *) image 
{
  unsigned char *data, *upLine, *downLine;
  int i;
  int bpr = [image bytesPerRow];
 	int h = [image pixelsHigh];
  int halfHeight = (int) (h/2);
  unsigned char *tempLine;
  tempLine = malloc(bpr); 
    
  data = [image bitmapData];
  upLine = data;
  downLine = data + (h - 1) * bpr;
  for (i = 0; i < halfHeight; i++) {
    memcpy(tempLine, downLine, bpr); 
    memcpy(downLine, upLine, bpr);
    memcpy(upLine, tempLine, bpr);
    upLine += bpr;
    downLine -= bpr;
  };
  free(tempLine);
}

+ (unsigned char) intensityOfBmpImage:(NSBitmapImageRep *)image atX:(int)x y:(int)y
{
  if ((x > [image pixelsWide]) || (y > [image pixelsHigh])) {
    return 0;
  }
	unsigned char *data;
	int offset;
  int bpr = [image bytesPerRow];
  int h = (int) [image size].height;
	
	data = [image bitmapData];
	offset = ((h-1-y) * bpr) + (x * 3);
	unsigned char result;
	result = *(data + offset);
	return result;
}

+ (unsigned char) intensityOfBmpImage:(NSBitmapImageRep *)image atPoint:(NSPoint)point
{
  unsigned char result;
  int x = (int) point.x;
  int y = (int) point.y;
  result = [ImageUtils intensityOfBmpImage:image atX:x y:y];
  return result;
}

+ (void) thresholdBmpImage:(NSBitmapImageRep *)image withValue:(int)threshold
{
	unsigned char *data;
	int i,size;
  int bpr = [image bytesPerRow];
	int h = [image pixelsHigh];
  data = [image bitmapData];
	
	size = bpr * h; 
	for (i = 0; i < size; i++) {
		if (*(data+i) < threshold) {
	    *(data+i) = 0;
	  }
	}
}	

+ (void) absSubtractBmpImage : (NSBitmapImageRep *) image1
                   fromImage : (NSBitmapImageRep *) image2
                   ontoImage : (NSBitmapImageRep *) destImage
{
	int bpr = [image1 bytesPerRow];
	int x,y;
	int offset;
	int d,v1,v2;
	unsigned char *data1 = [image1 bitmapData];
	unsigned char *data2 = [image2 bitmapData];
	unsigned char *destData = [destImage bitmapData];
  int w = (int) [image1 size].width;
  int h = (int) [image1 size].height;
	
	for (y = 0; y < h; y++) {
    offset = y * bpr;
		for (x = 0; x < w; x++) {
			v1 = *(data1 + offset);
			v2 = *(data2 + offset);
			if (v1 > v2) { d = v1 - v2; }
			else { d = v2 - v1; }
			*(destData + offset) = d;
			*(destData + offset + 1) = d;
			*(destData + offset + 2) = d;
			offset = offset + 3;
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
// Magnify copies a small (+/- range) square region in the srcBmp 
////////////////////////////////////////////////////////////////////////////////
+ (void) magnifyCopyBmp : (NSBitmapImageRep *) srcBmp
              ontoImage : (NSImage *) destImage 
                      x : (int) x
                      y : (int) y
                  range : (int) range
               gridSize : (int) gridSize  
              
{  
  int cellW, cellH;
  int xb, yb, xl, yl;
  int xd, yd, xs, ys;
  int srcW, srcH;
  int destW, destH;
  NSRect destRect;
  BOOL topMark, bottomMark, leftMark, rightMark;
  NSColor *srcColor;
  
// find the width and height of the src bmp image
  NSSize srcSize = [srcBmp size];
  srcW = (int) srcSize.width;
  srcH = (int) srcSize.height;
  
// find the width and height of the dest image
  NSSize destSize = [destImage size];
  destW = (int) destSize.width;
  destH = (int) destSize.height;

// find the size of the magnified pixels
  int gridPixels = (range * 1) * 2;
  cellW = (destW - gridPixels * gridSize) / ((range * 2) + 1); 
  cellH = (destH - gridPixels * gridSize) / ((range * 2) + 1);
  int cellSize;
  if (cellW < cellH) cellSize = cellW;
  else cellSize = cellH;
//  int cellSize = minInt(cellW, cellH); 
  int cells = (range * 2) + 1;
  int cellPixels = cellSize * cells;
  
// find the x and y borders
  xb = (int) ((destW - (gridPixels + cellPixels)) / 2);   
  yb = (int) ((destH - (gridPixels + cellPixels)) / 2); 

// enable drawing on the image
  [destImage lockFocus];
  
// clear it
  [[NSColor blackColor] set];
  
  destRect = NSMakeRect(0, 0, destW, destH);
  [NSBezierPath fillRect:destRect];
  
// draw the pixels     
  yd = yb;
  for (yl = + range; yl >= -range; yl--) {
    ys = (srcH - 1) - (y + yl);
    xd = xb;
    for (xl = - range; xl <= range; xl++) {     
      xs = x + xl;
      
// the four xhair pixels are green
      topMark = (xl == 0) && (yl == range);
      bottomMark = (xl == 0) && (yl == -range);
      leftMark = (yl == 0) && (xl == -range);
      rightMark = (yl == 0) && (xl == range);
      if (topMark || bottomMark || leftMark || rightMark) {  
        [[NSColor greenColor] set];
      }          
    
// if the source pixel's out of bounds set the color to black    
      else if ((xs < 0) || (xs >= srcW) || (ys < 0) || (ys >= srcH)) {
        [[NSColor blackColor] set];
      }
      
// otherwise copy the color from the corresponding pixel
      else {
        srcColor = [srcBmp colorAtX:xs y:ys];
        [srcColor set];
      }
      
// find the dest rect for the pixel
      destRect = NSMakeRect(xd, yd, cellW, cellH);
      
// fill it with the source color   
      [NSBezierPath fillRect:destRect];   

// continue...
      xd = xd + cellW + gridSize;  
    }   
    yd = yd + cellH + gridSize;
  } 
  
// restore the previous graphics context  
  [destImage unlockFocus];
}                    
       
+ (void) drawBmp : (NSBitmapImageRep *) srcBmp 
           onBmp : (NSBitmapImageRep *) destBmp
{
  unsigned char *srcPtr = [srcBmp bitmapData];
  unsigned char *destPtr = [destBmp bitmapData];
  int size = [srcBmp bytesPerRow] * [srcBmp pixelsHigh]; 
  memcpy(destPtr, srcPtr, size);
}                  

+ (void) showFPS:(float)fps
{
  char    cString[16];
  Str255	pString;

// format the fps into a c-string
  sprintf(cString, "%2.1f", fps);
  
// copy it into a pascal string  
  CopyCStringToPascal(cString, pString);
  
// prepare to draw  
  TextSize(12);
  TextMode(srcCopy);
  MoveTo(10, 20);
  
// draw it  
  DrawString(pString);
}

+ (NSBitmapImageRep *) CreateBmpWithWidth : (int) w andHeight : (int) h
{
  int BPP = 3;
  
  NSBitmapImageRep *result;
  result = [[NSBitmapImageRep alloc] 
                 initWithBitmapDataPlanes : NULL
                               pixelsWide : w
                               pixelsHigh : h
                            bitsPerSample : 8
                          samplesPerPixel : BPP
                                 hasAlpha : (BPP == 4)
                                 isPlanar : NO
                           colorSpaceName : NSDeviceRGBColorSpace
                             bitmapFormat : 0
                              bytesPerRow : (w * BPP)
                             bitsPerPixel : BPP * 8];
  return result;                             
}                   

@end
