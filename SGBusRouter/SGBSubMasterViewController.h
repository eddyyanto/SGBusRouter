//
//  SGBSubMasterViewController.h
//  SGBusRouter
//
//  Created by Eddy on 17/5/13.
//  Copyright (c) 2013 Eddy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGBDetailViewController;

@interface SGBSubMasterViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSString *selectedBus;
    NSString *selectedDirection;
    NSArray *stopsSelectedBusPassThrough;
    NSArray *filteredStopsSelectedBusPasThrough;
    IBOutlet UISegmentedControl *segmentedControl;
}

@property (strong, nonatomic) SGBDetailViewController *detailViewController;

- (void)setStopsAlongPath:(NSString *)bus withDirection:(NSString *)dir;

@end
