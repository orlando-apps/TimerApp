#import <UIKit/UIKit.h>

@interface CustomUIDatePicker : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>

@property NSInteger hours;
@property NSInteger mins;
@property NSInteger secs;

-(NSInteger) getPickerTimeInMS;
-(void) initialize;

@end
