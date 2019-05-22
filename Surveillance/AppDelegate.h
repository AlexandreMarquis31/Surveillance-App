//
//  AppDelegate.h
//  Surveillance
//
//  Created by Alexandre Marquis on 09/07/2016.
//  Copyright © 2016 Alexandre Marquis. All rights reserved.
//

@import AVKit;
@import WebKit;
@import AVFoundation;

#import "UIActionsControllerContainer.h"

@interface AppDelegate : NSObject <UIApplicationDelegate,UITableViewDelegate,UITableViewDataSource,WKNavigationDelegate,UITextFieldDelegate>
{
}
@property (nonatomic,strong) UIWindow* window;
@property (strong) NSMutableArray* array;
@property (strong) NSMutableArray* images;
@property (strong) UITableViewController* tableController;
@end
