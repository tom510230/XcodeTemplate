//
//  NSMutableObject+SafeInsert.mm
//  MicroMessenger
//
//  Created by Guo Ling on 12-6-4.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import "NSMutableObject+SafeInsert.h"

@implementation NSObject(SafeInsert)

- (void)safeRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    if (!observer || !keyPath || [keyPath length] <= 0) {
        NSAssert1(NO, @"safeRemoveObserver invalid args: %@", self);
        return;
    }
    @try {
        [self removeObserver:observer forKeyPath:keyPath];
    }
    @catch (NSException *exception) {
        NSLog(@"safeRemoveObserver ex: %@", [exception callStackSymbols]);
    }
}

@end


@implementation NSCache(SafeInsert)

- (void)safeSetObject:(id)anObject forKey:(id)aKey cost:(NSUInteger)aCost{
    if (anObject && aKey) {
		[self setObject:anObject forKey:aKey cost:aCost];
	} else {
        NSAssert2(NO, @"NSCache invalid args safeSetObject:[%@] forKey[%@] cost", anObject, aKey);
	}
}

-(void) safeSetObject:(id)anObject forKey:(id)aKey
{
    if (anObject && aKey) {
		[self setObject:anObject forKey:aKey];
	} else {
        NSAssert2(NO, @"NSCache invalid args safeSetObject:[%@] forKey[%@]", anObject, aKey);
	}
}
-(void) safeRemoveObjectForKey:(id)aKey
{
    if (aKey) {
		[self removeObjectForKey:aKey];
	} else {
        NSAssert1(NO, @"NSCache invalid args safeRemoveObjectForKey[%@]", aKey);
	}
}

@end

@implementation NSMutableDictionary (SafeInsert)

-(void) safeSetObject:(id)anObject forKey:(id)aKey {
	if (anObject && aKey) {
		[self setObject:anObject forKey:aKey];
	} else {
		NSAssert2(NO, @"NSMutableDictionary invalid args safeSetObject:[%@] forKey[%@]", anObject, aKey);
	}
}

-(void) safeSetObject:(id)anObject forKey:(id)aKey defaultObj:(id)defaultObj
{
    if (anObject && aKey) {
		[self setObject:anObject forKey:aKey];
	} else if (defaultObj && aKey) {
		[self setObject:defaultObj forKey:aKey];
	} else {
        NSAssert3(NO, @"NSMutableDictionary invalid args safeSetObject:[%@] forKey:[%@] defaultObj:[%@]", anObject, aKey, defaultObj);
    }
}

-(void) safeRemoveObjectForKey:(id)aKey {
	if (aKey) {
		[self removeObjectForKey:aKey];
	} else {
        NSAssert1(NO, @"NSMutableDictionary invalid args safeRemoveObjectForKey[%@]", aKey);
	}
}

@end

@implementation NSMutableSet (SafeInsert)

-(void) safeAddObject:(id)object {
	if (object) {
		[self addObject:object];
	} else {
        NSAssert1(NO, @"NSMutableSet invalid args safeAddObject[%@]", object);
	}
}

- (void) safeRemoveObject:(id)object {
	if (object) {
		[self removeObject:object];
	} else {
        NSAssert1(NO, @"NSMutableSet invalid args safeRemoveObject[%@]", object);
	}
}


@end

@implementation NSMutableArray (SafeInsert)

+(instancetype)safeArrayWithObject:(id)anObject
{
    if (anObject) {
        return [NSMutableArray arrayWithObject:anObject];
    } else {
        return [[NSMutableArray alloc] init];
    }
}

-(void) safeAddObject:(id)anObject {
	if (anObject) {
		[self addObject:anObject];
	} else {
        NSAssert1(NO, @"NSMutableArray invalid args safeAddObject[%@]", anObject);
	}
}

-(void) safeAddObject:(id)anObject defaultObj:(id)defaultObj
{
    NSAssert(defaultObj, @"NSMutableArray safeAddObject defaultObj can not be nil");
    if (anObject) {
		[self addObject:anObject];
	} else {
        [self addObject:defaultObj];
	}
}


