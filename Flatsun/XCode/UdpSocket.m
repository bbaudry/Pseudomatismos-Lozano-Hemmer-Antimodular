#import <sys/socket.h>
#import <netinet/in.h>

#include <sys/types.h>
#include <ifaddrs.h>

#import "UdpSocket.h"

#define kHostIP @"hostIP"

@implementation UdpSocket

@synthesize dataRx;

+ (void) initialize
{
 // [[NSUserDefaults standardUserDefaults] registerDefaults :
  //   [NSDictionary dictionaryWithObjectsAndKeys : @"10.0.5.163", kHostIP, nil]];
}

- (id) init
{
  if (self = [super init]) {
    txPort = 7654;
    rxPort = 8000;
  }  
  return self;
}

- (void) awakeFromNib 
{
  waveI = 0;
  dataRx = NO;  
//  [self loadSettings];
//  hostIP = @"206.248.190.32";
  hostIP = @"10.0.2.2";

//  if ([self ableToConnectTx]) {
//    NSLog(@"Connected to %@", hostIP);   
//  }
//  else NSLog(@"Can''t connect to %@", hostIP);
  [self startListening];
}
  
- (void) loadSettings
{
//  hostIP = [[NSUserDefaults standardUserDefaults] stringForKey : kHostIP]; 
}

- (void) dealloc 
{
  [self disconnectTx];
  [super dealloc];
} 

- (void) setSocketTimeout : (int) iSocket
{
//  struct timeval timeout;
//  timeout.tv_sec = 5;//timeoutSecs;
//  timeout.tv_usec = 0;//timeoutUSecs;
 // socklen_t length = sizeof(struct timeval);
//  setsockopt(iSocket, SOL_SOCKET, SOL_SNDTIMEO, &timeout, &length);
//  setsockopt(iSocket, SOL_SOCKET, SOL_RCVTIMEO, &timeout, &length);
}

