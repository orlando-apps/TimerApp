#import "AllTimersTableViewCell.h"
#import "Chameleon.h"

@implementation AllTimersTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
     self.backgroundColor = [UIColor clearColor];
     [self.stopButton setBackgroundColor:[UIColor flatRedColor]];
     [self.playButton setBackgroundColor:[UIColor flatGreenColor]];
     self.calendar = [NSCalendar currentCalendar];
     self.components= [[NSDateComponents alloc]init];
     self.stepLabelConstraint.constant = 155.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (IBAction)playButton:(id)sender {

    if ([self.playButton.titleLabel.text isEqualToString:@"start"])
    {
        [self.playButton setTitle:@"pause" forState:UIControlStateNormal];
        [self.playButton setBackgroundColor:[UIColor flatForestGreenDarkColor]];

        self.allStepsCheck  = [NSMutableArray arrayWithArray:self.allSteps];
        self.reminder = 0;
        [self startTimer];
        
    } else if ([self.playButton.titleLabel.text isEqualToString:@"pause"])
        {
        self.reminder = [self.endDate timeIntervalSinceNow];
        [self pauseTimer];
        [self.playButton setTitle:@"resume" forState:UIControlStateNormal];
        [self.playButton setBackgroundColor:[UIColor flatGrayDarkColor]];
            
    } else if ([self.playButton.titleLabel.text isEqualToString:@"resume"])
        {
        [self.playButton setTitle:@"pause" forState:UIControlStateNormal];
        [self.playButton setBackgroundColor:[UIColor flatForestGreenDarkColor]];
  
        [self resumeTimer:self.reminder];
        }
}


- (IBAction)stopButton:(id)sender {
    BOOL isComplete = NO;
    [self stopTimerWithMessage: isComplete];
}

- (void)updateTimer
{
    double di = [self.endDate timeIntervalSinceNow];

    NSInteger ti = ((NSInteger)round(di));
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600) % 24;
//  NSInteger days = (ti / 86400);

    self.timeLabel.text = [NSString stringWithFormat:@"%02li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
    
    if(ti == 0){
        NSLog(@"equal to zero");
        if ([self.allStepsCheck count] == 1){
            BOOL isComplete = YES;
            [self stopTimerWithMessage: isComplete];
        } else {
            [self.allStepsCheck removeObjectAtIndex:0];
            [self updateEndDateWithDic:self.allStepsCheck[0]];
        }
    }
}

-(void)stopTimerWithMessage:(BOOL)isComplete{
    
    [self.stopWatchTimer invalidate];
    self.stopWatchTimer = nil;
    self.allStepsCheck = nil;
    
    if(!isComplete)
    {
        [self cancelNotification:self.uniqueID];
        self.uniqueID = nil;
    }
    
    self.stepLabel.text = self.timerName;
    //self.stepLabel.text = [NSString stringWithFormat:@"%@", [[self.allSteps objectAtIndex:0] valueForKey:@"title"]];
    self.timeLabel.text = [NSString stringWithFormat:@"%@", [[self.allSteps objectAtIndex:0] valueForKey:@"timeString"]];
    
    [self.playButton setTitle:@"start" forState:UIControlStateNormal];
    [self.playButton setBackgroundColor:[UIColor flatGreenColor]];

    self.stepLabel.textColor =[UIColor whiteColor];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    
    [self.delegate subtractDeactive:self];
}

-(void) updateEndDateWithDic:(NSDictionary*)dictionary
{
    
    self.stepLabel.text = [NSString stringWithFormat: @"%@ - %@", self.timerName, [dictionary valueForKey:@"title"]];
    self.timeLabel.text = [dictionary valueForKey:@"timeString"];
    
    [self.components setHour: [[dictionary valueForKey:@"hourTime"] intValue]];
    [self.components setMinute:[[dictionary valueForKey:@"minTime"] intValue]];
    [self.components setSecond:[[dictionary valueForKey:@"secondTime"] intValue]];
    self.endDate = [self.calendar dateByAddingComponents:self.components toDate:[NSDate date] options:0];
}

