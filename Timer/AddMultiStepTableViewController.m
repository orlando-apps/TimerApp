#import "AddMultiStepTableViewController.h"
#import "EditButton.h"
#import "Chameleon.h"


#define BackgroundColorOne      flatGrayDarkColor
#define BackgroundColorTwo      flatSkyBlueColor

@interface AddMultiStepTableViewController ()

@end

@implementation AddMultiStepTableViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setHidesNavigationBarHairline:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:YES];
        self.tableView.backgroundColor = [UIColor clearColor];
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    UIView *backgroundView = [[UIView alloc]initWithFrame:screenRect];
//    [backgroundView setBackgroundColor:[UIColor colorWithGradientStyle:UIGradientStyleTopToBottom
//                                                             withFrame:self.tableView.bounds andColors:
//                                        @[[UIColor BackgroundColorOne],[UIColor BackgroundColorTwo]]]];
    
//    [self.tableView setBackgroundView:backgroundView];
    
    [self.tableView setSeparatorColor:[UIColor whiteColor]];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.allSteps == nil){
    self.allSteps = [[NSMutableArray alloc] init];
    }
    
    if (self.allSteps.count == 0){
        self.tableHeader.hidden = YES;
    }
    
    if (!self.newRecord){
        self.allSteps = [self.editRecord valueForKey:@"timeCollection"];
        self.tableHeader.hidden = NO;
        self.navigationItem.title = @"Edit Timer";
    } else {
        self.navigationItem.title = @"New Timer";
    }
    
    self.sections = @[@"title", @"steps", @"sounds"];
    NSArray * title = @[@"title"];
    NSArray *sound = @[@"sound"];
    self.rows = [NSMutableArray arrayWithObjects: title, self.allSteps, sound, nil];
    
    //hide keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:nil];
    
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (([touch.view isKindOfClass:[UITextField class]])) {
        return NO;
    }
    [self dismissKeyboard];
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{

}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rows[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if(indexPath.section == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"titleCell"];
        }
        
        self.titleField = (UITextField *)[cell viewWithTag:100];
        
        if (!self.newRecord){
            self.titleField.text = [self.editRecord valueForKey:@"timerName"];
        }
        cell.backgroundColor = [UIColor clearColor];
    }
    
    if(indexPath.section == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"normalCell"];

        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"normalCell"];
        }
        cell.backgroundColor = [UIColor clearColor];
        UILabel *soundTitle = (UILabel *)[cell viewWithTag:100];
        [soundTitle setText:@"Sound"];
        soundTitle.textColor = [UIColor flatWhiteColor];
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(tableView.bounds));

    }
    
    if(indexPath.section == 1){
    cell = [tableView dequeueReusableCellWithIdentifier:@"stepCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stepCell"];
        }

    NSDictionary* currentStep = [self.allSteps objectAtIndex:indexPath.row];
    
    UILabel *stepTitle = (UILabel *)[cell viewWithTag:100];
    [stepTitle setText:[currentStep valueForKey:@"title"]];
    UILabel *stepTime = (UILabel *)[cell viewWithTag:200];
    [stepTime setText:[currentStep valueForKey:@"timeString"]];
    
    UIView *editingCategoryAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 80)];
    //    [[editingCategoryAccessoryView layer] setBorderWidth:2.0f];
    //    [[editingCategoryAccessoryView layer] setBorderColor:[UIColor blackColor].CGColor];
    EditButton *button = [EditButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(0, 0, 45, 80)];
    //    [[button layer] setBorderWidth:2.0f];
    [[button layer] setBorderColor:[UIColor greenColor].CGColor];
    [button addTarget:self action:@selector(editClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UITableViewCell *disclosure = [[UITableViewCell alloc] init];
    disclosure.frame = button.bounds;
    disclosure.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    disclosure.userInteractionEnabled = NO;
    [button addSubview:disclosure];
    [editingCategoryAccessoryView addSubview:button];
    cell.editingAccessoryView = editingCategoryAccessoryView;

    cell.backgroundColor = [UIColor clearColor];
    };

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if(indexPath.section == 0 || indexPath.section == 2){
        return 45;
    }
    
    return 77;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1){
        UIView *footerView = [[[NSBundle mainBundle] loadNibNamed:@"CustomHeaderFooter" owner:self options:nil]
                              firstObject];
        UIButton *editButton = (UIButton *)[footerView viewWithTag:100];
        [editButton setTitle:@"Add another step" forState:UIControlStateNormal];
        [editButton setTitleColor:[UIColor flatWhiteColor] forState:UIControlStateNormal];
        editButton.backgroundColor = [UIColor flatGrayColor];
        [editButton addTarget:self action:@selector(addAnotherStep:) forControlEvents:UIControlEventTouchUpInside];
        
        return footerView;
    }
    return [[UIView alloc] initWithFrame:CGRectZero];

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1){
        UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"CustomHeaderFooter" owner:self options:nil]
                        firstObject];
        self.editButton = (UIButton *)[headerView viewWithTag:100];
        [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
        [self.editButton setTitleColor:[UIColor flatWhiteColor] forState:UIControlStateNormal];
        self.editButton.backgroundColor = [UIColor flatWatermelonColor];
        [self.editButton addTarget:self action:@selector(goEditingMode:) forControlEvents:UIControlEventTouchUpInside];
        
        return headerView;
    }
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)addAnotherStep:(UIButton*)sender{
    [self performSegueWithIdentifier:@"addStep" sender:self];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1){
        return 40.0;
    }
    
    if (section == 0){
        return 1.0;
    }
    return 40.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1){
        return 40.0;
    }
    return 40.0;
}

