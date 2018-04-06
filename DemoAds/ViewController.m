//
//  ViewController.m
//  DemoAds
//
//  Created by Calvin on 5/4/18.
//  Copyright © 2018 gogame. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[ObjectiveCAds sharedInstance] showBannerAds:self withPosition:bottom];
    
    self.rewardVideo = [[UIButton alloc] init];
    self.rewardVideo = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rewardVideo.translatesAutoresizingMaskIntoConstraints = false;
    self.rewardVideo.backgroundColor = [UIColor blackColor];
    [self.rewardVideo addTarget:self action:@selector(showRewardVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rewardVideo];
    
    self.interstitialAds = [[UIButton alloc] init];
    self.interstitialAds = [UIButton buttonWithType:UIButtonTypeCustom];
    self.interstitialAds.translatesAutoresizingMaskIntoConstraints = false;
    self.interstitialAds.backgroundColor = [UIColor redColor];
    [self.interstitialAds addTarget:self action:@selector(showInterstitialAds) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.interstitialAds];
    
    [self.rewardVideo.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.rewardVideo.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.rewardVideo.widthAnchor constraintEqualToConstant:250].active = YES;
    [self.rewardVideo.heightAnchor constraintEqualToConstant:50].active = YES;
    
    [self.interstitialAds.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.interstitialAds.topAnchor constraintEqualToAnchor:self.rewardVideo.bottomAnchor constant:10].active = YES;
    [self.interstitialAds.widthAnchor constraintEqualToConstant:250].active = YES;
    [self.interstitialAds.heightAnchor constraintEqualToConstant:50].active = YES;

    
}


-(void) showRewardVideo {
    [[ObjectiveCAds sharedInstance] showRewardVideoAds:self];
//    [[ObjectiveCAds sharedInstance] requestInterstitial];
}

-(void) showInterstitialAds {
    [[ObjectiveCAds sharedInstance] showInterstitialAds:self];
//    [[ObjectiveCAds sharedInstance] showInterstitial:self];
}


@end
