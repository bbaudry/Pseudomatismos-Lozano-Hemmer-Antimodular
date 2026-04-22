#import "FlatSunAppDelegate.h"

//sleep button stuff begin
#import <IOKit/ps/IOPowerSources.h>
#import <IOKIt/ps/IOPSKeys.h>

#include <IOKit/pwr_mgt/IOPMLib.h>
#include <IOKit/IOMessage.h>

#include <stdio.h> 
#include <CoreServices/CoreServices.h>
#include <Carbon/Carbon.h>

#define kAutoChangeSeasons @"AutoChangeSeasons"
#define kMinSeasonSeconds @"MinSeasonSeconds"
#define kMaxSeasonSeconds @"MaxSeasonSeconds"

#define kSwingTime @"SwingTime"

#define kTransitionPercent @"TransitionPercent"

static OSStatus SendAppleEventToSystemProcess(AEEventID EventToSend);

//sleep button stuff begin
// code from apple forum <http://developer.apple.com/qa/qa2001/qa1134.html> 
// also has info for ->The specific Apple events sent to initiate system restart, shutdown, logout or sleep are kAERestart, kAEShutDown, kAEReallyLogOut or kAESleep, respectively.
OSStatus SendAppleEventToSystemProcess(AEEventID EventToSend)
{
  AEAddressDesc targetDesc;
  static const ProcessSerialNumber kPSNOfSystemProcess = { 0, kSystemProcess };
  AppleEvent eventReply = {typeNull, NULL};
  AppleEvent appleEventToSend = {typeNull, NULL};
	
  OSStatus error = noErr;
	
  error = AECreateDesc(typeProcessSerialNumber, &kPSNOfSystemProcess, 
              				 sizeof(kPSNOfSystemProcess), &targetDesc);
	
  if (error != noErr) {
    return(error);
  }
	
  error = AECreateAppleEvent(kCoreEventClass, EventToSend, &targetDesc, 
					   kAutoGenerateReturnID, kAnyTransactionID, &appleEventToSend);
	
  AEDisposeDesc(&targetDesc);
  if (error != noErr) {
    return(error);
  }
	
  error = AESend(&appleEventToSend, &eventReply, kAENoReply, 
    		   kAENormalPriority, kAEDefaultTimeout, NULL, NULL);
	
  AEDisposeDesc(&appleEventToSend);
  if (error != noErr) {
    return(error);
  }
	
  AEDisposeDesc(&eventReply);
	
  return(error); 
}

void MySleepCallBack( void * refCon, io_service_t service, natural_t messageType, void * messageArgument)
{
  FlatSunAppDelegate *app = (FlatSunAppDelegate *)(refCon);
//  printf( "messageType %08lx, arg %08lx\n",(long unsigned int)messageType,(long unsigned int)messageArgument );
	
	if (messageType == kIOMessageCanSystemSleep) {
      app.window.title = @"Sleeping..."; 
      [app playSound : @"Sleep"];
  
// Idle sleep is about to kick in. This message will not be sent for forced sleep.
//		 Applications have a chance to prevent sleep by calling IOCancelPowerChange.
//		 Most applications should not prevent idle sleep.
//		 
//		 Power Management waits up to 30 seconds for you to either allow or deny idle sleep.
//		 If you don't acknowledge this power change by calling either IOAllowPowerChange
//		 or IOCancelPowerChange, the system will wait 30 seconds then go to sleep.
//		 
		
    //    io_connect_t root_port;    
	//	IOCancelPowerChange( root_port, (long)messageArgument );
        
    //    OSStatus error1 = noErr; 
    //    error1 = SendAppleEventToSystemProcess(kAEShutDown);
	
    
// we will allow idle sleep
		//IOAllowPowerChange( root_port, (long)messageArgument );
 	}
	
	if (messageType ==  kIOMessageSystemWillSleep){
    app.window.title = @"Will sleep";
  
//	The system WILL go to sleep. If you do not call IOAllowPowerChange or
//		 IOCancelPowerChange to acknowledge this message, sleep will be
//		 delayed by 30 seconds.
//		 
//		 NOTE: If you call IOCancelPowerChange to deny sleep it returns kIOReturnSuccess,
//		 however the system WILL still go to sleep. 
//		
		
    io_connect_t root_port;       
    IOCancelPowerChange(root_port, (long) messageArgument);
//  IOAllowPowerChange( root_port, (long)messageArgument );
		
		OSStatus error1 = noErr;
		
		NSLog(@"Power button was hit");
		
		error1 = SendAppleEventToSystemProcess(kAEShutDown);
		if (error1 == noErr) {
      [app playSound : @"ShutDown"];
			printf("Computer is going to shutdown!\n");
      app.window.title = @"Shutting down...";
      exit(0);
		}
		else{
			printf("Computer wouldn't shutdown\n");
		}
		
	}

//System has started the wake up process...
  if (messageType ==  kIOMessageSystemWillPowerOn) {
		printf( "System has started the wake up process \n");
	}

//System has finished waking up...
	if (messageType ==  kIOMessageSystemHasPoweredOn) {
		printf( "System has finished waking up \n");
	}
}