-(void)editClicked:(EditButton *)sender
{
    NSLog(@"where is it %@", sender.editIndexPath);
    self.editIndexPath = sender.editIndexPath;
    [self performSegueWithIdentifier:@"editStep" sender:self] ;
}

-(void) tableView:(UITableView *) tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{

    if(editingStyle == UITableViewCellEditingStyleDelete){
        if(self.allSteps.count == 1){
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Delete Timer"
                                         message:@"Do you want to delete this Timer?"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                         actionWithTitle:@"Yes"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             if(!self.newRecord){
                                                 [self.managedObjectContext deleteObject:self.editRecord];
                                                }
                                             NSError *error = nil;
                                             if ([self.managedObjectContext save:&error]) {
                                                 [self CancelButton:nil];
                                             } else {
                                                 if (error) {
                                                     NSLog(@"Unable to delete record.");
                                                     NSLog(@"%@, %@", error, error.localizedDescription);
                                                 }
 //                                                [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your timer could not be deleted." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                             }
                                         }];
            
            UIAlertAction* noButton = [UIAlertAction
                                       actionWithTitle:@"No"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                            [self goEditingMode:self.editButton];
                                       }];
            
            [alert addAction:yesButton];
            [alert addAction:noButton];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
        [self.allSteps removeObjectAtIndex: indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detemine if it's in editing mode
    if (self.tableView.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

-(void) tableView:(UITableView *) tableView moveRowAtIndexPath:(nonnull NSIndexPath *)sourceIndexPath toIndexPath:(nonnull NSIndexPath *)destinationIndexPath
{
    NSDictionary * moveDic = self.allSteps[sourceIndexPath.row];
    [self.allSteps removeObjectAtIndex:sourceIndexPath.row];
    [self.allSteps insertObject:moveDic atIndex:destinationIndexPath.row];
}

- (void)receivedNewData:(NSArray *)stepTime title:(NSString *)stepTitle
{
    if (self.allSteps == nil){
        self.allSteps = [[NSMutableArray alloc] init];
    }
    
    NSString * stepTimeString = [NSString stringWithFormat:@"%02d:%02d:%02d", [[stepTime objectAtIndex:0]intValue],
                                                                              [[stepTime objectAtIndex:1]intValue],
                                                                              [[stepTime objectAtIndex:2]intValue]];
    
    NSDictionary *stepData = @{
                                 @"hourTime" : [stepTime objectAtIndex:0],
                                 @"minTime" : [stepTime objectAtIndex:1],
                                 @"secondTime" : [stepTime objectAtIndex:2],
                                 @"timeString" :stepTimeString,
                                 @"title" : [NSString stringWithFormat:@"%@", stepTitle],
                              };
   
   [self.allSteps addObject:stepData];
   [self.tableView reloadData];

    if (self.allSteps.count > 0){
        self.tableHeader.hidden = NO;
    }
}

- (void)receivedEditData:(NSArray *)stepTime title:(NSString *)stepTitle position:(NSInteger) position;
{
    
    NSString * stepTimeString = [NSString stringWithFormat:@"%02d:%02d:%02d",
                                 [[stepTime objectAtIndex:0]intValue],
                                 [[stepTime objectAtIndex:1]intValue],
                                 [[stepTime objectAtIndex:2]intValue]];
    
    
    NSDictionary *stepData = @{
                               @"hourTime" : [stepTime objectAtIndex:0],
                               @"minTime" : [stepTime objectAtIndex:1],
                               @"secondTime" : [stepTime objectAtIndex:2],
                               @"timeString" :stepTimeString,
                               @"title" : [NSString stringWithFormat:@"%@", stepTitle],
                               };

    [self.allSteps removeObjectAtIndex:position];
    [self.allSteps insertObject:stepData atIndex:position];
    [self.tableView reloadData];
    
    if (self.allSteps.count > 0){
        self.tableHeader.hidden = NO;
    }
}

-(void)dismissKeyboard {
    [self.titleField resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"addStep"]) {
      
        AddStepTableViewController *vc = (AddStepTableViewController *)[segue destinationViewController];
        vc.delegate = self;
        vc.isExisting = NO;
        vc.isAddStep = YES;
        NSInteger stepNumber = self.allSteps.count +1;
        vc.existingTitle = [NSString stringWithFormat:@"step %ld", (long)stepNumber];
      
  } else if ([segue.identifier isEqualToString:@"editStep"]) {
      
        AddStepTableViewController *vc = (AddStepTableViewController *)[segue destinationViewController];
        vc.delegate = self;
        vc.existingPosition = self.editIndexPath.row;
        vc.isExisting = YES;
        vc.isAddStep = NO;
      
      NSDictionary* currentStep = [self.allSteps objectAtIndex:self.editIndexPath.row];
        vc.existingTitle =[currentStep valueForKey:@"title"];
        vc.existingComponents =[NSArray arrayWithObjects: [currentStep valueForKey:@"hourTime"],[currentStep valueForKey:@"minTime"],[currentStep valueForKey:@"secondTime"], nil];
    }
    self.editIndexPath = nil;
}

- (void)goEditingMode:(UIButton *)sender {
    if(self.isEditing){
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        [self setEditing:NO animated:YES];
    } else{
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        [self setEditing:YES animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];

    if (section ==1){
        return YES;
    };

    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld", indexPath.row); // you can see selected row number in your console;
}


- (IBAction)CancelButton:(id)sender {
    if (self.newRecord){
        NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
        [controllers removeLastObject];
        [self.navigationController setViewControllers:controllers animated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)SaveButton:(id)sender {

    if (self.allSteps) {

        if (self.newRecord) {
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Times" inManagedObjectContext:self.managedObjectContext];
            NSManagedObject *record = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
             double newID = self.firstOrderValue - 1.0;
            [record setValue: @(newID) forKey:@"orderingValue"];
            [record setValue:self.allSteps forKey:@"TimeCollection"];
            
            if(self.titleField.text.length > 0){
            [record setValue:self.titleField.text forKey:@"timerName"];
            }
            
        }else{
            [self.editRecord setValue:self.allSteps forKey:@"TimeCollection"];
            
            if(self.titleField.text){
                [self.editRecord setValue:self.titleField.text forKey:@"timerName"];
            }
        }
    
        // Save Record
        NSError *error = nil;
        if ([self.managedObjectContext save:&error]) {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            if (error) {
                NSLog(@"Unable to save record.");
                NSLog(@"%@, %@", error, error.localizedDescription);
            }
      //      [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your event could not be saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
    } else {
        // Show Alert View
       // [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your event needs a name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


@end
