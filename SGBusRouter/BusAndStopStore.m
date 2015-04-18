//
//  StopStore.m
//  SGBusRouter
//
//  Created by Eddy on 20/5/13.
//  Copyright (c) 2013 Eddy. All rights reserved.
//

#import "BusAndStopStore.h"
#import "AFJSONRequestOperation.h"
#import "Stop.h"
#import "Bus.h"

@implementation BusAndStopStore

+ (BusAndStopStore *)sharedStore
{
    static BusAndStopStore *sharedStore = nil;
    if(!sharedStore)
        sharedStore = [[super allocWithZone:nil] init];
    
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (id)init
{
    self = [super init];
    if(self){
        allStops = [[NSMutableDictionary alloc] init];
        allBuses = [[NSMutableDictionary alloc] init];
        // Load stops into store
        NSURL *stopsJsonUrl = [[NSBundle mainBundle] URLForResource:@"bus-stops" withExtension:@"json"];
        NSURLRequest *stopsJsonRequest = [NSURLRequest requestWithURL:stopsJsonUrl];
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
        AFJSONRequestOperation *stopsSONOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:stopsJsonRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {\
            
            for (NSString *sKey in JSON) { // sKey = dictionary key
                NSDictionary *sDetail = [JSON objectForKey:sKey];
                NSString *sName = [sDetail objectForKey:@"name"];
                NSArray *sCoord = [[sDetail objectForKey:@"coords"] componentsSeparatedByString:@","];
                CLLocationDegrees sLat  = [[sCoord objectAtIndex:1] doubleValue];
                CLLocationDegrees sLong = [[sCoord objectAtIndex:0] doubleValue];
                [self addStop:sKey withName:sName withLat:sLat withLong:sLong];
            }
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
            NSLog(@"%@", error);
        }];
        [stopsSONOperation start];
    }
    return self;
}

- (NSDictionary *)allStops
{
    return allStops;
}

- (NSDictionary *)allBuses
{
    return allBuses;
}

- (Stop *)addStop:(NSString *)number withName:(NSString *)name withLat:(CLLocationDegrees)latitude withLong:(CLLocationDegrees)longitude
{
    Stop *s = [[Stop alloc] init];
    [s setNumber:number];
    [s setName:name];
    [s setLatitude:latitude];
    [s setLongitude:longitude];
    
    [[self allStops] setValue:s forKey:number];
    
    return s;
}

- (Bus *)addBus:(NSString *)number withDirection:(NSString *)direction withProvider:(NSString *)provider withType:(NSString *)type
{
    Bus *b = [[Bus alloc] init];
    [b setNumber:number];
    [b setDirection:direction];
    [b setProvider:provider];
    [b setType:type];
    
    [[self allBuses] setValue:b forKey:number];
    
    return b;
}

- (Stop *)getStop:(NSString *)number
{
    return [[self allStops] objectForKey:number];
}

- (Bus *)getBus:(NSString *)number
{
    return [[self allBuses] objectForKey:number];
}

@end