-(void) updateFinalEndDate:(double)remainder withSteps:(NSMutableArray *)steps
{
    double roundReminder = ceil(remainder);
    [self.components setSecond:roundReminder];
    self.finalEndDate = [self.calendar dateByAddingComponents:self.components toDate:[NSDate date] options:0];

    NSDictionary *dic;
    int i;
    for (i = 1; i < [steps count]; i++) {
        dic = [steps objectAtIndex:i];
        [self.components setHour: [[dic valueForKey:@"hourTime"] intValue]];
        [self.components setMinute:[[dic valueForKey:@"minTime"] intValue]];
        [self.components setSecond:[[dic valueForKey:@"secondTime"] intValue]];
        self.finalEndDate = [self.calendar dateByAddingComponents:self.components toDate:self.finalEndDate options:0];
    }
}

-(void) intialFinalEndDateWithSteps:(NSMutableArray *)steps
{
    self.finalEndDate = [NSDate date];
    NSDictionary *dic;
    int i;
    for (i = 0; i < [steps count]; i++) {
        dic = [steps objectAtIndex:i];
        [self.components setHour: [[dic valueForKey:@"hourTime"] intValue]];
        [self.components setMinute:[[dic valueForKey:@"minTime"] intValue]];
        [self.components setSecond:[[dic valueForKey:@"secondTime"] intValue]];
        self.finalEndDate = [self.calendar dateByAddingComponents:self.components toDate:self.finalEndDate options:0];
    }
}


- (void)startTimer
{
    if (self.stopWatchTimer) {
        [self.stopWatchTimer invalidate];
        self.stopWatchTimer = nil;
    }
    
    [self.delegate addActive:self];
    [self intialFinalEndDateWithSteps:self.allStepsCheck];
    [self updateEndDateWithDic:self.allStepsCheck[0]];
    
    self.stepLabel.textColor =[UIColor blackColor];
    self.timeLabel.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor whiteColor];
    
        // alert settings
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    [self createNotification];
    
    self.stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(updateTimer)
                                                         userInfo:nil
                                                        repeats:YES];
    [self.stopWatchTimer fire];
}


- (void)pauseTimer
{
    [self.stopWatchTimer invalidate];
    self.stopWatchTimer = nil;
    [self cancelNotification:self.uniqueID];
}


- (void)resumeTimer:(double)remainder
{
    double roundReminder = ceil(remainder);
    NSDateComponents *components= [[NSDateComponents alloc] init];
    [components setSecond:roundReminder];
    self.endDate = [self.calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
    [self updateFinalEndDate:remainder withSteps:self.allStepsCheck];
    [self createNotification];
    
    self.stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(updateTimer)
                                                         userInfo:nil
                                                          repeats:YES];
    [self.stopWatchTimer fire];
}


-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if(editing){
        self.stopButton.hidden = YES;
        self.playButton.hidden = YES;
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.stepLabel.textAlignment = NSTextAlignmentLeft;
        self.stepLabelConstraint.constant = 15.0;

    }else{
        self.stopButton.hidden = NO;
        self.playButton.hidden = NO;
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.stepLabel.textAlignment = NSTextAlignmentRight;
        self.stepLabelConstraint.constant = 155.0;

    }
}

-(void)createNotification {
    //unique ID
    self.uniqueID = [[NSUUID UUID] UUIDString];
    
    //generates alert
    UILocalNotification *timerAlert = [[ UILocalNotification alloc] init];
    timerAlert.alertBody = @"Series Timer Ended";
    timerAlert.fireDate = self.finalEndDate;
    timerAlert.soundName = UILocalNotificationDefaultSoundName;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.uniqueID forKey:@"ID"];
    timerAlert.userInfo = userInfo;
    [[UIApplication sharedApplication] scheduleLocalNotification:timerAlert];
}

-(void) cancelNotification: (NSString *)id
{
    NSString *notificationId = id;
    UILocalNotification *notification = nil;
    for(UILocalNotification *notify in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {
        if([[notify.userInfo objectForKey:@"ID"] isEqualToString:notificationId])
        {
            notification = notify;
            break;
        }
    }
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
    self.uniqueID = nil;
}

@end
