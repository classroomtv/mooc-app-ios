//
//  OEXRearTableViewController.m
//  edXVideoLocker
//
//  Created by Nirbhay Agarwal on 16/05/14.
//  Copyright (c) 2014 edX. All rights reserved.
//

#import "OEXRearTableViewController.h"

#import "NSBundle+OEXConveniences.h"

#import "OEXAppDelegate.h"
#import "OEXCustomLabel.h"
#import "OEXAuthentication.h"
#import "OEXConfig.h"
#import "OEXFindCoursesViewController.h"
#import "OEXImageCache.h"
#import "OEXInterface.h"
#import "OEXMySettingsViewController.h"
#import "OEXMyVideosViewController.h"
#import "OEXNetworkConstants.h"
#import "OEXUserDetails.h"
#import "SWRevealViewController.h"

typedef NS_ENUM(NSUInteger, OEXRearViewOptions)
{
    MyCourse=1,
    MyVideos,
    FindCourses,
    MySettings,
    SubmitFeedback,
};

@interface OEXRearTableViewController ()

@property (nonatomic, strong) OEXInterface * dataInterface;
@property (nonatomic, strong) IBOutlet UILabel* coursesLabel;
@property (nonatomic, strong) IBOutlet UILabel* videosLabel;
@property (nonatomic, strong) IBOutlet UILabel* findCoursesLabel;
@property (nonatomic, strong) IBOutlet UILabel* settingsLabel;
@property (nonatomic, strong) IBOutlet UILabel* submitFeedbackLabel;
@property (nonatomic, strong) IBOutlet UIButton* logoutButton;

@end

@implementation OEXRearTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //EdX Interface
    self.dataInterface = [OEXInterface sharedInterface];
    
    //Call API
    if (!_dataInterface.userdetail) {
        
        if ([OEXAuthentication getLoggedInUser]) {
            _dataInterface.userdetail=[OEXAuthentication getLoggedInUser];
              self.userNameLabel.text = _dataInterface.userdetail.name;
              self.userEmailLabel.text = _dataInterface.userdetail.email;
        }

    }
    else {
        self.userNameLabel.text = _dataInterface.userdetail.name;
        self.userEmailLabel.text = _dataInterface.userdetail.email;
    }
    
    NSString* environmentName = [[OEXConfig sharedConfig] environmentName];
    NSString* appVersion = [[NSBundle mainBundle] oex_shortVersionString];
    self.lbl_AppVersion.text = [NSString stringWithFormat:@"Version %@ %@", appVersion, environmentName];
    
    
    //UI
    [self.logoutButton setBackgroundImage:[UIImage imageNamed:@"bt_logout_active.png"] forState:UIControlStateHighlighted];
    
    //set wifi only switch position
    [_wifiOnlySwitch setOn:[OEXInterface shouldDownloadOnlyOnWifi]];
    
    //Listen to notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataAvailable:) name:NOTIFICATION_URL_RESPONSE object:nil];
    
    self.coursesLabel.text = [OEXLocalizedString(@"MY_COURSES", nil) uppercaseStringWithLocale:[[NSBundle mainBundle] oex_displayLocale]];
    self.videosLabel.text = [OEXLocalizedString(@"MY_VIDEOS", nil) uppercaseStringWithLocale:[[NSBundle mainBundle] oex_displayLocale]];
    self.findCoursesLabel.text = [OEXLocalizedString(@"FIND_COURSES", nil) uppercaseStringWithLocale:[[NSBundle mainBundle] oex_displayLocale]];
    self.settingsLabel.text = [OEXLocalizedString(@"MY_SETTINGS", nil) uppercaseStringWithLocale:[[NSBundle mainBundle] oex_displayLocale]];
    self.submitFeedbackLabel.text = [OEXLocalizedString(@"SUBMIT_FEEDBACK", nil) uppercaseStringWithLocale:[[NSBundle mainBundle] oex_displayLocale]];
    [self.logoutButton setTitle:[OEXLocalizedString(@"LOGOUT", nil) uppercaseStringWithLocale:[[NSBundle mainBundle] oex_displayLocale]] forState:UIControlStateNormal];
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // configure the segue.
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] )
    {
        SWRevealViewControllerSegue* rvcs = (SWRevealViewControllerSegue*) segue;
        
        SWRevealViewController* rvc = self.revealViewController;
        NSAssert( rvc != nil, @"oops! must have a revealViewController" );
        
        NSAssert( [rvc.frontViewController isKindOfClass: [UINavigationController class]], @"oops!  for this segue we want a permanent navigation controller in the front!" );
        
        rvcs.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc)
        {
            UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:dvc];
            [rvc pushFrontViewController:nc animated:YES];
        };
    }
}

