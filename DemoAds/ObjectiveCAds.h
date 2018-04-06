//
//  ObjectiveCAds.h
//  DemoAds
//
//  Created by Calvin on 5/4/18.
//  Copyright © 2018 gogame. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GoogleMobileAds;
#import "Firebase.h"
#import <AdColony/AdColony.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface ObjectiveCAds : NSObject <GADInterstitialDelegate,GADRewardBasedVideoAdDelegate, GADBannerViewDelegate>

typedef enum {
    bottom = 0,
    top
} BannerPosition;


@property(nonatomic, strong) GADInterstitial*interstitial;
@property(nonatomic, strong) GADRewardBasedVideoAd*rewardVideo;
@property(nonatomic, strong) GADBannerView *bannerView;
@property (assign, nonatomic) BannerPosition bannerPosition;

+(ObjectiveCAds*) sharedInstance;
-(void) googleAdsInit;
-(void) loadInterstitialAds;
-(void) loadRewardVideoAds;
-(void) showRewardVideoAds: (UIViewController*) uv;
-(void) showInterstitialAds: (UIViewController*) uv;
-(void) showBannerAds:(UIViewController*) uv withPosition: (BannerPosition) position;
-(void) adColonyOptimization;
-(void)requestInterstitial;
-(void)showInterstitial: (UIViewController*) uv;

@end
