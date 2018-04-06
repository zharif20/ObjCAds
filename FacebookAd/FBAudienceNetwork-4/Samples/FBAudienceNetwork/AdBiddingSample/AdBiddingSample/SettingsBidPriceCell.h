#import <UIKit/UIKit.h>

static NSString * const FB_AD_BID_PRICE = @"fb_ad_bid_price";

@interface SettingsBidPriceCell : UITableViewCell

@property (nonatomic, copy) void (^onBidPriceChange)(CGFloat price);

@end
