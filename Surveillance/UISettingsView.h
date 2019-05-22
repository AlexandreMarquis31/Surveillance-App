//
//  UISettingsView.h
//  Surveillance
//
//  Created by Alexandre Marquis on 10/07/2016.
//  Copyright © 2016 Alexandre Marquis. All rights reserved.
//

@import UIKit;

@interface UISettingsView : UIView <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
}
@property(strong)UITableView* settingsTableView;
@property(strong) NSMutableArray* IPAdress;
@property BOOL cellWasSelected;
@end
