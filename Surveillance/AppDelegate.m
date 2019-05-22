//
//  AppDelegate.m
//  Surveillance
//
//  Created by Alexandre Marquis on 09/07/2016.
//  Copyright © 2016 Alexandre Marquis. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize array;
@synthesize tableController;
@synthesize images;
@synthesize window;

BOOL fieldShouldRespond;
NSString* adresse;
UIBarButtonItem* statutButton;
static UIActionsControllerContainer* actionsController;
static NSURLSession* session;
static NSDate* backgroundDate;
static int secondes;
static WKWebView*web;
extern NSMutableArray* actionsArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window makeKeyAndVisible];
    actionsArray=[[NSMutableArray alloc]initWithArray:@[@"Refresh",@"Stream",@"Delay 5 min",@"Start"]];
    session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue currentQueue]];
	adresse=[NSString stringWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Adress.txt"] encoding:NSUTF8StringEncoding error:nil];
	if (adresse==nil){
		adresse=@"";
	}
	UITableView* table =[[UITableView alloc]initWithFrame:CGRectMake(0,64-([window frame].size.height/10),[window frame].size.width,[window frame].size.height-64-([window frame].size.height/10))];
	table.cellLayoutMarginsFollowReadableWidth = NO;
	table.delegate=self;
	table.dataSource=self;
	table.rowHeight=[window frame].size.height/10;
	tableController=[[UITableViewController alloc]init];
	tableController.refreshControl = [[UIRefreshControl alloc] init];
    tableController.refreshControl.tintColor = [UIColor lightGrayColor];
    [tableController.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
	tableController.tableView=table;
	tableController.title=@"Vidéos";
	table.allowsMultipleSelectionDuringEditing=YES;
	UINavigationController* navController=[[UINavigationController alloc]initWithRootViewController:tableController];
    [navController setToolbarHidden:NO animated:YES];
    window.rootViewController=navController;
	UIBarButtonItem* settingButton=[[UIBarButtonItem alloc]initWithTitle:@"IP Adress" style:UIBarButtonItemStyleDone target:self action:@selector(showSettingsView)];
	UIBarButtonItem* space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[[navController.viewControllers objectAtIndex:0] setToolbarItems:@[space,settingButton,space] animated:YES];
	UIBarButtonItem* editButton= [[UIBarButtonItem alloc]initWithTitle:@"Edit"  style:UIBarButtonItemStyleDone target:self action:@selector(editTable:)];
	editButton.possibleTitles=[NSSet setWithArray:@[@"Edit",@"Done"]];
	[tableController.navigationItem setRightBarButtonItem:editButton animated:YES];
	statutButton= [[UIBarButtonItem alloc]initWithTitle:@"Off" style:UIBarButtonItemStyleDone target:self action:@selector(showActions)];
	statutButton.tintColor=[UIColor redColor];
	statutButton.possibleTitles=[NSSet setWithArray:@[@"On",@"Off"]];
	[tableController.navigationItem setLeftBarButtonItem:statutButton animated:YES];
    secondes = -1;
    return YES;
}

-(void)showSettingsView{
    UIAlertController* alert=[UIAlertController alertControllerWithTitle:@"IP Adress" message:@"Enter the server's adress"  preferredStyle:UIAlertControllerStyleAlert];
    UITextField* IPField = [[UITextField alloc]init];
    fieldShouldRespond = false;
    [alert addTextFieldWithConfigurationHandler:^(UITextField* IPField){IPField.text = adresse;
                                                                        IPField.delegate = self;
                                                                        fieldShouldRespond = false;}];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [window.rootViewController presentViewController:alert animated:YES completion:^{fieldShouldRespond = true;}];
}

-(void)showActions{
    actionsController =[[UIActionsControllerContainer alloc] init];
    if (secondes>-1){
        secondes++;
        [self delayDecrement:nil];
    }
    [window.rootViewController presentViewController:actionsController.controller animated:YES completion:nil];
}

-(void)startStream{
    web=[[WKWebView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    web.navigationDelegate=self;
    web.scrollView.userInteractionEnabled=NO;
    [web addGestureRecognizer:[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(closeStream)]];
    [web loadRequest:[self authRequestWithString:[NSString stringWithFormat:@"%@stream.php",adresse]]];
    [window addSubview:web];
    UIView*tempView=[[UIView alloc]initWithFrame:CGRectMake(window.center.x-1,window.center.y-1,0,0)];
    tempView.backgroundColor=[UIColor blackColor];
    [window addSubview:tempView];
    [UIView animateWithDuration:1.5 delay:0 options:0 animations:^(void){tempView.frame=window.frame;} completion:^(BOOL finished){}];
}

-(void)closeStream{
    UIGraphicsBeginImageContextWithOptions(web.bounds.size, YES, 0);
    [web drawViewHierarchyInRect:web.bounds afterScreenUpdates:YES];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView* imView=[[UIImageView alloc]initWithImage:image];
    [window addSubview:imView];
    [web removeFromSuperview];
    web=nil;
    [UIView animateWithDuration:2 delay:0 options:0 animations:^(void){imView.frame=CGRectMake(window.center.x-1,window.center.y-1,2,2);} completion:^(BOOL finished){if(finished){
        [imView removeFromSuperview];
    }}];
    NSMutableURLRequest* request=[self authRequestWithString:[NSString stringWithFormat:@"%@closeStream.php",adresse]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {}];
    [task resume];
}

-(void)changeStateSurveillance{
	UIActivityIndicatorView* activity =[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	statutButton.customView=activity;
	[activity startAnimating];
	NSMutableURLRequest *request=[self authRequestWithString:[NSString stringWithFormat:@"%@startCloseSurveillance.php",adresse]];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self refreshState];}];
	[task resume];	
}

-(void)refreshData{
    [tableController.refreshControl beginRefreshing];
    NSMutableURLRequest* request=[self authRequestWithString:[NSString stringWithFormat:@"%@listVideos.php",adresse]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!data){
            UIAlertController* alert=[UIAlertController alertControllerWithTitle:@"Erreur" message:[NSString stringWithFormat:@"Adress: %@ Error: %@",[NSString stringWithFormat:@"%@listVideos.php",adresse],error ] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
        else{
            array = [[NSMutableArray alloc]initWithArray:[[[NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: nil] reverseObjectEnumerator]allObjects]];
            for (int i=(int)[array count]-1; i>-1;i--){
                if([[array objectAtIndex:i] isEqualToString:@"."]==YES || [[array objectAtIndex:i] isEqualToString:@".."]== YES){
                    [array removeObject:[array objectAtIndex:i]];
                }
            }
            images=[[NSMutableArray alloc]init];
            for (int k=0; k<[array count]; k++){
                [images addObject:[[UIImage alloc]init]];
            }
            for (int k=0; k<[array count]; k++){
                NSString* file= [[array objectAtIndex:k] stringByReplacingOccurrencesOfString:@".mp4" withString:@".jpg"];
                NSMutableURLRequest*request=[self authRequestWithString:[NSString stringWithFormat:@"%@PhotosSurveillance/%@",adresse,file]];
                NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            [images replaceObjectAtIndex:k withObject:[[UIImage alloc]initWithData:data]];
                                                            [tableController.tableView reloadData];
                                                        }];
                [task resume];
            }
        }
        [tableController.refreshControl endRefreshing];
        [tableController.tableView reloadData];
    }];
    [task resume];
}

