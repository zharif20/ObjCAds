//
//  ObjectiveCAds.m
//  DemoAds
//
//  Created by Calvin on 5/4/18.
//  Copyright © 2018 gogame. All rights reserved.
//

#import "ObjectiveCAds.h"
#import <AdColonyAdapter/AdColonyAdapter.h>

@interface ObjectiveCAds()

@property (strong, nonatomic) UILayoutGuide* layoutGuide;
@property (strong, nonatomic) NSLayoutConstraint* bannerViewConstraint;
@property (strong, nonatomic) AdColonyInterstitial* adcolony;

@end

@implementation ObjectiveCAds


+(ObjectiveCAds*) sharedInstance {
    static ObjectiveCAds* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        NSLog(@"AdMob SDK version: %@",GADRequest.sdkVersion);
//        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didRotateDevice) name:UIDeviceOrientationDidChangeNotification object:nil];
    });
    return sharedInstance;
}


-(void) googleAdsInit{
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-7255639722534079~6359636553"];
}

-(GADAdSize) bannerAdSize {
    return (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) ? kGADAdSizeSmartBannerLandscape: kGADAdSizeSmartBannerPortrait;
}

-(void) didRotateDevice {
    NSLog(@"Device rotate");
    self.bannerView.adSize = [self bannerAdSize];
}

#pragma mark - Banner Ads
-(void) showBannerAds:(UIViewController*) uv withPosition: (BannerPosition) position {
    
    self.bannerPosition = position;
    [self loadBannerAds:uv];
}


-(void) loadBannerAds: (UIViewController*) uv {
    self.bannerView = [[GADBannerView alloc] initWithAdSize:[self bannerAdSize]];
    self.bannerView.translatesAutoresizingMaskIntoConstraints = false;
    [uv.view addSubview:self.bannerView];
    
    self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
    self.bannerView.rootViewController = uv;
    self.bannerView.delegate = self;
    
//    self.layoutGuide = [uv.view safeAreaLayoutGuide];
    
    self.layoutGuide = [uv.view layoutMarginsGuide];
    
    [self.bannerView.leftAnchor constraintEqualToAnchor:self.layoutGuide.leftAnchor].active = YES;
    [self.bannerView.rightAnchor constraintEqualToAnchor:self.layoutGuide.rightAnchor].active = YES;
    
    switch (self.bannerPosition) {
        case bottom:
            self.bannerViewConstraint = [self.bannerView.bottomAnchor constraintEqualToAnchor:self.layoutGuide.bottomAnchor];
            break;
        case top:
            self.bannerViewConstraint = [self.bannerView.topAnchor constraintEqualToAnchor:self.layoutGuide.topAnchor];
            break;
        default:
            break;
    }
    self.bannerViewConstraint.active = YES;
    
    GADRequest* request = [GADRequest request];
#ifdef DEBUG
    request.testDevices = @[ @"691d58725df6a1f088675cbdcd71f513"];
#endif
    [self.bannerView loadRequest:request];
}

#pragma mark - Interstitial Ads
-(void) showInterstitialAds: (UIViewController*) uv {
    if ([self isInterstitialReady]) {
        [self.interstitial presentFromRootViewController:uv];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Interstitial Ads" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [uv presentViewController:alert animated:true completion:nil];
    }
}

// Ad Colony optimization -  didfinishlaunchingwithoptions
-(void) adColonyOptimization {
    AdColonyAppOptions *op = [[AdColonyAppOptions alloc] init];
//    op.testMode = YES;
    
    [AdColony configureWithAppID:@"app1eb31ecdc5984287b2" zoneIDs:@[@"vz1c0371bac9a74c029c"] options:op completion:^(NSArray<AdColonyZone *> * _Nonnull zones) {
        NSLog(@"%@",zones);
        
    }];
}

-(void) loadInterstitialAds {
#ifdef DEBUG
    NSString* adUnitId = @"ca-app-pub-3940256099942544/4411468910";
#else
    NSString* adUnitId = @"ca-app-pub-7255639722534079/1462533095";
#endif
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:adUnitId];
    //ca-app-pub-7255639722534079/1462533095
    //ca-app-pub-3940256099942544/4411468910 - test 
    self.interstitial.delegate = self;
    
    GADMAdapterAdColonyExtras* extras = [[GADMAdapterAdColonyExtras alloc] init];
    extras.testMode = YES;
    extras.showPrePopup = YES;
    extras.showPostPopup = YES;

    GADRequest* request = [GADRequest request];
    [request registerAdNetworkExtras:extras];
