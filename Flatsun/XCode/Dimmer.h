#import <Foundation/Foundation.h>
#import "StopWatch.h"

#define BOOST_TRIGGER_VALUE (253) // the value needed to trigger the boost
#define BOOST_ARM_VALUE (0)       // the value needed to re-arm the boost
#define BOOST_VALUE (250)         // the value used in boost mode   
#define BOOST_SECONDS (10.0*60)   // boost lasts for 10 minutes

#define BOOST_UP_SECONDS (1.0)    // fade time when going into boost mode
#define BOOST_DOWN_SECONDS (1.0)  // fade time when leaving boost mode

#define STATIC_SECONDS (0.5)      // fade time when changing static values
#define MAX_STATIC_VALUE (127)


typedef enum DimmerModeEnum {dmStatic=0,dmBoost} DimmerMode;

typedef struct FadeStruct {
  BOOL active;
  double startTime;
  double duration;
  UInt8 startValue;
  UInt8 endValue;
  double fraction;
} Fade;  

typedef struct BoostStruct {
  BOOL active;
  BOOL armed;
  double startTime;
  double remaining;
} Boost;
  
@interface Dimmer : NSObject
{
  IBOutlet NSTextField *fadeTF;
  IBOutlet NSTextField *boostTF;
  IBOutlet NSTextField *valueTF;
  
  DimmerMode mode;
  
  NSTimer *timer;
  
  Fade fade;
  Boost boost;  
  
  UInt8 value;
}  

- (void) update : (UInt8) newValue;
- (void) fadeTo : (UInt8) fadeValue withDuration : (float) duration;

-(void) jumpTo : (UInt8) newValue;


@property (nonatomic) UInt8 value;

@end
