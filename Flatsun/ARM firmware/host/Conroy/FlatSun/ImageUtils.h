#import <Cocoa/Cocoa.h>
#import "Global.h"

@interface ImageUtils : NSObject {

}

+ (void) drawText:(NSString *)text onBmpImage:(NSBitmapImageRep *)image;
+ (void) fillImage:(NSImage *)image withColor:(NSColor *)color;
+ (unsigned char) intensityOfBmpImage:(NSBitmapImageRep *)image atX:(int)x y:(int)y;
+ (unsigned char) intensityOfBmpImage:(NSBitmapImageRep *)image atPoint:(NSPoint)point;
+ (void) thresholdBmpImage:(NSBitmapImageRep *)image withValue:(int)threshold;

+ (void) absSubtractBmpImage : (NSBitmapImageRep *) image1
                   fromImage : (NSBitmapImageRep *) image2
                   ontoImage : (NSBitmapImageRep *) destImage;
                   
+ (void) flipBmpImageVertically:(NSBitmapImageRep *) image;

+ (void) magnifyCopyBmp : (NSBitmapImageRep *) srcBmp
              ontoImage : (NSImage *) destImage 
                      x : (int) x
                      y : (int) y
                  range : (int) range
               gridSize : (int) gridSize;
               
+ (void) drawBmp : (NSBitmapImageRep *) srcBmp 
           onBmp : (NSBitmapImageRep *) destBmp;  
           
+ (void) showFPS:(float)fps;         

+ (NSBitmapImageRep *) CreateBmpWithWidth : (int) w andHeight : (int) h;

                        
@end

