//
//  GuestInfoModel.m
//
//  Created by ljc  on 2016/11/19
//  Copyright (c) 2016 meitu.com. All rights reserved.
//

#import "GuestInfoModel.h"

NSString *const kGuestInfoModelID = @"ID";
NSString *const kGuestInfoModelPhoneNumber = @"PhoneNumber";
NSString *const kGuestInfoModelName = @"Name";
NSString *const kGuestInfoModelQRcodeImageUrlStr = @"QRcodeImageUrlStr";
NSString *const kGuestInfoModelCreateTime = @"CreateTime";


@interface GuestInfoModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation GuestInfoModel

@synthesize iDProperty = _iDProperty;
@synthesize phoneNumber = _phoneNumber;
@synthesize name = _name;
@synthesize qRcodeImageUrlStr = _qRcodeImageUrlStr;
@synthesize createTime = _createTime;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
            self.iDProperty = [self objectOrNilForKey:kGuestInfoModelID fromDictionary:dict];
            self.phoneNumber = [self objectOrNilForKey:kGuestInfoModelPhoneNumber fromDictionary:dict];
            self.name = [self objectOrNilForKey:kGuestInfoModelName fromDictionary:dict];
            self.qRcodeImageUrlStr = [self objectOrNilForKey:kGuestInfoModelQRcodeImageUrlStr fromDictionary:dict];
            self.createTime = [self objectOrNilForKey:kGuestInfoModelCreateTime fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.iDProperty forKey:kGuestInfoModelID];
    [mutableDict setValue:self.phoneNumber forKey:kGuestInfoModelPhoneNumber];
    [mutableDict setValue:self.name forKey:kGuestInfoModelName];
    [mutableDict setValue:self.qRcodeImageUrlStr forKey:kGuestInfoModelQRcodeImageUrlStr];
    [mutableDict setValue:self.createTime forKey:kGuestInfoModelCreateTime];

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

    self.iDProperty = [aDecoder decodeObjectForKey:kGuestInfoModelID];
    self.phoneNumber = [aDecoder decodeObjectForKey:kGuestInfoModelPhoneNumber];
    self.name = [aDecoder decodeObjectForKey:kGuestInfoModelName];
    self.qRcodeImageUrlStr = [aDecoder decodeObjectForKey:kGuestInfoModelQRcodeImageUrlStr];
    self.createTime = [aDecoder decodeObjectForKey:kGuestInfoModelCreateTime];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_iDProperty forKey:kGuestInfoModelID];
    [aCoder encodeObject:_phoneNumber forKey:kGuestInfoModelPhoneNumber];
    [aCoder encodeObject:_name forKey:kGuestInfoModelName];
    [aCoder encodeObject:_qRcodeImageUrlStr forKey:kGuestInfoModelQRcodeImageUrlStr];
    [aCoder encodeObject:_createTime forKey:kGuestInfoModelCreateTime];
}

- (id)copyWithZone:(NSZone *)zone {
    GuestInfoModel *copy = [[GuestInfoModel alloc] init];
    
    
    
    if (copy) {

        copy.iDProperty = [self.iDProperty copyWithZone:zone];
        copy.phoneNumber = [self.phoneNumber copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.qRcodeImageUrlStr = [self.qRcodeImageUrlStr copyWithZone:zone];
        copy.createTime = [self.createTime copyWithZone:zone];
    }
    
    return copy;
}


@end
