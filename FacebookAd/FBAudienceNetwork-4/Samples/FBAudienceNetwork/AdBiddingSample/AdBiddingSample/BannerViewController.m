// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "BannerViewController.h"

#import "SettingsBidPriceCell.h"

@interface BannerViewController ()

@property (nonatomic, weak) IBOutlet UILabel *adStatusLabel;
@property (nonatomic, strong) FBAdView *adView;
@property (nonatomic, copy) NSString *bidPayLoad;
@property (nonatomic, assign) CGFloat bidPrice;
@end

@implementation BannerViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self loadAd];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  FBAdSize adSize = [self fbAdSize];
  CGSize viewSize = self.view.bounds.size;
  CGSize tabBarSize = self.tabBarController.tabBar.frame.size;
  viewSize = CGSizeMake(viewSize.width, viewSize.height - tabBarSize.height);
  UIEdgeInsets insets = [self safeAreaInsets];
  CGFloat bottomAlignedY = viewSize.height - adSize.size.height - insets.bottom;
  self.adView.frame = CGRectMake(insets.left,
                                 bottomAlignedY,
                                 viewSize.width - insets.right - insets.left,
                                 adSize.size.height);
}

- (void)loadAd
{
    self.adStatusLabel.text = @"Loading ad...";
    self.adView = nil;

    NSString *placementID = @"INSERT_PLACEMENT_ID";
    NSString *appID = @"INSERT_APP_ID";

    // Create a banner's ad view with a unique placement ID (generate your own on the Facebook app settings).
    // Use different ID for each ad placement in your app.
    FBAdSize adSize = [self fbAdSize];
    self.adView = [[FBAdView alloc] initWithPlacementID:placementID
                                               adSize:adSize
                                   rootViewController:self];

    // Set a delegate to get notified on changes or when the user interact with the ad.
    self.adView.delegate = self;

    // When testing on a device, add its hashed ID to force test ads.
    // The hash ID is printed to console when running on a device.
    // [FBAdSettings addTestDevice:@"THE HASHED ID AS PRINTED TO CONSOLE"];

    // Set autoresizingMask so the rotation is automatically handled
    self.adView.autoresizingMask =
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleLeftMargin|
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleTopMargin;

    // Add adView to the view hierarchy.
    [self.view addSubview:self.adView];

    [FBAdBidRequest getAudienceNetworkBidForAppID:appID
                                    placementID:placementID
                                       adFormat:FBAdBidFormatBanner_HEIGHT_50
                               responseCallback:^(FBAdBidResponse *bidResponse) {
        if ([bidResponse isSuccess]) {
            self.bidPayLoad = [bidResponse getPayload];
            self.bidPrice = [bidResponse getPrice];
            CGFloat minPrice = [[NSUserDefaults standardUserDefaults] floatForKey:FB_AD_BID_PRICE];
            if (self.bidPrice < minPrice) {
                self.adStatusLabel.text = [NSString stringWithFormat:@"Ad bid failed with bid price: %.2f below minimum price: %.2f", self.bidPrice, minPrice];
                // Call notifyLoss when the bid from Audience Network loses the impression opportunity.
                [bidResponse notifyLoss];
                return;
            }
            // Call notifyWin when the bid from Audience Network wins the impression opportunity.
            [bidResponse notifyWin];

            [self.adView loadAdWithBidPayload:self.bidPayLoad];
        } else {
            self.adStatusLabel.text = [bidResponse getErrorMessage];
        }
    }];

}

- (UIEdgeInsets)safeAreaInsets
{
    // Comment the following if-statement if you are not running XCode 9+
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        return [window safeAreaInsets];
    }
    return UIEdgeInsetsZero;
}

- (IBAction)refreshAd:(id)sender {
  self.adView.hidden = YES;
  [self loadAd];
}

- (FBAdSize)fbAdSize
{
  BOOL isIPAD = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
  return isIPAD ? kFBAdSizeHeight90Banner : kFBAdSizeHeight50Banner;
}

#pragma mark - FBAdViewDelegate implementation

// Implement this function if you want to change the viewController after the FBAdView
// is created. The viewController will be used to present the modal view (such as the
// in-app browser that can appear when an ad is clicked).
// - (UIViewController *)viewControllerForPresentingModalView
// {
//   return self;
// }

- (void)adViewDidClick:(FBAdView *)adView
{
  NSLog(@"Ad was clicked.");
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView
{
  NSLog(@"Ad did finish click handling.");
}

- (void)adViewDidLoad:(FBAdView *)adView
{
  self.adStatusLabel.text = [NSString stringWithFormat:@"Ad loaded with bid price: %f", self.bidPrice];
  NSLog(@"Ad was loaded.");
  // Now that the ad was loaded, show the view in case it was hidden before.
  self.adView.hidden = NO;
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error
{
  self.adStatusLabel.text = [NSString stringWithFormat:@"Ad failed to load. %@", error.localizedDescription];
  NSLog(@"Ad failed to load with error: %@", error);

  // Hide the unit since no ad is shown.
  self.adView.hidden = YES;
}

- (void)adViewWillLogImpression:(FBAdView *)adView
{
  NSLog(@"Ad impression is being captured.");
}

@end
