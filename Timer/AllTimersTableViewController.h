#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AllTimersTableViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableArray * activeArray;
@property (nonatomic, strong) NSMutableArray * inactiveArray;

@property (assign, nonatomic) BOOL userDrivenDataModelChange;
@property (assign, nonatomic) BOOL activeTimers;

@property (strong, nonatomic) NSManagedObject * editRecord;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@end
