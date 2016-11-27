//
//  ClientInfoModel.m
//
//  Created by ljc  on 2016/11/27
//  Copyright (c) 2016 meitu.com. All rights reserved.
//

#import "ClientInfoModel.h"


NSString *const kClientInfoModelIsNewClient = @"isNewClient";
NSString *const kClientInfoModelCiname = @"ciname";
NSString *const kClientInfoModelCiphone = @"ciphone";
NSString *const kClientInfoModelClientsImageData = @"ClientsImageData";
NSString *const kClientInfoModelClientImagesCount = @"ClientImagesCount";
NSString *const kClientInfoModelRemark = @"remark";


@interface ClientInfoModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ClientInfoModel

@synthesize isNewClient = _isNewClient;
@synthesize ciname = _ciname;
@synthesize ciphone = _ciphone;
@synthesize clientsImageData = _clientsImageData;
@synthesize clientImagesCount = _clientImagesCount;
@synthesize remark = _remark;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
            self.isNewClient = [[self objectOrNilForKey:kClientInfoModelIsNewClient fromDictionary:dict] integerValue];
            self.ciname = [self objectOrNilForKey:kClientInfoModelCiname fromDictionary:dict];
            self.ciphone = [self objectOrNilForKey:kClientInfoModelCiphone fromDictionary:dict];
            self.clientsImageData = [self objectOrNilForKey:kClientInfoModelClientsImageData fromDictionary:dict];
            self.clientImagesCount = [[self objectOrNilForKey:kClientInfoModelClientImagesCount fromDictionary:dict] doubleValue];
            self.remark = [self objectOrNilForKey:kClientInfoModelRemark fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.isNewClient] forKey:kClientInfoModelIsNewClient];
    [mutableDict setValue:self.ciname forKey:kClientInfoModelCiname];
    [mutableDict setValue:self.ciphone forKey:kClientInfoModelCiphone];
    NSMutableArray *tempArrayForClientsImageData = [NSMutableArray array];
    
    for (NSObject *subArrayObject in self.clientsImageData) {
        if ([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForClientsImageData addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForClientsImageData addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForClientsImageData] forKey:kClientInfoModelClientsImageData];
    [mutableDict setValue:[NSNumber numberWithDouble:self.clientImagesCount] forKey:kClientInfoModelClientImagesCount];
    [mutableDict setValue:self.remark forKey:kClientInfoModelRemark];

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

    self.isNewClient = [aDecoder decodeIntegerForKey:kClientInfoModelIsNewClient];
    self.ciname = [aDecoder decodeObjectForKey:kClientInfoModelCiname];
    self.ciphone = [aDecoder decodeObjectForKey:kClientInfoModelCiphone];
    self.clientsImageData = [aDecoder decodeObjectForKey:kClientInfoModelClientsImageData];
    self.clientImagesCount = [aDecoder decodeDoubleForKey:kClientInfoModelClientImagesCount];
    self.remark = [aDecoder decodeObjectForKey:kClientInfoModelRemark];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeInteger:_isNewClient forKey:kClientInfoModelIsNewClient];
    [aCoder encodeObject:_ciname forKey:kClientInfoModelCiname];
    [aCoder encodeObject:_ciphone forKey:kClientInfoModelCiphone];
    [aCoder encodeObject:_clientsImageData forKey:kClientInfoModelClientsImageData];
    [aCoder encodeDouble:_clientImagesCount forKey:kClientInfoModelClientImagesCount];
    [aCoder encodeObject:_remark forKey:kClientInfoModelRemark];
}

- (id)copyWithZone:(NSZone *)zone {
    ClientInfoModel *copy = [[ClientInfoModel alloc] init];
    if (copy) {
        copy.isNewClient = self.isNewClient;
        copy.ciname = [self.ciname copyWithZone:zone];
        copy.ciphone = [self.ciphone copyWithZone:zone];
        copy.clientsImageData = [self.clientsImageData copyWithZone:zone];
        copy.clientImagesCount = self.clientImagesCount;
        copy.remark = [self.remark copyWithZone:zone];
    }
    
    return copy;
}


@end
