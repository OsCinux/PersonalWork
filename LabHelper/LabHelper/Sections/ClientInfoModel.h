//
//  ClientInfoModel.h
//
//  Created by ljc  on 2016/11/27
//  Copyright (c) 2016 meitu.com. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ClientInfoModel : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) NSInteger isNewClient;
@property (nonatomic, strong) NSString *ciname;
@property (nonatomic, strong) NSString *ciphone;
@property (nonatomic, strong) NSArray *clientsImageData;
@property (nonatomic, assign) double clientImagesCount;
@property (nonatomic, strong) NSString *remark;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
