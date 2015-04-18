//
//  Bus.h
//  SGBusRouter
//
//  Created by Eddy on 20/5/13.
//  Copyright (c) 2013 Eddy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bus : NSObject

@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSString *direction;
@property (strong, nonatomic) NSString *provider;
@property (strong, nonatomic) NSString *type;


@end
