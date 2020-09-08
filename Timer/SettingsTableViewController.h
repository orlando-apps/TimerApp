#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *notificationCheck;

@property (assign, nonatomic) BOOL hasNotification;

@end
