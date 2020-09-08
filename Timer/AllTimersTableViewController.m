#import "AllTimersTableViewController.h"
#import "TimerTypesTableViewController.h"
#import "AllTimersTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "EditButton.h"
#import "AddMultiStepTableViewController.h"
#import "SettingsTableViewController.h"
#import "Chameleon.h"

#define BackgroundColorOne      flatGrayDarkColor
#define BackgroundColorTwo      flatSkyBlueColor

@interface AllTimersTableViewController () <NSFetchedResultsControllerDelegate, CellDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation AllTimersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setHidesNavigationBarHairline:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:YES];
   
    self.tableView.backgroundColor = [UIColor clearColor];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIView *backgroundView = [[UIView alloc]initWithFrame:screenRect];
    [self.navigationController.view insertSubview:backgroundView atIndex:0];
    [backgroundView setBackgroundColor:[UIColor colorWithGradientStyle:UIGradientStyleTopToBottom
                                                      withFrame:self.tableView.bounds andColors:
                         @[[UIColor BackgroundColorOne],[UIColor BackgroundColorTwo]]]];

    //add separator to top cell
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1 / UIScreen.mainScreen.scale)];
    headerView.backgroundColor = self.tableView.separatorColor;
    self.tableView.tableHeaderView = headerView;
    
    [self.tableView setSeparatorColor:[UIColor whiteColor]];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.title = @"All Timers";
    self.userDrivenDataModelChange =NO;
    self.activeArray = [[NSMutableArray alloc] init];
    self.activeTimers = NO;
    self.tableView.allowsSelection = NO;

    UINib *nib = [UINib nibWithNibName:@"AllTimersTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"AllTimersTableViewCell"];

    [self fetch];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

//separator extend
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.activeTimers && ![self.activeArray containsObject:indexPath]){
        return 0;
    }
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];

    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    AllTimersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AllTimersTableViewCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
           [cell setTintColor:[UIColor whiteColor]];
    return cell;
}

- (void)configureCell:(AllTimersTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.allSteps = [record valueForKey:@"timeCollection"];
    cell.timeLabel.text = [[cell.allSteps objectAtIndex:0] valueForKey:@"timeString"];
    cell.timeLabel.textColor = [UIColor whiteColor];
    //cell.stepLabel.text =[[cell.allSteps objectAtIndex:0] valueForKey:@"title"];

    if ([[record valueForKey:@"timerName"] length] > 0){
        NSLog(@"here");
        cell.stepLabel.text =[record valueForKey:@"timerName"];
        cell.timerName = [record valueForKey:@"timerName"];
    }else{
        cell.stepLabel.text = @"Series Timer";
        cell.timerName = @"Series Timer";
    }
   
    cell.stepLabel.textColor = [UIColor whiteColor];
    
    cell.delegate = self;
    
    UIView *editingCategoryAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 80)];
    //    [[editingCategoryAccessoryView layer] setBorderWidth:2.0f];
    //    [[editingCategoryAccessoryView layer] setBorderColor:[UIColor blackColor].CGColor];
    EditButton *button = [EditButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(0, 0, 45, 80)];
    //    [[button layer] setBorderWidth:2.0f];
    [[button layer] setBorderColor:[UIColor greenColor].CGColor];
    button.record = record;
    [button addTarget:self action:@selector(editClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UITableViewCell *disclosure = [[UITableViewCell alloc] init];
    disclosure.frame = button.bounds;
    disclosure.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    disclosure.userInteractionEnabled = NO;
    [button addSubview:disclosure];
    [editingCategoryAccessoryView addSubview:button];
    cell.editingAccessoryView = editingCategoryAccessoryView;
}

-(void)editClicked:(EditButton *)sender
{
    self.editRecord = sender.record;
    [self performSegueWithIdentifier:@"EditMultiSteps" sender:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Fetched Results Controller Delegate Methods
-(void)fetch{
 
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Times"];
    
    // Add Sort Descriptors
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES]]];
    
    // Initialize Fetched Results Controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    // Configure Fetched Results Controller
    [self.fetchedResultsController setDelegate:self];
    
    // Perform Fetch
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);}
    
    if (([[self.fetchedResultsController fetchedObjects] count] == 0)){
        self.editButton.enabled =NO;
    }
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
     if (self.userDrivenDataModelChange) return;
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
     if (self.userDrivenDataModelChange) return;
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (self.userDrivenDataModelChange) return;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            self.editButton.enabled =YES;
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(AllTimersTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

#pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"TimerTypes"]) {
        
        if(self.isEditing){
            self.addButton.title = @"Edit";
            [self setEditing:NO animated:YES];
        };
        
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        TimerTypesTableViewController *vc = (TimerTypesTableViewController *)[nc topViewController];
        [vc setManagedObjectContext:self.managedObjectContext];

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Times"];
        fetchRequest.fetchLimit = 1;
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES]];
        NSError *error = nil;
        
        vc.firstOrderValue = [[[self.managedObjectContext executeFetchRequest:fetchRequest error:&error].firstObject valueForKey:@"orderingValue"] doubleValue];

    }else if ([segue.identifier isEqualToString:@"EditMultiSteps"]) {
        UINavigationController *nc= (UINavigationController*)[segue destinationViewController];
        AddMultiStepTableViewController *vc = (AddMultiStepTableViewController *)[nc topViewController];
        [vc setManagedObjectContext:self.managedObjectContext];
        vc.newRecord = NO;
        vc.editRecord = self.editRecord;
        
    }else if([segue.identifier isEqualToString:@"settings"]) {
//        UINavigationController *nc= (UINavigationController*)[segue destinationViewController];
//         SettingsTableViewController *vc = (SettingsTableViewController *)[nc topViewController];
    }

    self.editRecord= nil;
}

