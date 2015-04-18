//
//  RoutePoint.h
//  SGBusRouter
//
//  Created by Eddy on 16/5/13.
//  Copyright (c) 2013 Eddy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RoutePoint : NSObject <MKAnnotation>
{

}

- (id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t identifier:(NSString *)i;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *identifier;

@end
