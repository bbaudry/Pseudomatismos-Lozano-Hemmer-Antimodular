#import "Settings.h"

@implementation Settings

- (NSString *) appPath
{
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *appName = [bundle bundlePath];
  NSString *appFolder = [appName stringByDeletingLastPathComponent];
//  [appFolder retain];
  return appFolder;
}

- (NSString *) dictionaryFileName 
{
  NSString *path = [self appPath];    
  NSString *fileName = [NSString stringWithFormat : @"%@/Settings.plist", path];
//  [fileName retain];
  return fileName;
}

- (NSString *) defaultsDictionaryFileName 
{
  NSString *path = [self appPath];    
  NSString *fileName = [NSString stringWithFormat : @"%@/Defaults.plist", path];
//  [fileName retain];
  return fileName;
}

- (BOOL) ableToLoadDictionary : (BOOL) useDefaults
{
// get the path to the app
  NSString *fileName;
  if (useDefaults) fileName = [self defaultsDictionaryFileName];
  else fileName = [self dictionaryFileName];
                        
// get the default file manager  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  if ([fileManager fileExistsAtPath:  fileName]) {
    dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile : fileName];
    [dictionary retain];
    return YES;
  }
  return NO;
}  

- (void) loadDictionary :(BOOL)useDefaults
{
  [self ableToLoadDictionary : useDefaults];
}

- (void) createDictionary
{
}

- (void) saveDictionary : (BOOL) useDefaults
{
  NSString *fileName;
  
  if (useDefaults) fileName = [self defaultsDictionaryFileName];
  else fileName = [self dictionaryFileName];
  
  [dictionary writeToFile : fileName atomically : YES];
}  

- (void) freeDictionary
{ 
  if (dictionary) [dictionary release];
}

- (NSString *) stringForKey : (NSString *) key andTag : (int) tag andSeason : (int) s
{
  NSString *result = [NSString stringWithFormat : @"%@%i-%i", key, tag, s];
  [result retain];
  return result;
}

- (NSNumber *) numberForKey : (NSString *) key andTag : (int) tag andSeason : (int) s
{
  NSString *keyStr = [self stringForKey : key andTag : tag andSeason : s];
  
  NSNumber *number = [dictionary objectForKey : keyStr];
  [number retain];
  //[keyStr release];
  return number;
}


- (NSString *) stringForKey : (NSString *) key andSeason : (int) s
{
  NSString *result = [NSString stringWithFormat : @"%@-%i", key, s];
  [result retain];
  return result;
}

- (NSNumber *) numberForKey : (NSString *) key andSeason : (int) s
{
  NSString *keyStr = [self stringForKey : key andSeason : s];
  
  NSNumber *number = [dictionary objectForKey : keyStr];
  [number retain];
  //[keyStr release];
  
  return number;
}

- (float) floatFromKey : (NSString *) key andTag : (int) tag andSeason : (int) s
{
  NSNumber *number = [self numberForKey : key andTag : tag andSeason : s];
  
  float result;
  if (number) {
    result = [number floatValue];
    //[number release];
  }
  else result = 0;
                      
  return result;
}  
  
- (void) setFloat : (float) v forKey : (NSString *) key andTag : (int) tag andSeason : (int) s
{
  NSNumber *number = [[NSNumber alloc] initWithFloat : v];
                      
  NSString *keyStr = [self stringForKey : key andTag : tag andSeason : s];
                      
 [dictionary setObject : number forKey : keyStr];                      
 
 [number release];
 //[keyStr release];
}

- (int) intFromKey : (NSString *) key andTag : (int) tag andSeason : (int) s
{
  NSNumber *number = [self numberForKey : key andTag : tag andSeason : s];
  
  int result;
  if (number) result = [number intValue];
  else result = 0;
                      
  //[number release];                      
                      
  return result;
}  

- (void) setInt : (int) v forKey : (NSString *) key andTag : (int) tag andSeason : (int) s
{
  NSNumber *number = [[NSNumber alloc] initWithInt : v];
                      
  NSString *keyStr = [self stringForKey : key andTag : tag andSeason : s];
                      
 [dictionary setObject : number forKey : keyStr];                      
 
 [number release];
 //[keyStr release];
}
////
- (float) floatFromKey : (NSString *) key andSeason : (int) s
{
  NSNumber *number = [self numberForKey : key andSeason : s];
  
  float result;
  if (number) result = [number floatValue];
  else result = 0;
                      
  //[number release];                      
                      
  return result;
}  
  
- (void) setFloat : (float) v forKey : (NSString *) key andSeason : (int) s
{
  NSNumber *number = [[NSNumber alloc] initWithFloat : v];
                      
  NSString *keyStr = [self stringForKey : key andSeason : s];
                      
 [dictionary setObject : number forKey : keyStr];                      
 
 [number release];
 //[keyStr release];
}

- (int) intFromKey : (NSString *) key andSeason : (int) s
{
  NSNumber *number = [self numberForKey : key andSeason : s];
  
  int result;
  if (number) result = [number intValue];
  else result = 0;
                      
  //[number release];                      
                      
  return result;
}  

- (void) setInt : (int) v forKey : (NSString *) key andSeason : (int) s
{
  NSNumber *number = [[NSNumber alloc] initWithInt : v];
                      
  NSString *keyStr = [self stringForKey : key andSeason : s];
                      
 [dictionary setObject : number forKey : keyStr];                      
 
 [number release];
 //[keyStr release];
}

- (BOOL) boolFromKey : (NSString *) key andSeason : (int) s
{
  BOOL result = (BOOL) [self intFromKey : key andSeason : s];
  return result;
}

- (void) setBool : (BOOL) v forKey : (NSString *) key andSeason : (int) s
{
  [self setInt : (int) v forKey : key andSeason : s];
}

// season-less keys
- (NSNumber *) numberForKey : (NSString *) key
{
  NSNumber *number = [dictionary objectForKey : key];
  return number;
}

- (float) floatFromKey : (NSString *) key 
{
  NSNumber *number = [self numberForKey : key];
  
  float result;
  if (number) result = [number floatValue];
  else result = 0;
                      
  //[number release];                      
                      
  return result;
}  
  
- (void) setFloat : (float) v forKey : (NSString *) key 
{
  NSNumber *number = [[NSNumber alloc] initWithFloat : v];
  [number retain];
                      
 [dictionary setObject : number forKey : key];                      
 
 [number release];
}

- (int) intFromKey : (NSString *) key 
{
  NSNumber *number = [self numberForKey : key];
  
  int result;
  if (number) result = [number intValue];
  else result = 0;
                      
  //[number release];                      
                      
  return result;
}  

- (void) setInt : (int) v forKey : (NSString *) key
{
  NSNumber *number = [[NSNumber alloc] initWithInt : v];
                      
 [dictionary setObject : number forKey : key];                      
 
 [number release];
}

- (BOOL) boolFromKey : (NSString *) key 
{
  BOOL result = (BOOL) [self intFromKey : key];
  return result;
}

- (void) setBool : (BOOL) v forKey : (NSString *) key
{
  [self setInt : (int) v forKey : key];
}

- (BOOL) keyExists : (NSString *) key 
{
  NSNumber *number = [self numberForKey : key];
  return (number != nil);
}

@end