#ifdef DEBUG
    request.testDevices = @[ @"691d58725df6a1f088675cbdcd71f513"];
#endif
    [self.interstitial loadRequest:request];
}

-(BOOL) isInterstitialReady {
    if (!self.interstitial.isReady) {
        NSLog(@"Reward Video Ads not ready. Reloading...");
        [self loadInterstitialAds];
        return false;
    }
    return true;
}


#pragma mark - Reward Video
-(void) showRewardVideoAds: (UIViewController*) uv {
    if ([self isRewardVideoReady]) {
        [self.rewardVideo presentFromRootViewController:uv];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"No Video" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [uv presentViewController:alert animated:true completion:nil];
    }
}

-(void) loadRewardVideoAds {
#ifdef DEBUG
    NSString* adUnitId = @"ca-app-pub-3940256099942544/1712485313";
#else
    NSString* adUnitId = @"ca-app-pub-7255639722534079/1595708112";
#endif
    
    self.rewardVideo = [GADRewardBasedVideoAd sharedInstance];
    self.rewardVideo.delegate = self;
    
    GADRequest* request = [GADRequest request];
#ifdef DEBUG
    request.testDevices = @[ @"691d58725df6a1f088675cbdcd71f513"];
#endif
    [self.rewardVideo loadRequest:request withAdUnitID:adUnitId];
}

-(BOOL) isRewardVideoReady {
    if (!self.rewardVideo.isReady) {
        NSLog(@"Reward Video Ads not ready. Reloading...");
        [self loadRewardVideoAds];
        return false;
    }
    return true;
}

#pragma mark - Delegates

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward {
//    NSString *rewardMessage =
//    [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf",
//     reward.type,
//     [reward.amount doubleValue]];
//    NSLog(rewardMessage);
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"AdMob reward based video did receive ad from: %@", rewardBasedVideoAd.adNetworkClassName);
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Opened reward based video ad.");
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad started playing.");
}

- (void)rewardBasedVideoAdDidCompletePlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad has completed.");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is closed.");
    [self loadRewardVideoAds];
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad will leave application.");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(NSError *)error {
    NSLog(@"Reward based video ad failed to load: %@", error.localizedDescription);
}




/// Tells the delegate an ad request succeeded.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"interstitialDidReceiveAd");
}

/// Tells the delegate an ad request failed.
- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

/// Tells the delegate that an interstitial will be presented.
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillPresentScreen");
}

/// Tells the delegate the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillDismissScreen");
}

/// Tells the delegate the interstitial had been animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialDidDismissScreen");
    [self loadInterstitialAds];
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication");
}



/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"adViewDidReceiveAd");
}

/// Tells the delegate an ad request failed.
- (void)adView:(GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

/// Tells the delegate that a full-screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillPresentScreen");
}

/// Tells the delegate that the full-screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

/// Tells the delegate that the full-screen view has been dismissed.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewDidDismissScreen");
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
}

-(void)requestInterstitial {
    [AdColony requestInterstitialInZone:@"vz1c0371bac9a74c029c" options:nil
                                success:^(AdColonyInterstitial* ad) {
                                    ad.open = ^{
                                        NSLog(@"Ad opened");
                                    };
                                    ad.close = ^{
                                        NSLog(@"Ad closed");
                                    };
                                    self.adcolony = ad;
                                }
                                failure:^(AdColonyAdRequestError* error) {
                                    NSLog(@"Interstitial request failed with error: %@", [error localizedDescription]);
                                }
     ];
}

-(void)showInterstitial: (UIViewController*) uv {
    [self.adcolony showWithPresentingViewController:uv];
}

@end

//appid = app1eb31ecdc5984287b2
//zone = vz1c0371bac9a74c029c
//apikey = ksKZuiZKrJAEwwkzn0Fm
