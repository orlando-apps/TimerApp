#import <UIKit/UIKit.h>

@interface TimerTypesTableViewController : UITableViewController
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) double firstOrderValue;

@end
