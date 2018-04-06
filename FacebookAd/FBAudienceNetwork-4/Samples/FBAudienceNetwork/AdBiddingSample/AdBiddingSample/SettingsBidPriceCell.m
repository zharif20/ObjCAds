#import "SettingsBidPriceCell.h"

#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface SettingsBidPriceCell ()

@property (retain, nonatomic) IBOutlet UISlider *slider;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation SettingsBidPriceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.slider.maximumValue = 200.0f;
    self.slider.minimumValue = 0.0f;
    self.slider.value = [[NSUserDefaults standardUserDefaults] floatForKey:FB_AD_BID_PRICE];
    if (self.slider.value > 0) {
      self.priceLabel.text = [NSString stringWithFormat:@"Bid Price: %.2f", self.slider.value];
    }
}

- (IBAction)slideValueChanged:(UISlider *)slider {
    self.priceLabel.text = [NSString stringWithFormat:@"Bid Price: %.2f", slider.value];
    [[NSUserDefaults standardUserDefaults] setFloat:slider.value forKey:FB_AD_BID_PRICE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