-(void)refreshState{
	UIActivityIndicatorView* activity =[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	statutButton.customView=activity;
	[activity startAnimating];
	NSMutableURLRequest *request=[self authRequestWithString:[NSString stringWithFormat:@"%@Documents/SurveillanceRunning.txt",adresse]];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (data==nil || [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding].length >10){
			statutButton.title=@"Off";
			statutButton.tintColor=[UIColor redColor];
			[actionsArray replaceObjectAtIndex:[actionsArray count]-1 withObject:@"Start"];
			
		}
		else{
	  	 	statutButton.title=@"On";
			statutButton.tintColor=[UIColor colorWithRed:0.0 green:(220.0/255.0) blue:0.0 alpha:1.0];
			[actionsArray replaceObjectAtIndex:[actionsArray count]-1 withObject:@"Stop"];

		}
		[((UIActivityIndicatorView*)statutButton.customView) stopAnimating];
		statutButton.customView=nil;
		}];
	[task resume];
}

-(void)delay5min{
    secondes=300;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(delayDecrement:) userInfo:nil repeats:YES];
    NSMutableURLRequest *request=[self authRequestWithString:[NSString stringWithFormat:@"%@start5MinSurveillance.php",adresse]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){}];
    [task resume];
}

-(void)delayDecrement:(NSTimer*)timer{
    secondes--;
    NSString* secondesString=[NSString stringWithFormat:@"%d",((int)secondes%60)];
    if (secondesString.length<2){
        secondesString=[NSString stringWithFormat:@"0%d",((int)secondes%60)];
    }
    if ([actionsController respondsToSelector:@selector(setTimerString:)]){
        actionsController.timerString=[NSString stringWithFormat:@"%d:%@",((int)secondes/60),secondesString];
    }
    if(secondes==0){
        [self refreshState];
        [timer invalidate];
        [actionsArray replaceObjectAtIndex:2 withObject:@"Delay 5 min"];
        actionsController.timerString=@"Delay 5 min";
    }
}

-(void)deleteAction{
    [self deleteVideos:tableController.tableView.indexPathsForSelectedRows];
    [self editTable:tableController.navigationItem.rightBarButtonItem];
}

