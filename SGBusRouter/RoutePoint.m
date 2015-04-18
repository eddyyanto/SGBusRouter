//
//  RoutePoint.m
//  SGBusRouter
//
//  Created by Eddy on 16/5/13.
//  Copyright (c) 2013 Eddy. All rights reserved.
//

#import "RoutePoint.h"


@implementation RoutePoint

@synthesize coordinate, title, identifier;

- (id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t identifier:(NSString *)i
{
    self = [super init];
    if(self){
        coordinate = c;
        title = t;
        identifier = i;
    }
    return self;
}

@end
