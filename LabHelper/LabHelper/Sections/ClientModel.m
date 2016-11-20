//
//  ClientModel.m
//
//  Created by ljc  on 2016/11/20
//  Copyright (c) 2016 meitu.com. All rights reserved.
//

#import "ClientModel.h"


NSString *const kClientModelCiId = @"CiId";
NSString *const kClientModelCiName = @"CiName";


@interface ClientModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ClientModel

@synthesize ciId = _ciId;
@synthesize ciName = _ciName;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
            self.ciId = [self objectOrNilForKey:kClientModelCiId fromDictionary:dict];
            self.ciName = [self objectOrNilForKey:kClientModelCiName fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.ciId forKey:kClientModelCiId];
    [mutableDict setValue:self.ciName forKey:kClientModelCiName];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description  {
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict {
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];

    self.ciId = [aDecoder decodeObjectForKey:kClientModelCiId];
    self.ciName = [aDecoder decodeObjectForKey:kClientModelCiName];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_ciId forKey:kClientModelCiId];
    [aCoder encodeObject:_ciName forKey:kClientModelCiName];
}

- (id)copyWithZone:(NSZone *)zone {
    ClientModel *copy = [[ClientModel alloc] init];
    
    
    
    if (copy) {

        copy.ciId = [self.ciId copyWithZone:zone];
        copy.ciName = [self.ciName copyWithZone:zone];
    }
    
    return copy;
}


@end
