#import <sys/socket.h>
#import <netinet/in.h>
#import <sys/types.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <fcntl.h>
#import <unistd.h> 

#import "Sphere.h"
#import "FlatSunAppDelegate.h"
#import "Dimmer.h"

#define BOOST_REQ  (1)
#define DIMMER_REQ (2)
#define SEASON_REQ (3)

typedef char IPAddress[64];

@class FlatSunAppDelegate;

@interface UdpSocket : NSObject {

  IBOutlet Sphere *sphere;
  IBOutlet FlatSunAppDelegate *appDelegate;

  int rxSocket;
  int rxPort;
  char rxBuffer[256];
  int rxSize;
  NSString *rxStr;
  
  int txSocket;	
  int txPort;
  int txSize;
  int txCount;
  int packetsSent;
  
  UInt8 packetI;
  
  int waveI;
  
  NSString *hostIP;
    
  BOOL dataRx;  
}

- (BOOL) ableToConnectTx;
- (void) disconnectTx;
- (BOOL) ableToConnectToHost : (char *) host;

- (BOOL) ableToSendData:(NSData *)data;
- (BOOL) ableToSendString:(NSString *)txString;

- (BOOL) pollRx;

- (void) startListening;
- (void) stopListening;

- (void) setTxPort : (int) newPort;
- (void) setRxPort : (int) newPort;

- (int) txPort;
- (int) rxPort;

- (NSString *) rxStr;

- (void) applyDefaults;

- (BOOL) ableToTxByte : (UInt8) byte;

- (void) txReq : (UInt8) req;
- (void) txReq : (UInt8) req andByte : (UInt8) byte;

- (void) txBuffer : (UInt8 *) buffer withSize : (int) size;
- (void) txBufferQuick : (UInt8 *) buffer withSize : (int) size;

- (void) loadSettings;

@property (nonatomic) BOOL dataRx;

@end