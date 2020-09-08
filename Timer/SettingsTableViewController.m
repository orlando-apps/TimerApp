@import GoogleMobileAds;
#import "SettingsTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "Chameleon.h"

#define HeaderHeight      25
#define BackgroundColorOne      flatGrayDarkColor
#define BackgroundColorTwo      flatSkyBlueColor


@interface SettingsTableViewController ()<MFMailComposeViewControllerDelegate>

@property(nonatomic, strong) GADBannerView *bannerView;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Settings";
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:YES];
    self.tableView.backgroundColor = [UIColor clearColor];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIView *backgroundView = [[UIView alloc]initWithFrame:screenRect];
    [self.navigationController.view insertSubview:backgroundView atIndex:0];
    [backgroundView setBackgroundColor:[UIColor colorWithGradientStyle:UIGradientStyleTopToBottom
                                                             withFrame:self.tableView.bounds andColors:
                                        @[[UIColor BackgroundColorOne],[UIColor BackgroundColorTwo]]]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable)
     
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
    //hide extra cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // In this case, we instantiate the banner with desired ad size.
    self.bannerView = [[GADBannerView alloc]
                       initWithAdSize:kGADAdSizeSmartBannerPortrait];
    [self addBannerViewToView:self.bannerView];
    self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];

}

-(void)refreshTable{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    if(indexPath.row == 0 && indexPath.section == 0){
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]){
            // Check it's iOS 8 and above
            UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
            
            if (grantedSettings.types  & UIUserNotificationTypeAlert){
                self.hasNotification = YES;
                if (grantedSettings.types & UIUserNotificationTypeBadge) {
                    self.hasNotification = YES;
                    if (grantedSettings.types & UIUserNotificationTypeSound){
                        self.hasNotification = YES;
                    } else {
                        self.hasNotification = NO;
                    }
                }else {
                    self.hasNotification = NO;
            }
            }else {
                self.hasNotification = NO;
            }
        }

        if (self.hasNotification){
            self.notificationCheck.text = @"Yes";
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            self.notificationCheck.text = @"No";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }

    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];

    return cell;
}


- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return HeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return HeaderHeight;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //add separator to top cell
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1 / UIScreen.mainScreen.scale)];
    UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.separatorInset.left, HeaderHeight, self.tableView.frame.size.width - self.tableView.separatorInset.left - self.tableView.separatorInset.right, 1 / UIScreen.mainScreen.scale)];
    topSeparator.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:topSeparator];
   // headerView.backgroundColor = [ UIColor greenColor];
    //self.tableView.tableHeaderView = headerView;
    return headerView;
}

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    //add separator to top cell
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1 / UIScreen.mainScreen.scale)];
    UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.separatorInset.left, 0, self.tableView.frame.size.width - self.tableView.separatorInset.left - self.tableView.separatorInset.right, 1 / UIScreen.mainScreen.scale)];
    topSeparator.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:topSeparator];
    // headerView.backgroundColor = [ UIColor greenColor];
    //self.tableView.tableHeaderView = headerView;
    return footerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0 && indexPath.section == 0){
        if (!self.hasNotification){
            NSLog(@"did it load notification");
            [self redirectNotificationSettings];
        }
    }
    
    if(indexPath.row == 0 && indexPath.section == 1)
    {
        NSLog(@"did it load email");
        [self sendEmail];
    }
    
    if(indexPath.row == 0 && indexPath.section == 0){
        //handle rating link
    }
}


- (void)sendEmail {
    // Email Subject
    NSString *emailTitle = @"FeedBack";
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"driesdreya@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


-(void)redirectNotificationSettings
{
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"To enable notifications, please update your settings"  message:nil  preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction* gotoButton = [UIAlertAction
                                   actionWithTitle:@"Goto Settings"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       @try
                                       {
                                           NSLog(@"tapped ok");
                                           BOOL canOpenSettings = (UIApplicationOpenSettingsURLString != NULL);
                                           if (canOpenSettings)
                                           {
                                               NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                               [[UIApplication sharedApplication] openURL:url];
                                           }
                                       }
                                       @catch (NSException *exception)
                                       {
                                           
                                       }                                   }];
    
    
    UIAlertAction* cancelButton = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     //Handle your yes please button action here
                                 }];
    
    [alertController addAction:cancelButton];
    [alertController addAction:gotoButton];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}


- (void)addBannerViewToView:(UIView *)bannerView {
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bannerView];
    if (@available(ios 11.0, *)) {
        // In iOS 11, we need to constrain the view to the safe area.
        [self positionBannerViewFullWidthAtBottomOfSafeArea:bannerView];
    } else {
        // In lower iOS versions, safe area is not available so we use
        // bottom layout guide and view edges.
        [self positionBannerViewFullWidthAtBottomOfView:bannerView];
    }
}

#pragma mark - view positioning

- (void)positionBannerViewFullWidthAtBottomOfSafeArea:(UIView *_Nonnull)bannerView NS_AVAILABLE_IOS(11.0) {
    // Position the banner. Stick it to the bottom of the Safe Area.
    // Make it constrained to the edges of the safe area.
    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    
    [NSLayoutConstraint activateConstraints:@[
                                              [guide.leftAnchor constraintEqualToAnchor:bannerView.leftAnchor],
                                              [guide.rightAnchor constraintEqualToAnchor:bannerView.rightAnchor],
                                              [guide.bottomAnchor constraintEqualToAnchor:bannerView.bottomAnchor]
                                              ]];
}

- (void)positionBannerViewFullWidthAtBottomOfView:(UIView *_Nonnull)bannerView {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bannerView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.tableView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bannerView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.tableView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bannerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.bottomLayoutGuide
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
