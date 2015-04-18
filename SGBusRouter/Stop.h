//
//  Stop.h
//  SGBusRouter
//
//  Created by Eddy on 20/5/13.
//  Copyright (c) 2013 Eddy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Stop : NSObject

@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) CLLocationDegrees latitude;
@property (assign, nonatomic) CLLocationDegrees longitude;

@end
