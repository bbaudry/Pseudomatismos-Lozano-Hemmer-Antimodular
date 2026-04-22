#import <Foundation/Foundation.h>

@interface Settings : NSObject 
{
  NSMutableDictionary *dictionary;  
}

- (NSString *) appPath;
- (NSString *) dictionaryFileName;
  
- (BOOL) ableToLoadDictionary : (BOOL) useDefaults;
- (void) loadDictionary : (BOOL) useDefaults;

- (void) createDictionary;
- (void) freeDictionary;

- (void) saveDictionary : (BOOL) useDefaults;

// keys, tags and seasons
- (float) floatFromKey : (NSString *) key andTag : (int) tag andSeason : (int) s;
- (void) setFloat : (float) v forKey : (NSString *) key andTag : (int) tag andSeason : (int) s;

- (int) intFromKey : (NSString *) key andTag : (int) tag andSeason : (int) s;
- (void) setInt : (int) v forKey : (NSString *) key andTag : (int) tag andSeason : (int) s;

// keys and seasons
- (float) floatFromKey : (NSString *) key andSeason : (int) s;
- (void) setFloat : (float) v forKey : (NSString *) key andSeason : (int) s;

- (int) intFromKey : (NSString *) key andSeason : (int) s;
- (void) setInt : (int) v forKey : (NSString *) key andSeason : (int) s;

- (BOOL) boolFromKey : (NSString *) key andSeason : (int) s;
- (void) setBool : (BOOL) v forKey : (NSString *) key andSeason : (int) s;

// keys only
- (NSNumber *) numberForKey : (NSString *) key;
- (float) floatFromKey : (NSString *) key; 
- (void) setFloat : (float) v forKey : (NSString *) key; 
- (int) intFromKey : (NSString *) key; 
- (void) setInt : (int) v forKey : (NSString *) key;
- (BOOL) boolFromKey : (NSString *) key; 
- (void) setBool : (BOOL) v forKey : (NSString *) key;

- (BOOL) keyExists : (NSString *) key;

@end