@implementation FlatSunAppDelegate

@synthesize window;

@synthesize autoChangeSeasons;
@synthesize minSeasonSeconds;
@synthesize maxSeasonSeconds;
@synthesize transitionPercent;

- (void)awakeFromNib 
{
  [self playSound : @"Sleep"];
  
// sleep button 
  IONotificationPortRef  notifyPortRef; // notification port allocated by IORegisterForSystemPower
  io_object_t notifierObject;           // notifier object, used to deregister later
	
// register to receive system sleep notifications
  io_connect_t root_port; // a reference to the Root Power Domain IOService
  root_port = IORegisterForSystemPower(self, &notifyPortRef, MySleepCallBack, &notifierObject);
  if (root_port == 0) {
    printf("IORegisterForSystemPower failed\n");
  }

// add the notification port to the application runloop
  else {	
    CFRunLoopAddSource(CFRunLoopGetCurrent(),IONotificationPortGetRunLoopSource(notifyPortRef),
                       kCFRunLoopCommonModes); 
  }                                    
   
  [sunTexture loadImage : @"sun.gif" intoIndex : 0];   
 // [sunTexture loadImage : @"sun.gif" intoIndex : 1];   
  
  for (int i = 1; i < MAX_IMAGES; i++) {
    NSString *imageName = [NSString stringWithFormat : @"sun%i.jpg", i];
    [sunTexture loadImage : imageName intoIndex : i];
  }                                                          
}

- (void) dealloc
{
  [super dealloc];
}

- (void) installSignalHandlers
{
  signal(SIGPIPE, SIG_IGN);
}

- (void) removeSignalHandlers
{
  signal(SIGPIPE, SIG_DFL);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [self installSignalHandlers];
  
  window.title = @"FlatSun version 1.19";

  transitioning = NO;
  
  memset(&seasonHistory, sizeof(seasonHistory), 0);
  historyI = 0;
  
// load everything from the settings file  
  [settings loadDictionary : NO];
  [self loadSettings];
  [camera loadSettings];
  [glView loadAll];
  
  [settings freeDictionary];
  
  if (self.autoChangeSeasons) {
    [self changeSeason];
  }
  else sphere.seasonI = 1;
  
  [glView startThread];
  
  if ([serial ableToOpenPort]) {
    [dimmerSlider setHidden : YES];
  }
  
  [self setDimmerFromUdp : 200];
  
  [self startSerialTimer];
  [self startUdpTimer];
  
  [self playSound : @"StartUp"];
}

- (void) startSerialTimer
{
  serialTimer = [NSTimer scheduledTimerWithTimeInterval : 0.050
                                                 target : self
                                               selector : @selector(serialTimerCallBack)
                        									     userInfo : nil
                                                repeats : YES];
  [serialTimer retain];
}

- (void) setDimmer : (UInt8) value
{
// show the value we are receiving  
  [dimmerInTF setIntValue : value];
  
// update the brightness
  [dim update : value];
  
// update the panel
  [glView applyLock];
    [ledPanel setDimmer : dim.value];
  [glView removeLock];
}

- (void) setDimmerFromUdp : (UInt8) value
{
  dimmerSlider.intValue = value;
  overideSlider.intValue = value;
  
  [dim jumpTo : value];
  [dimmerInTF setIntValue : value];
  
  [glView applyLock]; 
    [ledPanel setDimmer : value];
  [glView removeLock];
   
  //NSLog(@"Dimmer from udp = %i", value);
}

- (void) setDimmerBoostFromUdp
{
  [self setDimmerFromUdp : BOOST_TRIGGER_VALUE];  
}

- (void) serialTimerCallBack
{
  if (![serial opened]) {
  //  if (!udpSocket.dataRx) {  
      UInt8 v = [dimmerSlider intValue];
      [self setDimmer : v];
 //   }  
  }
  
  else if ([serial pollRx]) {
    [self setDimmer : serial.rxValue];
  }
  [serial requestData];
}

