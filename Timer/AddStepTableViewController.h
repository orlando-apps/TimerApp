#import <UIKit/UIKit.h>

@protocol AddStepDelegate

- (void)receivedNewData:(NSArray *)stepTime title:(NSString *)stepTitle;
- (void)receivedEditData:(NSArray *)stepTime title:(NSString *)stepTitle position:(NSInteger) position;

@end

@interface AddStepTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIView *dateViewContainer;
@property (weak, nonatomic) IBOutlet UITextField *stepName;

@property(nonatomic, assign) NSInteger existingPosition;
@property (strong, nonatomic) NSString * existingTitle;
@property (strong, nonatomic) NSArray * existingComponents;
@property (nonatomic, assign) BOOL isExisting;
@property (nonatomic, assign) BOOL isAddStep;

@property (nonatomic, weak) id<AddStepDelegate> delegate;

@end
