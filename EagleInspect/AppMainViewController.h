//
//  AppMainViewController.h
//  EagleInspect
//
//  Created by 刘生辉 on 2021/1/19.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import <DJIWidget/DJIWidget.h>

NS_ASSUME_NONNULL_BEGIN

#define WeakRef(__obj) __weak typeof(self) __obj = self
#define WeakReturn(__obj) if(__obj==nil)return;

@interface AppMainViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btnBacktoWelcome;
@property (weak, nonatomic) IBOutlet UIView *fpvview;
@property (weak, nonatomic) IBOutlet UIButton *btnChangeMode;
@property (weak, nonatomic) IBOutlet UIButton *btnCapture;
@property (weak, nonatomic) IBOutlet UIButton *btnRecord;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentMode;
@property (weak, nonatomic) IBOutlet UILabel *lblRecordingDuration;


- (IBAction)doBack:(id)sender;
- (IBAction)doChangeMode:(id)sender;
- (IBAction)doCapture:(id)sender;
- (IBAction)doRecording:(id)sender;


@end

NS_ASSUME_NONNULL_END
