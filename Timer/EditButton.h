#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface EditButton : UIButton

@property (nonatomic, strong) NSManagedObject * record;
@property (nonatomic, strong) NSIndexPath * editIndexPath;

@end