- (void) safeRemoveObject:(id)object {
	if (object) {
		[self removeObject:object];
	} else {
        NSAssert1(NO, @"NSMutableArray invalid args safeRemoveObject[%@]", object);
	}
}

-(void) safeInsertObject:(id)anObject atIndex:(NSUInteger)index {
	if (anObject && index <= self.count) {
		[self insertObject:anObject atIndex:index];
	} else {
		if (!anObject) {
			NSAssert2(NO, @"NSMutableArray invalid args safeInsertObject[%@] atIndex:[%u]", anObject, index);
		}
		if (index > self.count) {
            NSAssert3(NO, @"NSMutableArray safeInsertObject[%@] atIndex[%u] out of bound[%u]", anObject, index, self.count);
		}
	}
}

-(void) safeRemoveObjectAtIndex:(NSUInteger)index {
	if (index < self.count) {
		[self removeObjectAtIndex:index];
	} else {
		NSAssert2(NO, @"NSMutableArray safeRemoveObjectAtIndex[%u] out of bound[%u]", index, self.count);
	}
}

-(id) safeObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
		return [self objectAtIndex:index];
	}
	return nil;
}

-(void) safeReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
	if (index < self.count && anObject) {
		[self replaceObjectAtIndex:index withObject:anObject];
	} else {
		if (!anObject) {
			NSAssert2(NO, @"NSMutableArray invalid args safeReplaceObjectAtIndex[%u] withObject[%@]", index, anObject);
		}
		if (index >= self.count) {
			NSAssert3(NO, @"NSMutableArray safeReplaceObjectAtIndex[%u] withObject[%@] out of bound[%u]", index, anObject, self.count);
		}
	}
}

-(id) firstObject {
	if (self.count > 0) {
		return [self objectAtIndex:0];
	}
	return nil;
}

-(void) removeFirstObject {
	[self safeRemoveObjectAtIndex:0];
}

- (void)safeRemoveObject:(id)anObject inRange:(NSRange)range{
    
    if(anObject==nil||range.location>=[self count]||range.length>[self count]||range.location+range.length>[self count]){
        // NSAssert1(NO, @"NSMutableArray invalid args safeRemoveObject[%@] or range[%@]", anObject,range);
    }else{
        [self removeObject:anObject inRange:range];
    }
}

@end

@implementation NSArray (SafeInsert)

+(instancetype)safeArrayWithObject:(id)anObject
{
    if (anObject) {
        return [NSArray arrayWithObject:anObject];
    } else {
        return [[NSArray alloc] init];
    }
}

-(id) safeObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
		return [self objectAtIndex:index];
	}
	return nil;
}

-(id) firstObject {
	if (self.count > 0) {
		return [self objectAtIndex:0];
	}
	return nil;
}

@end

@implementation NSMutableString (SafeInsert)

- (void)safeAppendString:(NSString *)aString
{
    if (nil == aString) {
        return;
    }
    
    [self appendString:aString];
}

@end


@implementation NSUserDefaults(SafeInsert)

-(void) safeSetObject:(id)anObject forKey:(id)aKey
{
    if (anObject && aKey) {
		[self setObject:anObject forKey:aKey];
	} else {
        NSAssert2(NO, @"NSUserDefaults invalid args safeSetObject:[%@] forKey[%@]", anObject, aKey);
	}
}
-(void) safeRemoveObjectForKey:(id)aKey
{
    if (aKey) {
		[self removeObjectForKey:aKey];
	} else {
        NSAssert1(NO, @"NSUserDefaults invalid args safeRemoveObjectForKey[%@]", aKey);
	}
}

@end



@implementation NSMutableOrderedSet (SafeInsert)

-(void) safeAddObject:(id)object {
	if (object) {
		[self addObject:object];
	} else {
        NSAssert1(NO, @"NSMutableOrderedSet invalid args safeAddObject[%@]", object);
	}
}

@end
