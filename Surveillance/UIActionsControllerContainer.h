//
//  UIActionsController.h
//  Surveillance
//
//  Created by Alexandre Marquis on 09/07/2016.
//  Copyright © 2016 Alexandre Marquis. All rights reserved.
//

@import UIKit;

@interface UIActionsControllerContainer : NSObject <UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate>{
}
@property (strong) id controller;
@property(nonatomic,strong)NSString* timerString;
@end
