/**
 * Copyright (c) 2021-present by Hans Knöchel
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLivequeryObjectProxy.h"
#import "TiLivequeryRelationProxy.h"
#import "TiLivequeryGeoPointProxy.h"
#import "TiLivequeryFileProxy.h"
#import "TiLivequeryUtils.h"

@implementation TiLivequeryObjectProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andObject:(PFObject *)object
{
  if (self = [super _initWithPageContext:context]) {
    _object = object;
  }

  return self;
}

- (PFObject *)object
{
  return _object;
}

- (NSString *)parseClassName
{
  return [_object parseClassName];
}

- (NSString *)objectId
{
  return [_object objectId];
}

- (NSDate *)createdAt
{
  return [_object createdAt];
}

- (NSDate *)updatedAt
{
  return [_object updatedAt];
}

- (NSArray<NSString *> *)allKeys
{
  return [_object allKeys];
}

- (id)objectForKey:(id)key
{
  ENSURE_SINGLE_ARG(key, NSObject);
  
  id object = [_object objectForKey:key];

  if (![object isKindOfClass:[NSArray class]]) {
    return [TiLivequeryUtils mappedObject:object withPageContext:self.pageContext];
  }

  NSMutableArray *result = [NSMutableArray arrayWithCapacity:[(NSArray *)object count]];

  [object enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    [result addObject:[TiLivequeryUtils mappedObject:obj withPageContext:self.pageContext]];
  }];
  
  return result;
}

- (void)add:(id)args
{
  id key = [args objectAtIndex:0];
  id value = [args objectAtIndex:1];

  // Unbox previously boxed value
  if ([value isKindOfClass:[TiLivequeryFileProxy class]]) {
    value = [(TiLivequeryFileProxy *) value file];
  }

  return [_object setObject:value forKey:key];
}

- (void)remove:(id)key
{
  ENSURE_SINGLE_ARG(key, NSObject);
  return [_object removeObjectForKey:key];
}

- (NSNumber *)deleteObject:(id)value
{
  ENSURE_SINGLE_ARG_OR_NIL(value, KrollCallback);

  if (value == nil) {
    return @([_object delete]);
  } else {
    [_object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      [value call:@[ @{ @"success" : @(succeeded),
        @"error" : error ? error.localizedDescription : [NSNull null] } ]
          thisObject:self];
    }];
    return nil;
  }
}

- (NSNumber *)saveObject:(id)callback
{
  ENSURE_SINGLE_ARG_OR_NIL(callback, KrollCallback);

  if (callback == nil) {
    return @([_object save]);
  } else {
    [_object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      [callback call:@[ @{ @"success" : @(succeeded),
        @"error" : error ? error.localizedDescription : [NSNull null] } ]
          thisObject:self];
    }];
    return nil;
  }
}

- (void)saveInBackground:(id)unused
{
  [_object saveInBackground];  
}

- (void)fetchInBackground:(id)callback
{
  ENSURE_SINGLE_ARG_OR_NIL(callback, KrollCallback);

  if (callback == nil) {
    [_object fetchInBackground];
  } else {
    [_object fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
      [callback call:@[ @{
        @"success" : @(error == nil),
        @"error" : error ? error.localizedDescription : [NSNull null],
        @"object": [[TiLivequeryObjectProxy alloc] _initWithPageContext:self.pageContext andObject:object]
      } ] thisObject:self];
    }];
  }
}

- (void)pinInBackground:(id)callback
{
  ENSURE_SINGLE_ARG_OR_NIL(callback, KrollCallback);

  if (callback == nil) {
    [_object pinInBackground];
  } else {
    [_object pinInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
      [callback call:@[ @{
        @"success" : @(error == nil),
        @"error" : error ? error.localizedDescription : [NSNull null]
      } ] thisObject:self];
    }];
  }
}

- (void)unpinInBackground:(id)callback
{
  ENSURE_SINGLE_ARG_OR_NIL(callback, KrollCallback);

  if (callback == nil) {
    [_object unpinInBackground];
  } else {
    [_object unpinInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
      [callback call:@[ @{
        @"success" : @(error == nil),
        @"error" : error ? error.localizedDescription : [NSNull null]
      } ] thisObject:self];
    }];
  }
}

- (void)pinAllInBackground:(id)callback
{
  ENSURE_SINGLE_ARG_OR_NIL(callback, KrollCallback);

  // [_object pinAllInBackground:@[]];
}

- (void)fetchFromLocalDatastoreInBackground:(id)callback
{
  ENSURE_SINGLE_ARG_OR_NIL(callback, KrollCallback);

  if (callback == nil) {
    [_object fetchFromLocalDatastoreInBackground];
  } else {
    [_object fetchFromLocalDatastoreInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
      [callback call:@[ @{
        @"success" : @(error == nil),
        @"error" : error ? error.localizedDescription : [NSNull null],
        @"object": [[TiLivequeryObjectProxy alloc] _initWithPageContext:self.pageContext andObject:object]
      } ] thisObject:self];
    }];
  }
}

- (void)fetchIfNeededInBackgroundWithBlock:(id)callback
{
  ENSURE_SINGLE_ARG(callback, KrollCallback);

  [_object fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
    [callback call:@[ @{
      @"success" : @(error == nil),
      @"error" : error ? error.localizedDescription : [NSNull null],
      @"object": [[TiLivequeryObjectProxy alloc] _initWithPageContext:self.pageContext andObject:object]
    } ] thisObject:self];
  }];
}

- (void)saveEventually:(id)callback
{
  ENSURE_SINGLE_ARG_OR_NIL(callback, KrollCallback);

  if (callback == nil) {
    [_object saveEventually];
  } else {
    [_object saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
      [callback call:@[ @{
        @"success" : @(error == nil),
        @"error" : error ? error.localizedDescription : [NSNull null]
      } ] thisObject:self];
    }];
  }
}

- (void)deleteEventually:(id)unused
{
  [_object deleteEventually];
}

@end
