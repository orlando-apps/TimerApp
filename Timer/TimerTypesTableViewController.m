#import "TimerTypesTableViewController.h"
#import "AddMultiStepTableViewController.h"
#import "AddStepTableViewController.h"
#import "Chameleon.h"

#define BackgroundColorOne      flatGrayDarkColor
#define BackgroundColorTwo      flatSkyBlueColor

@interface TimerTypesTableViewController ()

@end

@implementation TimerTypesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Create New Timer";
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        AddMultiStepTableViewController *multiStepView =[self.storyboard instantiateViewControllerWithIdentifier:@"multiStepView"];
        
        [multiStepView setManagedObjectContext:self.managedObjectContext];
        multiStepView.newRecord = YES;
        multiStepView.firstOrderValue = self.firstOrderValue;
        
        AddStepTableViewController *addStepView =[self.storyboard instantiateViewControllerWithIdentifier:@"addStepView"];
        addStepView.existingTitle = @"step 1";
        addStepView.isExisting = NO;
        addStepView.delegate = multiStepView;
        
        NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
        [controllers addObject:multiStepView];
        [controllers addObject:addStepView];
        [self.navigationController setViewControllers:controllers animated:YES];
    }
}

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView
                       cellForRowAtIndexPath:indexPath];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

@end
