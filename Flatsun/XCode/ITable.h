#import <Cocoa/Cocoa.h>
#import "Camera.h"

#define TABLE_W (640)
#define TABLE_H (480)

typedef UInt8 ITableType[TABLE_W][TABLE_H][256];

@class Camera;

@interface ITable : NSObject
{
  IBOutlet Camera *camera;

  ITableType table;  
  
  int xo, yo;
  float scale;
  float power;
  float radius;
  int width;
  int height; 
}

- (IBAction) calculateBtnClicked : (id) sender;

- (void) calculate;

- (void) setToUnity;
- (void) load;
- (void) save;

- (void) processData : (UInt8 *) srcData withWidth : (int) w andHeight : (int) h  toDest : (UInt8 *) destData;

- (void) initFromData : (UInt8 *) data withWidth : (int) w andHeight : (int) h;

@property (nonatomic) int xo;
@property (nonatomic) int yo;
@property (nonatomic) float scale;
@property (nonatomic) float power;
@property (nonatomic) float radius;

@property (nonatomic) int width;
@property (nonatomic) int height;

@end
