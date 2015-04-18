//
//  SGBMasterViewController.h
//  SGBusRouter
//
//  Created by Eddy on 17/5/13.
//  Copyright (c) 2013 Eddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGBSubMasterViewController.h"

@class SGBDetailViewController;

@interface SGBMasterViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>
{
    NSArray *busesKeys;
    NSArray *filteredBusesKeys;
    IBOutlet UISearchBar *searchBar;
}

@property (nonatomic, strong) NSArray *busesKeys;
@property (nonatomic, strong) NSArray *filteredBusesKeys;
@property (strong, nonatomic) SGBSubMasterViewController *subMasterViewController;
@property (strong, nonatomic) SGBDetailViewController *detailViewController;

@end
