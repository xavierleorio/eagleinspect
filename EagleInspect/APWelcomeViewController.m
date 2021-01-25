//
//  APWelcomeViewController.m
//  EagleInspect
//
//  Created by 刘生辉 on 2021/1/19.
//

#import "APWelcomeViewController.h"

@interface APWelcomeViewController () <DJISDKManagerDelegate, DJIAppActivationManagerDelegate>

@end

@implementation APWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //register app
    [DJISDKManager registerAppWithDelegate:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)appRegisteredWithError:(NSError * _Nullable)error {
    if(error != nil){
        NSLog(@"应用程序注册失败!: %@", error.localizedDescription);
        return;
    }
    NSLog(@"应用程序注册成功!");
    
    //activate the app
    [DJISDKManager appActivationManager].delegate = self;
    
    //connect to the drone
    [DJISDKManager startConnectionToProduct];
}

- (void)didUpdateDatabaseDownloadProgress:(nonnull NSProgress *)progress {
    NSLog(@"Download Progress: %lld/%lld %@", progress.completedUnitCount, progress.totalUnitCount,
          progress.localizedDescription);
}

- (void)productConnected:(DJIBaseProduct *_Nullable)product{
    NSLog(@"设备连接：%@", product.model);
}


/**
 *  Called when the "product" is disconnected.
 */
- (void)productDisconnected{
    NSLog(@"设备断开链接");
}


/**
 *  Called when the connected product is changed. The product will be updated when
 *  the aircraft connected changes from only remote controller connected.
 *
 *  @param product An instance of `DJIBaseProduct`.
 */

/**
 *  Called when the "component" is connected.
 *
 *  @param key Key of the component.
 *  @param index Index of the component.
 */
- (void)componentConnectedWithKey:(NSString * _Nullable)key andIndex:(NSInteger)index{
    NSLog(@"组件：%@， index：%ld 已经连接", key, index);
}


/**
 *  Called when the "component" is disconnected.
 *
 *  @param key Key of the component.
 *  @param index Index of the component.
 */
- (void)componentDisconnectedWithKey:(NSString * _Nullable)key andIndex:(NSInteger)index{
    NSLog(@"组件：%@， index：%ld 已经断开连接", key, index);
}



#pragma mark - implement the ActivateDelegateProtocol

-(void)manager:(DJIAppActivationManager *)manager didUpdateAppActivationState:(DJIAppActivationState)appActivationState{
    
    switch (appActivationState) {
        case DJIAppActivationStateNotSupported:
            self.lblAppActivationState.text = @"应用程序激活状态：Not Suppoted.";
            break;
        case DJIAppActivationStateLoginRequired:
            self.lblAppActivationState.text = @"应用程序激活状态：Login Required.";
            break;
        case DJIAppActivationStateUnknown:
            self.lblAppActivationState.text = @"应用程序激活状态：Login Required.";
            break;
        case DJIAppActivationStateActivated:
            self.lblAppActivationState.text = @"应用程序激活状态：Activated.";
            break;
        default:
            break;
    }
}
-(void)manager:(DJIAppActivationManager *)manager didUpdateAircraftBindingState:(DJIAppActivationAircraftBindingState)aircraftBindingState{
    
    switch (aircraftBindingState) {
        case DJIAppActivationAircraftBindingStateBound:
            self.lblAircarftBoundingState.text = @"无人机绑定状态：Bound.";
            break;
        case DJIAppActivationAircraftBindingStateNotRequired:
            self.lblAircarftBoundingState.text = @"无人机绑定状态：Not reqquired.";
            break;
        default:
            break;
    }
}

#pragma mark - UI operation
- (IBAction)btnEnterDevice:(id)sender {
}

- (IBAction)btnLoginDJIAccount:(id)sender {
    
    //WeakRef and WeakReturn are macro defined in APWelcomeViewControleller.h
    //were basically used to prevent recursive crash.
    //target is the self
    WeakRef(target);
    [[DJISDKManager userAccountManager] logIntoDJIUserAccountWithAuthorizationRequired:YES withCompletion:^(DJIUserAccountState state, NSError * _Nullable error) {
        WeakReturn(target); //if the target(the current view controller) is missing, return)
        switch (state){
            case DJIUserAccountStateAuthorized:
                [target showAlertViewWithTitle: @"Log into DJI Accounct" withMessage: @"Login Succeed and sucessfully authorized."];
                break;
            case DJIUserAccountStateNotAuthorized:
                [target showAlertViewWithTitle: @"Log into DJI Accounct" withMessage: @"Login not authorized."];
                break;
            case DJIUserAccountStateTokenOutOfDate:
                [target showAlertViewWithTitle: @"Log into DJI Accounct" withMessage: @"Token has been out of date."];
                break;
            case DJIUserAccountStateNotLoggedIn:
                [target showAlertViewWithTitle: @"Log into DJI Accounct" withMessage: @"Login failed."];
                break;
            case DJIUserAccountStateUnknown:
                [target showAlertViewWithTitle: @"Log into DJI Accounct" withMessage: @"Unknown."];
                break;
            default:
                break;
        }
    }];
}

- (void)showAlertViewWithTitle: (NSString *)title withMessage: (NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
