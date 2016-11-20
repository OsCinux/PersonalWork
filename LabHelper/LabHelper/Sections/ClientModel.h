//
//  ClientModel.h
//
//  Created by ljc  on 2016/11/20
//  Copyright (c) 2016 meitu.com. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ClientModel : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *ciId;
@property (nonatomic, strong) NSString *ciName;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