- (void)launchEmailComposer {
    OEXAppDelegate *appDelegate = (OEXAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.pendingMailComposerLaunch = YES;
    [self.revealViewController revealToggleAnimated:YES];
}

#pragma mark TableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0)
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    UIView *seperatorImage=[cell.contentView viewWithTag:10];
    if(seperatorImage)
    {
        seperatorImage.hidden=YES;
    }


}
- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    UIView *seperatorImage=[cell.contentView viewWithTag:10];
    if(seperatorImage)
    {
        [self performSelector:@selector(hideSeperatorImage:) withObject:seperatorImage afterDelay:0.5];
    }
    

}

-(void)hideSeperatorImage:(UIView *)view
{
   
    view.hidden=NO;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OEXRearViewOptions rearViewOptions = indexPath.row;
    
    switch (rearViewOptions)
    {
        case MyCourse: // MY COURSES
            [self.view setUserInteractionEnabled:NO];
            [self performSegueWithIdentifier:@"showCourse" sender:self];
            break;
            
        case MyVideos: // MY VIDEOS
            [self.view setUserInteractionEnabled:NO];
            [self performSegueWithIdentifier:@"showVideo" sender:self];
            break;
            
        case FindCourses: // FIND COURSES
        {
            [self.view setUserInteractionEnabled:NO];
            SWRevealViewController* rvc = self.revealViewController;
            OEXFindCoursesViewController *findCoursesViewController = [[OEXFindCoursesViewController alloc] init];
            UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:findCoursesViewController];
            [rvc pushFrontViewController:nc animated:YES];
        }
            break;

        case MySettings: // MY SETTINGS
        {
            [self.view setUserInteractionEnabled:NO];
            SWRevealViewController* rvc = self.revealViewController;
            OEXMySettingsViewController *mySettingsViewController = [[OEXMySettingsViewController alloc] init];
            UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:mySettingsViewController];
            [rvc pushFrontViewController:nc animated:YES];
        }
            break;

            
        case SubmitFeedback:
            [self launchEmailComposer];
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark edXInterface Delegate

- (void)dataAvailable:(NSNotification *)notification {
    NSDictionary *userDetailsDict = (NSDictionary *)notification.userInfo;
    
    NSString * successString = [userDetailsDict objectForKey:NOTIFICATION_KEY_STATUS];
    NSString * URLString = [userDetailsDict objectForKey:NOTIFICATION_KEY_URL];
    if ([successString isEqualToString:NOTIFICATION_VALUE_URL_STATUS_SUCCESS] && [URLString isEqualToString:[_dataInterface URLStringForType:URL_USER_DETAILS]])
    {    
        self.userNameLabel.text = _dataInterface.userdetail.name;
        self.userEmailLabel.text = _dataInterface.userdetail.email;
        
    }
}

- (IBAction)logoutClicked:(id)sender
{

    // Analytics User Logout
    [[OEXAnalytics sharedAnalytics] trackUserLogout];
    // Analytics tagging
    [[OEXAnalytics sharedAnalytics] clearIdentifiedUser];
    UIButton * button = (UIButton *)sender;
    [button setBackgroundImage:[UIImage imageNamed:@"bt_logout_active.png"] forState:UIControlStateNormal];
    // Set the language to blank
    [OEXInterface setCCSelectedLanguage:@""];
    [self deactivateAndPop];
    [[OEXImageCache sharedInstance] clearImagesFromMainCacheMemory];
    NSLog(@"logoutClicked");
}

- (void)deactivateAndPop
{
    
    NSLog(@"deactivateAndPop");
    [[OEXInterface sharedInterface] deactivateWithCompletionHandler:^{
    NSLog(@"should pop");
        [self performSelectorOnMainThread:@selector(pop) withObject:nil waitUntilDone:NO];
        [OEXAuthentication clearUserSession];
    }];
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)wifiOnlySwitchChanges:(id)sender {
    if (!_wifiOnlySwitch.isOn) {
        [[[UIAlertView alloc] initWithTitle:OEXLocalizedString(@"CELLULAR_DOWNLOAD_ENABLED_TITLE", nil)
                                   message:OEXLocalizedString(@"CELLULAR_DOWNLOAD_ENABLED_MESSAGE", nil)
                                  delegate:self
                         cancelButtonTitle:OEXLocalizedString(@"ALLOW", nil)
                          otherButtonTitles:OEXLocalizedString(@"DO_NOT_ALLOW", nil), nil] show];
    }
    else {
        [OEXInterface setDownloadOnlyOnWifiPref:_wifiOnlySwitch.isOn];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [_wifiOnlySwitch setOn:YES animated:NO];
    }
    [OEXInterface setDownloadOnlyOnWifiPref:_wifiOnlySwitch.isOn];
}

-(void)viewDidDisappear:(BOOL)animated{

    [self.view setUserInteractionEnabled:YES];

}

@end
