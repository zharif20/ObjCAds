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

#import "RewardedVideoViewController.h"

#import "SettingsBidPriceCell.h"
@interface RewardedVideoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *adStatusLabel;
@property (nonatomic, strong) FBRewardedVideoAd *rewardedVideoAd;
@property (nonatomic, copy) NSString *bidPayLoad;
@property (nonatomic, assign) CGFloat bidPrice;

@end

@implementation RewardedVideoViewController

- (IBAction)loadAd
{
    self.adStatusLabel.text = @"Loading rewarded video ad...";
    NSString *placementID = @"INSERT_PLACEMENT_ID";
    NSString *appID = @"INSERT_APP_ID";

    // Create the rewarded video unit with a placement ID (generate your own on the Facebook app settings).
    // Use different ID for each ad placement in your app.
    self.rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:placementID withUserID:@"user123"  withCurrency:@"gold"];
    // Set a delegate to get notified on changes or when the user interact with the ad.
    self.rewardedVideoAd.delegate = self;

    // Initiate the request to load the ad.
    [FBAdBidRequest getAudienceNetworkBidForAppID:appID
                                    placementID:placementID
                                       adFormat:FBAdBidFormatRewardedVideo
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

            [self.rewardedVideoAd loadAdWithBidPayload:self.bidPayLoad];
        } else {
            self.adStatusLabel.text = [bidResponse getErrorMessage];
        }
    }];
}

- (IBAction)showAd
{
  if (!self.rewardedVideoAd || !self.rewardedVideoAd.isAdValid)
  {
    // Ad not ready to present.
    self.adStatusLabel.text = @"Ad not loaded. Click load to request an ad.";
  } else {
    self.adStatusLabel.text = @"1. Tap 'Load Ad'\n2. Once ad loads, tap 'Show!' to see the ad";

    // Ad is ready, present it!
    [self.rewardedVideoAd showAdFromRootViewController:self animated:NO];
  }
}

#pragma mark - FBRewardedVideoAdDelegate implementation

- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd
{
  NSLog(@"Rewarded video ad was loaded. Can present now.");
  self.adStatusLabel.text = [NSString stringWithFormat:@"Ad loaded with bid price: %f. Click show to present!", self.bidPrice];
}

- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
  NSLog(@"Rewarded video failed to load with error: %@", error.description);
  self.adStatusLabel.text = [NSString stringWithFormat:@"Rewarded Video ad failed to load. %@", error.localizedDescription];
}

- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd
{
  NSLog(@"Rewarded video was clicked.");
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd
{
  NSLog(@"Rewarded video closed.");
}

- (void)rewardedVideoAdWillClose:(FBRewardedVideoAd *)rewardedVideoAd
{
  NSLog(@"Rewarded video will close.");
}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd
{
  NSLog(@"Rewarded video impression is being captured.");
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd
{
  NSLog(@"Rewarded video was completed successfully.");
}

- (void)rewardedVideoAdServerRewardDidSucceed:(FBRewardedVideoAd *)rewardedVideoAd
{
  NSLog(@"Rewarded video server side reward succeeded.");
  //optional, cleanup
  self.rewardedVideoAd = nil;
}

- (void)rewardedVideoAdServerRewardDidFail:(FBRewardedVideoAd *)rewardedVideoAd
{
  NSLog(@"Rewarded video server side reward failed.");
  //optional, cleanup
  self.rewardedVideoAd = nil;
}

@end