-(void)deleteVideos:(NSArray*) videos{
	NSMutableArray* videosToDelete=[[NSMutableArray alloc]init];
    NSMutableArray* rowsToDelete=[[NSMutableArray alloc]init];
    for (NSInteger k=[videos count]-1;k>-1;k--){
		[videosToDelete addObject: [[array objectAtIndex:((NSIndexPath*)[videos objectAtIndex:k]).row] stringByReplacingOccurrencesOfString:@".mp4" withString:@""]];
        [rowsToDelete addObject:[NSNumber numberWithLong:((NSIndexPath*)[videos objectAtIndex:k]).row]];
    }
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    [rowsToDelete sortUsingDescriptors:@[highestToLowest]];
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:videosToDelete options:0 error:nil ];
	NSMutableURLRequest* request=[self authRequestWithString:[NSString stringWithFormat:@"%@deleteVideos.php",adresse]];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postdata];
	NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:postdata completionHandler:^(NSData* data, NSURLResponse *response, NSError *error) {}];
	for (int k=0;k<[videos count];k++){
        [array removeObjectAtIndex:((NSNumber*)[rowsToDelete objectAtIndex:k]).intValue];
		[images removeObjectAtIndex:((NSNumber*)[rowsToDelete objectAtIndex:k]).intValue];
	}	
	[tableController.tableView deleteRowsAtIndexPaths:videos withRowAnimation:UITableViewRowAnimationLeft];
	[task resume];
	
}

-(NSMutableURLRequest*)authRequestWithString:(NSString*)string{
    NSMutableURLRequest* request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:string]];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@",@"Alexandre",@"Alex123321123321"];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@",[authData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    return request;
}

-(void)editTable:(UIBarButtonItem*) sender{
    if (!tableController.tableView.editing){
        [tableController.tableView setEditing: YES animated:YES];
        UIBarButtonItem* deleteButton= [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStyleDone target:self action:@selector(deleteAction)];
        deleteButton.tintColor=[UIColor redColor];
        [tableController.navigationItem setLeftBarButtonItems:@[deleteButton,statutButton] animated:YES];
        sender.title=@"Done";
    }
    else{
        [tableController.tableView setEditing: NO animated:YES];
        [tableController.navigationItem setLeftBarButtonItems:@[statutButton] animated:YES];
        sender.title=@"Edit";
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [self deleteVideos:@[indexPath]];}];
    return @[editAction];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!tableView.editing){
        AVAsset* avAsset = [AVAsset assetWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://Alexandre:Alex123321123321@%@VideosSurveillance/%@",[[adresse componentsSeparatedByString:@"://"]objectAtIndex:0],[[adresse componentsSeparatedByString:@"://"]objectAtIndex:1],[array objectAtIndex:indexPath.row]]]];
        AVPlayerItem* avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
        AVPlayer*avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
        AVPlayerViewController*cont=[[AVPlayerViewController alloc]init];
        cont.player=avPlayer;
        [window.rootViewController presentViewController:cont animated:YES completion:nil];
        [avPlayer seekToTime: kCMTimeZero];
        [avPlayer play];
    }
}

-(NSInteger)tableView:(UITableView*) tableView numberOfRowsInSection: (NSInteger) section{
    return (NSInteger)[array count];
}

-(UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) index{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"identifier"];
    }
    NSString* file= [[array objectAtIndex:index.row] stringByReplacingOccurrencesOfString:@".mp4" withString:@""];
    NSString* text= [file stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    text= [text stringByReplacingOccurrencesOfString:@"@" withString:@"-"];
    NSDateFormatter* format=[[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date= [format dateFromString:text];
    [format setDateStyle:NSDateFormatterLongStyle];
    [format setTimeStyle:NSDateFormatterMediumStyle];
    cell.textLabel.text =[format stringFromDate:date];
    if (index.row <[images count]){
        cell.imageView.image=[images objectAtIndex:index.row];
    }
    return cell;
}

-(void)webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)nav{
	[window addSubview:webView];
	[[[window subviews]objectAtIndex:[[window subviews]count]-2] removeFromSuperview];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField* )field{
    return fieldShouldRespond;
}

-(BOOL)textFieldShouldEndEditing:(UITextField* )field{
    adresse = field.text;
    [adresse writeToFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Adress.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return true;
}

-(void)applicationDidBecomeActive:(UIApplication *)application{
	[self refreshData];
	[self refreshState];
	if (backgroundDate){
        secondes=secondes-[[NSDate date] timeIntervalSinceDate:backgroundDate];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application{
	[tableController.refreshControl endRefreshing];
	if(secondes>-1){
        backgroundDate=[[NSDate alloc]init];
	}
}

-(void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation{
    if (web){
        web.frame=[[UIScreen mainScreen]bounds];
    }
}
@end
