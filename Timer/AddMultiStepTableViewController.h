#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AddStepTableViewController.h"

@interface AddMultiStepTableViewController : UITableViewController <AddStepDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) double firstOrderValue;
@property (strong, nonatomic) NSManagedObject *editRecord;
@property (nonatomic, strong) NSIndexPath * editIndexPath;

@property (assign, nonatomic) BOOL newRecord;
@property (strong, nonatomic) NSString *timerTitle;
@property (strong, nonatomic) UITextField *titleField;

@property (weak, nonatomic) IBOutlet UIView *tableHeader;

@property (strong, nonatomic) NSMutableArray * allSteps;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSMutableArray *rows;

@property (strong, nonatomic) UIButton * editButton;

@end
