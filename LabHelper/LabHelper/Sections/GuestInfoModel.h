//
//  GuestInfoModel.h
//
//  Created by ljc  on 2016/11/19
//  Copyright (c) 2016 meitu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuestInfoModel : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *iDProperty;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *qRcodeImageUrlStr;
@property (nonatomic, strong) NSString *createTime;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
