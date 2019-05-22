//
//  UIActionsController.m
//  Surveillance
//
//  Created by Alexandre Marquis on 09/07/2016.
//  Copyright © 2016 Alexandre Marquis. All rights reserved.
//

#import "UIActionsControllerContainer.h"

@interface AppDelegate{}
-(void)refreshState;
-(void)startStream;
-(void)delay5min;
-(void)changeStateSurveillance;
@end

@implementation UIActionsControllerContainer
@synthesize controller;
@synthesize timerString;

NSMutableArray* actionsArray;
extern UIBarButtonItem* statutButton;

-(UIActionsControllerContainer*)init{
    self=[super init];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        UITableViewController* actionsTableController=[[UITableViewController alloc]init];
        actionsTableController.modalPresentationStyle = UIModalPresentationPopover;
        UITableView*popoverTable =[[UITableView alloc]init];
        popoverTable.backgroundColor=[UIColor clearColor];
        popoverTable.delegate=self;
        popoverTable.dataSource=self;
        popoverTable.scrollEnabled=NO;
        popoverTable.layoutMargins = UIEdgeInsetsZero;
        actionsTableController.tableView=popoverTable;
        [popoverTable setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        popoverTable.rowHeight=50;
        actionsTableController.preferredContentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width/5,(popoverTable.rowHeight*[actionsArray count])-1);
        actionsTableController.popoverPresentationController.barButtonItem = statutButton;
        controller=actionsTableController;
    }
    else{
        UIAlertController* actionsAlertController = [UIAlertController alertControllerWithTitle:@"Actions"
                                                                       message:@"What do you want to do?"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        for (NSInteger i=0; i<[actionsArray count];i++){
            UIAlertAction* action = [UIAlertAction actionWithTitle:[actionsArray objectAtIndex:i] style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [self actionForRow:i];}];
            [actionsAlertController addAction:action];
        }
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * action) {
                                                              }];
        [actionsAlertController addAction:defaultAction];
        controller=actionsAlertController;
    }
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self actionForRow:indexPath.row];
}

-(NSInteger)tableView:(UITableView*) tableView numberOfRowsInSection: (NSInteger) section{
    return (NSInteger)[actionsArray count];
}

-(void)actionForRow:(NSInteger)row{
    if(row==0){
        [((AppDelegate*)[UIApplication sharedApplication].delegate) refreshState];
    }
    else if(row==1){
        [((AppDelegate*)[UIApplication sharedApplication].delegate) startStream];
    }
    else if(row==2){
        [((AppDelegate*)[UIApplication sharedApplication].delegate) delay5min];
    }
    else if(row==3){
        [((AppDelegate*)[UIApplication sharedApplication].delegate) changeStateSurveillance];
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) index{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"identifier"];
    }
    cell.textLabel.text =[actionsArray objectAtIndex:index.row];
    cell.textLabel.textAlignment =NSTextAlignmentCenter;
    cell.backgroundColor=[UIColor clearColor];
    cell.layoutMargins = UIEdgeInsetsZero;
    if([cell.textLabel.text isEqualToString:@"Stop"]){
        cell.textLabel.textColor=[UIColor redColor];
    }
    else if ([cell.textLabel.text isEqualToString:@"Start"]){
        cell.textLabel.textColor=[UIColor colorWithRed:0.0 green:(220.0/255.0) blue:0.0 alpha:1.0];
    }
    else{
        cell.textLabel.textColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    }
    if(index.row==2){
            cell.userInteractionEnabled = cell.textLabel.enabled=([cell.textLabel.text isEqualToString:@"Delay 5 min"]&&[[actionsArray objectAtIndex:3]isEqualToString:@"Start"]);
    }
    return cell;
}

-(void)setTimerString:(NSString *)string{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [actionsArray replaceObjectAtIndex:2 withObject:string];
        [((UITableViewController*)controller).tableView reloadData];
    }
    else{
        [((UIAlertController*)controller).actions objectAtIndex:2].enabled=[string isEqualToString:@"Delay 5 min"];
        ((UIAlertController*)controller).message=string;
        ((UIAlertController*)controller).title=@"Start in:";
        if ([string isEqualToString:@"Delay 5 min"]){
            ((UIAlertController*)controller).title=@"Actions";
        }
    }
}
@end
