#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class AllTimersTableViewCell;
@protocol CellDelegate <NSObject>
- (void)addActive:(AllTimersTableViewCell*)cell;
- (void)subtractDeactive:(AllTimersTableViewCell*)cell;
@end

@interface AllTimersTableViewCell : UITableViewCell

@property (strong, nonatomic) NSString * timerName;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;

@property (strong, nonatomic) NSManagedObject *record;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepLabelConstraint;

@property (strong, nonatomic) NSCalendar* calendar;
@property (strong, nonatomic) NSDateComponents *components;
@property (strong, nonatomic) NSArray *allSteps;
@property (strong, nonatomic) NSTimer *stopWatchTimer;
@property (retain, nonatomic) NSDate *startDate;
@property (retain, nonatomic) NSDate *endDate;
@property (retain, nonatomic) NSDate *finalEndDate;

@property (retain, nonatomic) NSDate *pauseStart;
@property (retain, nonatomic) NSDate *previousFireDate;
@property (strong, nonatomic) NSMutableArray* allStepsCheck;
@property (nonatomic) double reminder;
@property (strong, nonatomic)NSString * uniqueID;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

@property (nonatomic, weak) id <CellDelegate> delegate;

@end
