#import "Serial.h"
#include <termios.h>
#include <sys/ioctl.h>

@implementation Serial

@synthesize rxValue;

- (id) init
{
  if (self = [super init]) {
    fd = -1;
    switchOn = NO;  
  }  
  return self;
}

- (void) awakeFromNib
{
}

- (void) dealloc
{
//  [self closePort];
  [super dealloc];
}

- (NSString *) driverFileName
{
  return [NSString stringWithString : @"/dev/tty.usbmodem00001"];

/*  NSFileManager *fm = [NSFileManager defaultManager];
  NSArray *contents = [fm directoryContentsAtPath:@"/dev/"];
  NSString *fileName;
  int  i = 0;
  BOOL found = NO;
  NSRange range;
  while ((!found) && (i < [contents count])) {
    fileName = [contents objectAtIndex:i];
    range = [fileName rangeOfString:@"tty.usbmodem"];
    if (range.length > 0) found = YES;
    else i++;
  }
  if (found) return [NSString stringWithFormat:@"/dev/%@",fileName];
  else return nil;
  */
}  

- (BOOL) opened
{
  return (fd != -1);
}

- (BOOL) ableToOpenPort
{
  int error;
  struct termios options;
  
//  fd = open("/dev/tty.usbserial-DP3W5E11", O_RDWR | O_NOCTTY | O_NDELAY);
  NSString *driverFile = [self driverFileName];
  if (!driverFile) return NO;
  fd = open([driverFile cString], O_RDWR | O_NOCTTY | O_NDELAY);
  if (fd == -1) return NO;
  
  error = fcntl(fd, F_SETFL, FNDELAY); // set read to be non-blocking
  if (error == -1) {
    NSLog(@"Error setting serial port fcntl");
    return NO;
  }
  
// Get the current options and save them for later reset
  error = tcgetattr(fd, &options);
  if (error == -1) {
    NSLog(@"Error getting serial port attributes");
    return NO;
  }
    
// Set raw input, one second timeout
// These options are documented in the man page for termios
// (in Terminal enter: man termios)
  options.c_cflag |= (CLOCAL | CREAD | CS8);
  options.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
  options.c_oflag &= ~OPOST;
  options.c_cc[ VMIN ] = 1;
  options.c_cc[ VTIME ] = 0;
    
// RTS-CTS
//  options.c_cflag |= CRTSCTS;
  options.c_iflag &= ~(IXON | IXOFF | IXANY);
  options.c_iflag |= IGNPAR | IGNBRK;
    
  cfsetospeed(&options,B115200);
  cfsetispeed(&options,B115200);
    
    
// Set the options
  error = tcsetattr(fd, TCSANOW, &options);
  if (error == -1) {
    NSLog(@"Error setting serial port attributes");
    return NO;
  }
  return YES;
}

- (void) closePort
{
  if (fd != -1) close(fd);
}

- (BOOL) pollRx
{
//return NO;
  if (fd != -1) {
    UInt8 buffer[16];
    UInt8 value;
    int count = 0;
    @try {
      count = read(fd, &buffer[0], 16);
    }
    @catch(NSException *exception) {
    }
    if (count <= 0) return NO;
    
    value = buffer[count-1];
    value = buffer[count-2];
    
    if (buffer[count-3] != 13) return NO;
    if (buffer[count-2] != 10) return NO;
    if (buffer[count-1] != 32) return NO;
    
       
    NSString *rxStr = [NSString stringWithCString : &buffer[0] length : count-3];
//    NSLog(rxStr);


        
// convert from our ascii string to a binary value
    int rxInt = [rxStr intValue];
  //  sscanf(&buffer[0], "%i", rxInt);
    rxValue = (UInt8) rxInt;
    return YES;
      
  }
  else return NO;  
}

/* while ((count == 1 ) & (value != 10)) {
      count = read(fd, &value, 1); 
    }
    if (value != 10) return NO;
          
    UInt8 buffer[5];  
    UInt8 i = 0;  
    while ((count == 1) & (value != 13) & (i < 4)) {
      count = read(fd, &value, 1);
      if (value == 32) continue; // Space
      buffer[i++] = value;
    }
    if (count <= 0) return NO;
    
    buffer[i] = 0;

#if 0
    for (int x=0; x < i; x++) {
      NSLog(@"char[%i] = %i", x, buffer[x]);
    }  
#endif
*/

- (void) flushBuffer
{
    if (tcflush(fd, TCIOFLUSH) != 0) {
        NSLog(@"Error flushing serial buffer");
    }
}

- (void) requestData
{
  [self sendSingleByteCmd : 7];
}  

- (void) sendSingleByteCmd : (unsigned char) cmd
{
  if (fd != -1) {
    unsigned char buffer[1];
    buffer[0] = cmd;
    @try {
      write(fd, &cmd, 1);
    }
    @catch(NSException *exception) {
    }
  }
}

- (BOOL) found
{
  return (fd != -1);
}

- (BOOL) switchOn
{
  return switchOn;
}

@end