- (BOOL) ableToConnectTx
{
// create the BSD socket as a UDP connection
//txSocket = socket(AF_INET, SOCK_STREAM, 0); // tcp
  txSocket = socket(AF_INET, SOCK_DGRAM, 0);   
  if (txSocket < 0) {
    return NO;
  }
	
  else {
		
// initialize the addr structure
    struct sockaddr_in addr;
    bzero(&addr, sizeof(addr));
    
	addr.sin_family = AF_INET;
	addr.sin_port = htons(txPort);

//    char *host = (char *) [hostIP UTF8String];//"10.0.0.228";
 //   char *host = "10.0.0.245";
//    char *host = "206.248.190.32";
//    char *host = "10.0.1.208";
//    char *host = "10.0.5.143";
    char *host = (char *) [hostIP UTF8String];
    
    inet_pton(AF_INET, host, &addr.sin_addr);   
	
// connect
	if (connect(txSocket, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
	  return NO;
  	}
  	else return YES;
  }
}

- (BOOL) ableToConnectToHost : (char *) host
{
  struct sockaddr_in addr;
	
// create the BSD socket as a TCP stream connection
//  txSocket = socket(AF_INET, SOCK_STREAM, 0); 
  txSocket = socket(AF_INET, SOCK_DGRAM, 0);   
  if (txSocket < 0) {
		return NO;
	}
	
	else {
		
// initialize the addr structure
    bzero(&addr, sizeof(addr));
	  addr.sin_family = AF_INET;
	  addr.sin_port = htons(txPort);

    inet_pton(AF_INET, host, &addr.sin_addr);   
	
// connect
	  if (connect(txSocket, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
	    return NO;
  	}
  	else return YES;
	}
}

- (void) disconnectTx
{	
	if (txSocket > 0) {
    close(txSocket);
  }
}

- (void) disconnectRx
{	
	if (rxSocket>0) {
    close(rxSocket);
  }
}

- (BOOL) ableToSendData:(NSData *)data
{
	ssize_t bytesSent;
	int size;
	char *buffer = "Howdy/n";
	
	if (txSocket > 0) {
		size = [data length];
		size = strlen(buffer);
		bytesSent = write(txSocket, buffer, strlen(buffer));
	  return (bytesSent = size);
	}
	else return NO;
}

- (BOOL) ableToSendString:(NSString *)txString
{
	ssize_t bytesSent;
	int size;
	char *buffer;
	
	if (txSocket > 0) {
		buffer = (char *)[txString cString];
		size = strlen(buffer);
		bytesSent = write(txSocket, buffer, size);
	  return (bytesSent = size);
	}
	else return NO;
}

- (void) txReq : (UInt8) req
{
  if ([self ableToConnectTx]) {
    write(txSocket, &req, 1);
    [self disconnectTx];
  }  
}

- (void) txReq : (UInt8) req andByte : (UInt8) byte
{
  if ([self ableToConnectTx]) {
    UInt16 word = (req << 8) + byte;
    write(txSocket, &word, 2);
    [self disconnectTx];
  }  
}

- (BOOL) ableToTxByte : (UInt8) byte
{
	ssize_t bytesSent;
	if ([self ableToConnectTx]) {
  	bytesSent = write(txSocket, &byte, 1);
    [self disconnectTx];
	  return (bytesSent = 1);
	}
	else return NO;
}

- (void) startListening
{
  int error;
  struct sockaddr_in address;
  BOOL yes =  YES;
  
// prepare the socket
  rxSocket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if (rxSocket == -1) {
    NSLog(@"Error creating socket");
    return;
  }  

// set the socket options  
  error = setsockopt(rxSocket, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int));
  if (error == -1) {
    NSLog(@"Error setting sockopt");
    return;
  }  
  
// prepare the address structure  
  address.sin_len = sizeof(struct sockaddr_in);
  address.sin_family = AF_INET;
  address.sin_port = htons(rxPort);
  address.sin_addr.s_addr = htonl(INADDR_ANY);
  memset(address.sin_zero, 0, sizeof(address.sin_zero));
  
// bind the socket to the port
  error = bind(rxSocket, (struct sockaddr *)&address, sizeof(address));
  if (error == -1) {
    NSLog(@"Error binding socket");
    return;
  }    
  
// configure the socket as non-blocking
  error = fcntl(rxSocket, F_SETFL, O_NONBLOCK); 
  if (error == -1) {
    NSLog(@"Error configuring socket as non-blocking");
    return;
  }
}

- (void) setRxString : (NSString *) newStr
{
  [newStr retain];
  [rxStr release];
  rxStr = newStr;
}

- (void) showRxBuffer
{
  NSLog(@"%i bytes rx: ",rxSize);
  for (int i = 0; i < rxSize; i++) {
    NSLog(@"%i",rxBuffer[i]);
  }
  NSLog(@"");
}

- (BOOL) pollRx
{
  fd_set readfds;
  int error;
  static struct timeval timeout = { 0, 0 };
  rxSize = 0;
  
  FD_ZERO(&readfds);
  FD_SET(rxSocket, &readfds);
  
  error = select(rxSocket + 1, &readfds, NULL, NULL, &timeout);
  if (error == -1) {
    NSLog(@"Error polling socket");
    return NO;
  }
  
// see if anybody is there
  if  (FD_ISSET(rxSocket, &readfds)) {
      
// read the data  
    rxSize = read(rxSocket, &rxBuffer[0], 255);
    if (rxSize == -1) {
      NSLog(@"Error reading socket");
      fprintf(stderr, "Read failed. error: %d / %s\n", errno, strerror(errno));
      return NO;
    }
    else {
      dataRx = YES;   
      UInt8 cmd = rxBuffer[0];
      
      switch (cmd) {
      
        case BOOST_REQ :
          if (rxSize == 1) {
            [appDelegate setDimmerBoostFromUdp];
 //           [appDelegate setDimmer : BOOST_TRIGGER_VALUE];
          }
          break;
          
        case DIMMER_REQ :
          if (rxSize == 2) {
            UInt8 dimmer = rxBuffer[1];
            [appDelegate setDimmerFromUdp : dimmer];
          }
          break;
          
        case SEASON_REQ :
          if (rxSize == 2) {
            UInt8 season = rxBuffer[1];
            sphere.seasonI = season;
          }
          break;
      }
      return YES;
    }
  }
  return NO;  
}

- (void) stopListening
{ 
  if (rxSocket > 0) {
    close(rxSocket);
  }   
}

- (void) setRxPort : (int) newPort
{
  rxPort = newPort;
}

- (void) setTxPort : (int) newPort
{
  txPort = newPort;
}

- (NSString *) rxStr
{
  return rxStr;
}

- (int) txPort { return txPort; }

- (int) rxPort { return rxPort; }

- (void) applyDefaults 
{
  rxPort = 4000; 
  txPort = 2011;
}

#define MAX_SIZE (2500)
- (void) txBuffer : (UInt8 *) buffer withSize : (int) size
{
  if ([self ableToConnectTx]) {
    
    UInt8 *data = buffer;
    while (size > 0) {
    
// write MAX_SIZE bytes    
      if (size > MAX_SIZE) {
    	write(txSocket, data, MAX_SIZE);
          
        size -= MAX_SIZE;
        data += MAX_SIZE;
      }
      
// write all of it      
      else {
        write(txSocket, buffer, size);
        size = 0;
      }
    }  
    [self disconnectTx];
  }
}

- (void) txBufferQuick : (UInt8 *) buffer withSize : (int) size
{
  if (txSocket > 0) {
    UInt8 *data = buffer;
    while (size > 0) {
    
    
// write MAX_SIZE bytes    
      if (size > MAX_SIZE) {
     	write(txSocket, data, MAX_SIZE);
        size -= MAX_SIZE;
        data += MAX_SIZE;
      }
      
// write all of it      
      else {
        write(txSocket, buffer, size);
        size = 0;
       }
    }  
  }
  else NSLog(@"txSocket = 0");
}

@end