#pragma mark cell delegate methods
- (void)addActive:(AllTimersTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.activeArray addObject:indexPath];
}

- (void)subtractDeactive:(AllTimersTableViewCell*)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.activeArray removeObject:indexPath];
}

#pragma mark buttons
- (IBAction)editToggled:(UIBarButtonItem *)sender {
    if (!([[self.fetchedResultsController fetchedObjects] count] == 0)){
        if(self.isEditing){
            [sender setTintColor:[UIColor whiteColor]];
            sender.title = @"Edit";
            [self setEditing:NO animated:YES];
        } else{
            [sender setTintColor:[UIColor flatRedDarkColor]];
            sender.title = @"Done";
            [self setEditing:YES animated:YES];
        }
    }else{
        self.editButton.enabled =NO;
    }
}

- (IBAction)allButton:(id)sender {
    self.navigationItem.title = @"All Timers";
    self.activeTimers = NO;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    if (([[self.fetchedResultsController fetchedObjects] count] == 0)){
        self.editButton.enabled =NO;
    }else {
        self.editButton.enabled =YES;
    }
}

- (IBAction)activeButton:(id)sender {
   self.navigationItem.title = @"Active Timers";
    self.activeTimers = YES;
    
    if ([[self.fetchedResultsController fetchedObjects] count] > 0){
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }

        self.editButton.enabled =NO;
}

-(void) tableView:(UITableView *) tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if ([[self.fetchedResultsController fetchedObjects] count] == 1){
            [self editToggled:self.editButton];
        };
        
        NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:managedObject];
        [self.managedObjectContext save:nil];
    }
    if (([[self.fetchedResultsController fetchedObjects] count] == 0)){
        self.editButton.enabled =NO;
    }
}

 - (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
     return UITableViewCellEditingStyleDelete;
 }

-(void) tableView:(UITableView *) tableView moveRowAtIndexPath:(nonnull NSIndexPath *)sourceIndexPath toIndexPath:(nonnull NSIndexPath *)destinationIndexPath
{
    self.userDrivenDataModelChange = YES;
    
    if(sourceIndexPath == destinationIndexPath){
        return;
    }
 
    NSMutableArray *fetchedTimers = [[self.fetchedResultsController fetchedObjects] mutableCopy];

    double lowerBound = 0.0;
    if (destinationIndexPath.row > 0){
        lowerBound = [[[fetchedTimers objectAtIndex:(destinationIndexPath.row -1)] valueForKey:@"orderingValue"] doubleValue];
    }else{
        lowerBound = [[[fetchedTimers objectAtIndex:1] valueForKey:@"orderingValue"] doubleValue] - 2.0;
    }
    
    double upperBound = 0.0;
    if (destinationIndexPath.row < [fetchedTimers count] - 1){
        upperBound = [[[fetchedTimers objectAtIndex:(destinationIndexPath.row +1)] valueForKey:@"orderingValue"] doubleValue];
    }else{
        upperBound = [[[fetchedTimers objectAtIndex:(destinationIndexPath.row -1)] valueForKey:@"orderingValue"] doubleValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    NSLog(@"moving to order %f", newOrderValue);
    
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:sourceIndexPath];
    [record setValue: @(newOrderValue) forKey:@"orderingValue"];
    [self.managedObjectContext save:nil];
    
    self.userDrivenDataModelChange = NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end
