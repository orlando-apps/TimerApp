#import "AddStepTableViewController.h"
#import "CustomUIDatePicker.h"
#import "Chameleon.h"

#define BackgroundColorOne      flatGrayDarkColor
#define BackgroundColorTwo      flatSkyBlueColor

@interface AddStepTableViewController ()

@property (strong, nonatomic) CustomUIDatePicker *timePicker;

@end

@implementation AddStepTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIView *backgroundView = [[UIView alloc]initWithFrame:screenRect];
    
    [backgroundView setBackgroundColor:[UIColor colorWithGradientStyle:UIGradientStyleTopToBottom
                                                             withFrame:self.tableView.bounds andColors:
                                        @[[UIColor BackgroundColorOne],[UIColor BackgroundColorTwo]]]];
    
    [self.tableView setBackgroundView:backgroundView];
    [self.tableView setSeparatorColor:[UIColor whiteColor]];
    
    //add separator to top cell
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1 / UIScreen.mainScreen.scale)];
    headerView.backgroundColor = self.tableView.separatorColor;
    self.tableView.tableHeaderView = headerView;
    
    //hide extra cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //[self.stepName becomeFirstResponder];
    //hide keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    if (self.existingTitle){
        self.stepName.text = self.existingTitle;
    }
    
    if (self.isExisting){

        self.navigationItem.title = @"Edit Step";
    }else{
        self.navigationItem.title = @"New Step";
    }
}

-(void)dismissKeyboard {
    [self.view endEditing:true];
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
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView
                       cellForRowAtIndexPath:indexPath];

        if (indexPath.section == 1){
        
            CGRect parentRect = [self.dateViewContainer frame];
            self.timePicker =[[CustomUIDatePicker alloc] initWithFrame:CGRectMake(0, 0, parentRect.size.width, parentRect.size.height)];
            self.timePicker.backgroundColor = [UIColor clearColor];
            self.dateViewContainer.backgroundColor = [UIColor clearColor];
            [self.dateViewContainer addSubview:self.timePicker];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.timePicker.center = CGPointMake(CGRectGetMidX(self.dateViewContainer.bounds), self.timePicker.center.y);
            });
            
            if (self.existingComponents){
                [self.timePicker selectRow:[self.existingComponents[0] longValue] inComponent:0 animated:YES];
                [self.timePicker selectRow:[self.existingComponents[1] longValue] inComponent:1 animated:YES];
                [self.timePicker selectRow:[self.existingComponents[2] longValue] inComponent:2 animated:YES];
            }
        }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    // rows in section 0 should not be selectable
    if ( indexPath.section == 0 || indexPath.section == 1 ) return NO;
    return YES;
}

- (IBAction)clickDone:(id)sender {
    if ([self.timePicker selectedRowInComponent:0] == 0 && [self.timePicker selectedRowInComponent:1] == 0 && [self.timePicker selectedRowInComponent:2] == 0 ){
    
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Timer"
                                         message:@"Time has not been set"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            
            
            UIAlertAction* okayButton = [UIAlertAction
                                        actionWithTitle:@"Okay"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                        }];
        
            [alert addAction:okayButton];

            [self presentViewController:alert animated:YES completion:nil];
    
    }else {
    
            NSArray *timeArray = [NSArray arrayWithObjects:
                                 [NSNumber numberWithInteger:[self.timePicker selectedRowInComponent:0]]
                                ,[NSNumber numberWithInteger:[self.timePicker selectedRowInComponent:1]]
                                ,[NSNumber numberWithInteger:[self.timePicker selectedRowInComponent:2]]
                                , nil];
           
            NSString *stepName;
            if (self.stepName.text.length > 0)
            {
                stepName = self.stepName.text;
            }
            
            else
            {
                 stepName = @"Untitled";
            }
            
            if(!self.isExisting){
                [self.delegate receivedNewData:timeArray title:stepName];
            }else{
                [self.delegate receivedEditData:timeArray title:stepName position:self.existingPosition];
            }
            
            NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
            [controllers removeLastObject];
            [self.navigationController setViewControllers:controllers animated:YES];
    }
}

- (IBAction)cancelButton:(id)sender {
    NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
    [controllers removeLastObject];
    if (!self.isExisting && !self.isAddStep){
        [controllers removeLastObject];
    }
    [self.navigationController setViewControllers:controllers animated:YES];
}


@end