- (void) playSound : (NSString *) name
{
  NSSound *sound = [NSSound soundNamed : name];
  [sound play];
}

- (IBAction) overrideSliderMoved : (id) sender
{
  NSSlider *slider = (NSSlider *) sender;
  UInt8 v = (UInt8) [slider intValue];
  [ledPanel setDimmer : v];
  
//  NSLog(@"Dimmer = %i", v);
}  


- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *) app
{
  return YES;
}

- (IBAction) shutDownBtnPressed : (id) sender
{
  [self sendSystemAppleEvent:kAEShutDown];
}

- (void) applicationWillTerminate:(NSNotification *)notification
{
  self.window.title = @"Terminating...";
  if (serialTimer) {
    [serialTimer invalidate];
    [serialTimer release];  
  }  
  [serial closePort];

  
  [glView stopThread];
  [camera shutDown];
  
  if (timer) {
    [timer invalidate];
    [timer release];  
  }  
  
  [settings loadDictionary : NO];
  
  [glView shutDown];
  [camera saveSettings];
  
  [self saveSettings];
  
  [settings saveDictionary : NO];
  [settings freeDictionary];
  [self removeSignalHandlers];
}

- (void) loadSettings
{
  self.autoChangeSeasons = [settings intFromKey : kAutoChangeSeasons];
  self.minSeasonSeconds = [settings intFromKey : kMinSeasonSeconds];
  self.maxSeasonSeconds = [settings intFromKey : kMaxSeasonSeconds];
  self.transitionPercent = [settings intFromKey : kTransitionPercent];
  
  sphere.swingTime = [settings floatFromKey : kSwingTime];
}  

- (void) saveSettings 
{
  [settings setInt : (int) autoChangeSeasons forKey : kAutoChangeSeasons];
  [settings setInt : minSeasonSeconds forKey : kMinSeasonSeconds];
  [settings setInt : maxSeasonSeconds forKey : kMaxSeasonSeconds];
  [settings setInt : transitionPercent forKey : kTransitionPercent];
  [settings setFloat : sphere.swingTime forKey : kSwingTime];
}

- (void) pickNextSeasonChangeTime
{
  float interval = (float) minSeasonSeconds + (float) [Routines randomInt : (maxSeasonSeconds - minSeasonSeconds)];
  
  [timer invalidate];
  [timer release];  
  
  timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerCallBack) userInfo:nil repeats:NO];
  [timer retain];
}  

- (void) setAutoChangeSeasons : (BOOL) autoChange
{
  autoChangeSeasons = autoChange;
  if (autoChange) {
    [self pickNextSeasonChangeTime];
  }    
  else {
    if (timer) {
      [timer invalidate];
      [timer release];
      timer = nil;
    }  
  }
}

- (BOOL) seasonInHistory : (int) s
{
  BOOL result = NO;
  int i = 0;
  
  while ((!result) && (i < MAX_HISTORY)) {
    if (seasonHistory[i] == s) result = YES;
    i++;
  }
  return result;
}

- (void) changeSeason
{
  int s = 1 + [Routines randomInt : 10];
  
  while ([self seasonInHistory : s]) {
    if (s < MAX_SEASONS) s++;
    else s = 1;
  }
  
  sphere.seasonI = s;
  
  seasonHistory[historyI++] = s;
  if (historyI == MAX_HISTORY) historyI = 0;
}

- (void) gotoTransitionSeason
{
  sphere.seasonI = 0;
}

- (void) timerCallBack
{
  if (transitioning) transitioning = NO;
  else {
    int dice = [Routines randomInt : 100];
    transitioning = (dice < transitionPercent);
  }   
  if (transitioning) [self gotoTransitionSeason];
  else [self changeSeason];
  [self pickNextSeasonChangeTime];
}

- (IBAction) defaultsBtnClicked : (id) sender
{
// free the old dictionary
  [settings freeDictionary];
  
// re-load the dictionary with defaults  
  [settings loadDictionary : YES];
  
// load our settings from the dictionary  
  
  [self loadSettings];
  [camera loadSettings];
  [glView loadAll];
}

- (void) startUdpTimer
{
  udpTimer = [NSTimer scheduledTimerWithTimeInterval : 0.0100
                                           target : self
                                         selector : @selector(udpTimerCallBack)
                   									     userInfo : nil
                                          repeats : YES];
  [udpTimer retain];
}

- (void) udpTimerCallBack
{
  [udpSocket pollRx];
}

@end
