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

#import "InstreamViewController.h"

#import "SettingsBidPriceCell.h"

@interface InstreamViewController ()

@property (weak, nonatomic) IBOutlet UILabel *adStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *mediaView;

@property (nonatomic, strong) FBInstreamAdView *adView;
@property (nonatomic, copy) NSString *bidPayLoad;
@property (nonatomic, assign) CGFloat bidPrice;

@end

@implementation InstreamViewController

- (IBAction)loadAd
{
    NSString *placementID = @"INSERT_PLACEMENT_ID";
    NSString *appID = @"INSERT_APP_ID";

    // Create an instream ad view with a unique placement ID (generate your own on the Facebook app settings).
    // Use different ID for each ad placement in your app.
    [self.adView removeFromSuperview];
    self.adView = [[FBInstreamAdView alloc] initWithPlacementID:placementID];

    // Set a delegate to get notified on changes or when the user interacts with the ad.
    self.adView.delegate = self;

    // Initiate a request to load an ad.
    [FBAdBidRequest getAudienceNetworkBidForAppID:appID
                                    placementID:placementID
                                       adFormat:FBAdBidFormatInstreamVideo
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
    self.adStatusLabel.text = @"Loading instream ad...";
}

- (IBAction)showAd
{
    if (!self.adView || !self.adView.adValid) {
        // Ad not ready to present.
        self.adStatusLabel.text = @"Ad not loaded. Click load to request an ad.";
    } else {
        // Ad is ready, present it!
        self.adStatusLabel.text = nil;
        self.adView.frame = self.mediaView.bounds;
        self.adView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.mediaView addSubview:self.adView];
        [self.adView showAdFromRootViewController:self];
    }
}

#pragma mark - FBInstreamAdViewDelegate implementation

- (void)adViewDidLoad:(FBInstreamAdView *)adView
{
    self.adStatusLabel.text = [NSString stringWithFormat:@"Ad loaded with bid price: %f", self.bidPrice];
}

- (void)adViewDidEnd:(FBInstreamAdView *)adView
{
    self.adStatusLabel.text = @"Ad ended";
    [self.adView removeFromSuperview];
    self.adView = nil;
}

- (void)adView:(FBInstreamAdView *)adView didFailWithError:(NSError *)error
{
    self.adStatusLabel.text = [NSString stringWithFormat:@"Ad failed: %@", error.localizedDescription];
    [self.adView removeFromSuperview];
    self.adView = nil;
}

- (void)adViewDidClick:(FBInstreamAdView *)adView
{
    self.adStatusLabel.text = @"Ad clicked";
}

- (void)adViewWillLogImpression:(FBInstreamAdView *)adView
{
    self.adStatusLabel.text = @"Ad impression";
}

@end
