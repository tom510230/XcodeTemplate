//
//  NSMutableObject+SafeInsert.h
//  MicroMessenger
//
//  Created by Guo Ling on 12-6-4.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SafeOperation)

- (void)safeRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end

@interface NSMutableDictionary (SafeInsert)

-(void) safeSetObject:(id)anObject forKey:(id)aKey;
-(void) safeSetObject:(id)anObject forKey:(id)aKey defaultObj:(id)defaultObj;
-(void) safeRemoveObjectForKey:(id)aKey;

@end

@interface NSMutableSet (SafeInsert)

-(void) safeAddObject:(id)object;
- (void) safeRemoveObject:(id)object;

@end

@interface NSMutableArray (SafeInsert)

+(instancetype)safeArrayWithObject:(id)anObject;
-(void) safeAddObject:(id)anObject;
-(void) safeAddObject:(id)anObject defaultObj:(id)defaultObj;
-(void) safeRemoveObject:(id)object;
-(void) safeInsertObject:(id)anObject atIndex:(NSUInteger)index;
-(void) safeRemoveObjectAtIndex:(NSUInteger)index;
-(void) safeReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
-(id) safeObjectAtIndex:(NSUInteger)index;
-(id) firstObject;
-(void) removeFirstObject;
- (void)safeRemoveObject:(id)anObject inRange:(NSRange)range;
@end

@interface NSArray (SafeInsert)

+(instancetype)safeArrayWithObject:(id)anObject;
-(id) safeObjectAtIndex:(NSUInteger)index;
-(id) firstObject;

@end

@interface NSCache (SafeInsert)
-(void) safeSetObject:(id)anObject forKey:(id)aKey;
-(void) safeRemoveObjectForKey:(id)aKey;
-(void)safeSetObject:(id)anObject forKey:(id)aKey cost:(NSUInteger)aCost;
@end

@interface NSMutableString (SafeInsert)

- (void)safeAppendString:(NSString *)aString;

@end

@interface NSUserDefaults (SafeInsert)
-(void) safeSetObject:(id)anObject forKey:(id)aKey;
-(void) safeRemoveObjectForKey:(id)aKey;
@end


@interface NSMutableOrderedSet (SafeInsert)

-(void) safeAddObject:(id)object;

@end
