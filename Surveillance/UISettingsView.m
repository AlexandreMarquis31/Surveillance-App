//
//  UISettingsView.m
//  Surveillance
//
//  Created by Alexandre Marquis on 10/07/2016.
//  Copyright © 2016 Alexandre Marquis. All rights reserved.
//

#import "UISettingsView.h"
#define screenHeight [[UIApplication sharedApplication]keyWindow].frame.size.height
#define screenWidth [[UIApplication sharedApplication]keyWindow].frame.size.width

extern NSString* adresse;
static UINavigationBar* bar;

@interface AppDelegate{}
-(void)hideSettingsView;
@end

@implementation UISettingsView;
@synthesize settingsTableView;
@synthesize IPAdress;
@synthesize cellWasSelected;

-(UIView*)init{
    float factor;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        factor=0.4;
    }
    else{
        factor= 0.8;
    }
    CGRect frame=CGRectMake((screenWidth-(screenWidth*factor))/2,screenHeight,screenWidth*factor,screenHeight*factor);
    IPAdress=[[NSMutableArray alloc]initWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"IPAdress.txt"]];
    if (!IPAdress){
        IPAdress=[[NSMutableArray alloc]initWithArray:@[]];
    }
    self=[super initWithFrame:frame];
    self.layer.cornerRadius=25;
    self.layer.borderWidth=1;
    self.layer.borderColor=[UIColor lightGrayColor].CGColor;
    settingsTableView=[[UITableView alloc]initWithFrame:CGRectMake(0,44,frame.size.width,frame.size.height-44)];
    settingsTableView.scrollEnabled=NO;
    settingsTableView.rowHeight=frame.size.height/12;
    [settingsTableView setEditing: YES animated:YES];
    settingsTableView.allowsMultipleSelectionDuringEditing=YES;
    settingsTableView.delegate=self;
    settingsTableView.dataSource=self;
    settingsTableView.separatorColor=[UIColor clearColor];
    UINavigationItem*item=[[UINavigationItem alloc]initWithTitle:@"IP Adress"];
    item.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:((AppDelegate*)[UIApplication sharedApplication].delegate) action:@selector(hideSettingsView)];
    item.leftBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addIPAdress)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    bar=[[UINavigationBar alloc]initWithFrame:CGRectMake(0,0,frame.size.width,44)];
    maskLayer.frame = bar.bounds;
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:bar.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(25.0, 25.0)].CGPath;
    bar.layer.mask = maskLayer;
    cellWasSelected=NO;
    [bar setItems:@[item] animated:NO];
    [self addSubview:settingsTableView];
    [self addSubview:bar];
    return self;
}

-(void)addIPAdress{
    if (settingsTableView.rowHeight*([IPAdress count]+1)<settingsTableView.frame.size.height){
        [IPAdress addObject:@"New"];
        [settingsTableView reloadData];
    }
}

-(UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) index{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"identifier2"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"identifier2"];
    }
    UITapGestureRecognizer* gesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editName:)];
    gesture.numberOfTapsRequired=2;
    [cell addGestureRecognizer:gesture];
    UILongPressGestureRecognizer* longGesture=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(showDeleteAlert:)];
    [cell addGestureRecognizer:longGesture];
    cell.textLabel.userInteractionEnabled=YES;
    cell.selectedBackgroundView=[[UIView alloc]init];
    cell.textLabel.text =[IPAdress objectAtIndex:index.row];
    if([adresse isEqualToString:cell.textLabel.text]){
        [tableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView*) tableView numberOfRowsInSection: (NSInteger) section{
    return (NSInteger)[IPAdress count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    adresse=[IPAdress objectAtIndex:indexPath.row];
    [[adresse dataUsingEncoding:NSUTF8StringEncoding]writeToFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Adress.txt"] atomically:YES];
}

-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([tableView.indexPathsForSelectedRows count]==1){
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    }
    return indexPath;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    float factor;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        factor=0.4;
    }
    else{
        factor=0.8;
    }
    self.frame=CGRectMake((screenWidth-(screenWidth*factor))/2,(screenHeight-(screenHeight*factor))/2,screenWidth*factor,screenHeight*factor);
    bar.frame=CGRectMake(0,0,screenWidth*factor,44);
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bar.bounds;
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:bar.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(25.0, 25.0)].CGPath;
    bar.layer.mask = maskLayer;
    settingsTableView.frame=CGRectMake(0,44,screenWidth*factor,screenHeight*factor-44);
    settingsTableView.rowHeight=self.frame.size.height/12;
}

-(void)editName:(UITapGestureRecognizer*)gesture{
    UITableViewCell* cell = ((UITableViewCell*)gesture.view);
    if(cell.selected==YES){
        [cell setSelected:NO animated:NO];
        cellWasSelected=YES;
    }
    UITextField* field=[[UITextField alloc]initWithFrame:CGRectMake(0,0,cell.textLabel.frame.size.width,cell.textLabel.frame.size.height)];
    field.textAlignment =NSTextAlignmentCenter;
    field.backgroundColor=[UIColor whiteColor];
    field.delegate=self;
    field.text=cell.textLabel.text;
    [cell.textLabel addSubview:field];
    [field becomeFirstResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    UITableViewCell* cell = ((UITableViewCell*)[[[textField superview ]superview]superview]);
    cell.textLabel.text=textField.text;
    if ([cell.textLabel.text isEqualToString:@""]){
        cell.textLabel.text=@"New";
    }
    [self.IPAdress replaceObjectAtIndex:[settingsTableView indexPathForCell:cell].row withObject:textField.text];
    [textField removeFromSuperview];
    if(cellWasSelected==YES){
        [cell setSelected:YES animated:NO];
        cellWasSelected=NO;
    }
}

-(void)showDeleteAlert:(UIGestureRecognizer*)gesture{
    UITableViewCell* cell = ((UITableViewCell*)gesture.view);
    UIAlertController* alert=[UIAlertController alertControllerWithTitle:@"Delete" message:@"Do you really want to delete this adress?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * action) {
                                                             UITableView* table=((UITableView*)[[cell superview]superview]);
                                                             [self.IPAdress removeObjectAtIndex:[table indexPathForCell:cell].row];
                                                             [table deleteRowsAtIndexPaths:@[[table indexPathForCell:cell]]withRowAnimation:UITableViewRowAnimationFade];
                                                         }];
   	[alert addAction:defaultAction];
    [alert addAction:deleteAction];
    [[[[[UIApplication sharedApplication]delegate]window]rootViewController] presentViewController:alert animated:YES completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
