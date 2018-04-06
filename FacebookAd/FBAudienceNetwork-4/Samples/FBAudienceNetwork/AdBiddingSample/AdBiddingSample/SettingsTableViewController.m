#import "SettingsTableViewController.h"

#import <FBAudienceNetwork/FBAudienceNetwork.h>

#import "SettingsTestModeCell.h"

@implementation SettingsTableViewController

#pragma mark - Private

- (NSString *)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    NSArray *reuseIdentifiers = @[@"SettingsSandboxCell",
                                  @"SettingsLogLevelCell",
                                  @"SettingsTestModeCell",
                                  @"SettingsBidPriceCell"];

    return reuseIdentifiers[indexPath.row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = [self reuseIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId
                                                            forIndexPath:indexPath];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"SDK Version %@", FB_AD_SDK_VERSION];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

@end
