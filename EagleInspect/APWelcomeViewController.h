//
//  APWelcomeViewController.h
//  EagleInspect
//
//  Created by 刘生辉 on 2021/1/19.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

NS_ASSUME_NONNULL_BEGIN

#define WeakRef(__obj) __weak typeof(self) __obj = self
#define WeakReturn(__obj) if(__obj==nil)return;

@interface APWelcomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblAppActivationState;
@property (weak, nonatomic) IBOutlet UILabel *lblAircarftBoundingState;
- (IBAction)btnLoginDJIAccount:(id)sender;
- (IBAction)btnEnterDevice:(id)sender;

@end

NS_ASSUME_NONNULL_END
