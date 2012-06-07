/*****************************************************************************
 *  Copyright (c) 2011 Meta Watch Ltd.                                       *
 *  www.MetaWatch.org                                                        *
 *                                                                           *
 =============================================================================
 *                                                                           *
 *  Licensed under the Apache License, Version 2.0 (the "License");          *
 *  you may not use this file except in compliance with the License.         *
 *  You may obtain a copy of the License at                                  *
 *                                                                           *
 *    http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                           *
 *  Unless required by applicable law or agreed to in writing, software      *
 *  distributed under the License is distributed on an "AS IS" BASIS,        *
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 *  See the License for the specific language governing permissions and      *
 *  limitations under the License.                                           *
 *                                                                           *
 *****************************************************************************/

//
//  WidgetsSelectionViewController.m
//  MWM
//
//  Created by Siqi Hao on 5/24/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "WidgetsSelectionViewController.h"
#import "AppDelegate.h"

@interface WidgetsSelectionViewController ()

@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) IBOutlet UISegmentedControl *rowSegCtrl;

- (IBAction) rowSegCtrlValueChanged:(id)sender;

@end

@implementation WidgetsSelectionViewController

@synthesize mainTableView, appDelegate, rowSegCtrl, delegate;

- (IBAction) rowSegCtrlValueChanged:(id)sender {
    [mainTableView reloadData];
}

- (IBAction) doneBtnPressed:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return appDelegate.allWidgets.count;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Select widgets for row %d", (rowSegCtrl.selectedSegmentIndex + 2)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
    
    // Configure the cell...
    NSUserDefaults *perfs = [NSUserDefaults standardUserDefaults];
    NSDictionary *layoutDict = [perfs valueForKey:@"watchLayout"];
    //NSLog(@"%@", [layoutDict description]);
    
    NSString *widgetClassName = [appDelegate.allWidgets objectAtIndex:indexPath.row];
    
    NSString *inRowWidgetName = [layoutDict objectForKey:[NSString stringWithFormat:@"%d3",rowSegCtrl.selectedSegmentIndex + 1]];
    if ([inRowWidgetName isEqualToString:widgetClassName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        //cell.detailTextLabel.text  = [NSString stringWithFormat:@"Displayed on row:%d", rowSegCtrl.selectedSegmentIndex + 1];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        //cell.detailTextLabel.text  = @"";
    }
    
    cell.textLabel.text = widgetClassName;
    
    return cell; 
}


#pragma mark - UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Not Available" message:@"This widget cannot be configured into the current row." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    } else {
        NSUserDefaults *perfs = [NSUserDefaults standardUserDefaults];
        NSDictionary *layoutDict = [[perfs objectForKey:@"watchLayout"] mutableCopy];
        NSString *widgetClassName = [appDelegate.allWidgets objectAtIndex:indexPath.row];
        [layoutDict setValue:widgetClassName forKeyPath:[NSString stringWithFormat:@"%d3", rowSegCtrl.selectedSegmentIndex+1]];
        [perfs setObject:layoutDict forKey:@"watchLayout"];
        [perfs synchronize];
        
        [tableView reloadData];
        [delegate widget:widgetClassName configuredAtRow:rowSegCtrl.selectedSegmentIndex+1];
    }
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Widgets Layouts";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = [[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
