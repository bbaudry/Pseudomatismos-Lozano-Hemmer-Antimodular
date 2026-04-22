#import "ITable.h"

@implementation ITable

@synthesize xo;
@synthesize yo;
@synthesize scale;
@synthesize power;
@synthesize radius;

@synthesize width;
@synthesize height;

- (id) init
{
  if (self = [super init]) {
    [self load];
    xo = 320;
    yo = 240;
    scale = 1.0;
    power = 1.0;
    radius = 100.0;
    width = 640;
    height = 480;
  }
  return self;
}

- (NSString *) appPath
{
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *appName = [bundle bundlePath];
  NSString *appFolder = [appName stringByDeletingLastPathComponent];
  return appFolder;
}

- (NSString *) tableFileName
{
  NSString *appFolder = [self appPath];
  NSString *result;
  result = [NSString stringWithFormat : @"%@/Table.dat", appFolder];
  return result;
}

- (unsigned long)fileSize:(NSString *)fileName
{
  NSDictionary *attributes;
  NSFileManager *fm = [NSFileManager defaultManager];
  attributes = [fm fileAttributesAtPath : fileName traverseLink : NO];
  
  NSNumber *size = [attributes objectForKey:NSFileSize];
  unsigned long result = [size unsignedLongValue];
  return result;  
}

- (BOOL) fileSizeOk:(NSString *)fileName 
{
  unsigned long size = [self fileSize:fileName];
  unsigned long expectedSize = sizeof(ITableType);
  BOOL result = (size == expectedSize);
  return result; 
}

- (void) setToUnity
{
  for (int y = 0; y < TABLE_H; y++) {
    for (int x = 0; x < TABLE_W; x++) {
      for (int i = 0; i < 256; i++) {
        table[x][y][i] = i;
      }  
    }
  }
}

- (void) load
{
  NSString *fileName = [self tableFileName];
  NSFileManager *fm = [NSFileManager defaultManager];

// make sure the file exists first
  if (![fm fileExistsAtPath:fileName]) {
    NSString *title;
    title = [NSString stringWithFormat:@"Intensity compensation file %@ not found",fileName];
    NSRunAlertPanel(title,@"Default settings will be used.",@"Ok",nil,nil); 
    [self setToUnity];
  }
  
// check the file size
  else if (![self fileSizeOk:fileName]) {
    NSString *title;
    title = [NSString stringWithFormat:@"%@ is the wrong size",fileName];
    NSRunAlertPanel(title,@"Default settings will be used.",@"Ok",nil,nil); 
    [self setToUnity];
  }

// we're ok - read the file  
  else {
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:fileName]; 
    NSData *data = [fh readDataToEndOfFile];
    [fh closeFile];
    memcpy(&table, [data bytes], sizeof(ITableType));
  }
}

- (void) save
{
  NSString *fileName = [self tableFileName];
  NSFileManager *fm = [NSFileManager defaultManager];

// create it if it doesn't exist  
  [fm createFileAtPath:fileName contents:nil attributes:nil];
 
// open it for writing 
  NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:fileName]; 
  
// copy the data into the NSData object
  int size = sizeof(table);
  
  NSData *data = [NSData dataWithBytes : &table length : size];
  
  [fh writeData : data];
  [fh closeFile];
}

// calculates the table from the vars
- (void) calculate
{
  float d, dx2, dy2;
  float f;
  int v;
  UInt8 vb;
  
  int w = width;
  int h = height;
  
  for (int y = 0; y < h; y++) {
    dy2 = (y-yo)*(y-yo);
    for (int x = 0; x < w; x++) {
      dx2 = (x-xo)*(x-xo);
      
// calculate the distance to the center pixel      
      d = sqrt(dx2+dy2);
      
// find this as an inverse fraction      
      f = (radius - d) / radius;
      
// apply the scale      
      f = scale * f;
      
// apply the power
      f = powf(f, power);
      
// clip it to the valid range
//      if (f < 0.0) f = 0.0;      // don't amplify only attenuate
//      else if (f > 1.0) f = 1.0; // don't influence outside our radius     
      
// calculate the table lookup value for all the possible intensities
      for (int i = 0; i < 256; i++) {
      
// don't influence outside our radius       
        if (d > radius) vb = i;
        else {
          v = i * (1.0 - f);
          if (v < 0) vb = 0;
          else if (v > i) vb = i;
          else vb = round(v);
        }       
        table[x][y][i] = vb;
      }  
    }
  }
}


- (IBAction) calculateBtnClicked : (id)sender
{  
// set the width and height from the camera
  width = camera.imageW;
  height = camera.imageH;
  
// calculate the table  
  [self calculate];
  
// save it
  [self save];  
}

- (void) initFromData : (UInt8 *) data withWidth : (int) w andHeight : (int) h
{
  UInt8 *dataPtr = data;
  float sum;
  UInt8 v;
  
 // sum all the pixels 
  sum = 0;
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      for (int i = 0; i < 3; i++) {
        v = *dataPtr;
        sum += v;
        dataPtr++;
      }
    }
  }      

// find the average r+g+b value
  float avg = sum / (w * h);

// loop throught the pixels again
#define MAX_SCALE (10)
  float s;
  dataPtr = data;  
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
    
// find the scale for this pixel
      sum = 0;
      for (int i = 0; i < 3; i++) {
        v = *dataPtr;
        sum += v;
        dataPtr++;
      }
      if (sum == 0) s = MAX_SCALE;
      else s = avg / sum; 
      
// calculate all the values
      for (int i = 0; i < 256; i++) {
        float vs = s * i;
        UInt8 vb;

        if (vs <= 255) vb = round(vs);
        else vb = 255;
        
        table[x][y][i] = vb;
      }      
    }
  }      
}

- (void) processData : (UInt8 *) srcData withWidth : (int) w andHeight : (int) h  toDest : (UInt8 *) destData
{
  UInt8 *srcPtr = srcData;
  UInt8 *destPtr = destData;
  UInt8 v;
  UInt8 vt;

// loop through the pixels  
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
    
// loop through the RGB components    
      for (int i = 0; i < 3; i++) {
      
// look up this components scaled value in the table      
        v = *srcPtr;
        vt = table[x][y][v];
        
// set the destination component        
        *destPtr = vt;
        
// select the next RGB component        
        srcPtr++;
        destPtr++;
      }
    }
  }      
}

@end
