//
//  AppMainViewController.m
//  EagleInspect
//
//  Created by 刘生辉 on 2021/1/19.
//

#import "AppMainViewController.h"

@interface AppMainViewController ()<DJIVideoFeedListener, DJICameraDelegate>

@property (nonatomic, assign) DJICameraMode modeCamera;
@property (nonatomic, assign) BOOL isStoringPhoto;
@property (nonatomic, assign) BOOL isRecordingVideo;
@property (nonatomic, assign) int currentRecordingTime;

@end

@implementation AppMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[DJISDKManager videoFeeder].primaryVideoFeed addListener:self withQueue:nil];
    
    [[DJIVideoPreviewer instance] setView:self.fpvview];
    
    [[DJIVideoPreviewer instance] start];
    
    //Acquire camera mode after catching a camera.
    DJICamera *camera = [self getCamera];
    if(camera != nil)
    {
        camera.delegate = self;
    }
    
    
}

- (DJICamera*) getCamera{
    //The method is for get a camera object to capture image or start recording.
    //get the default camera using this method.
    if([DJISDKManager product] == nil)
    {
        //The connection might be unstable, use if to detect the source.
        return nil;
    }else{
        
        DJICamera* camera = [DJISDKManager product].camera;
        NSLog(@"Default Camera: %@", camera.displayName);
        
        return camera;
    }
    //some product has more than one camera, so use the cameras properties
    //class pointer used
//    NSArray * cameras = ((DJIAircraft*)[DJISDKManager product]).cameras;
//    DJICamera* camera1 = [cameras objectAtIndex:0];
//    DJICamera* camera2 = [cameras objectAtIndex:1];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[DJISDKManager videoFeeder].primaryVideoFeed removeListener:self];
    
    [[DJIVideoPreviewer instance] unSetView];
    
    DJICamera *camera = [self getCamera];
    if(camera != nil)
    {
        camera.delegate = nil; //release the delegate
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doRecording:(id)sender {
    
    DJICamera *camera = [self getCamera];
    if (camera == nil)
    {
        return;
    }
    if (self.modeCamera != DJICameraModeRecordVideo)
    {
        return;
    }
    
    if(self.isRecordingVideo)
    {
        [camera stopRecordVideoWithCompletion:^(NSError * _Nullable error) {
            if(error != nil)
            {
                NSLog(@"Stopping Recording Failed! : %@", error.localizedDescription);
                return;
            }
                }];
    }else{
        [camera startRecordVideoWithCompletion:^(NSError * _Nullable error) {
                if(error != nil)
                {
                    NSLog(@"Starting Recording Failed! : %@", error.localizedDescription);
                    return;
                }
        }];
    }
}

- (IBAction)doCapture:(id)sender {
    //capturing a image: get camera object->set up mode-> start the image capturing
    
    __weak DJICamera *camera = [self getCamera]; //always get the current camera object and check nil
    
    
    if (self.modeCamera != DJICameraModeShootPhoto)
    {
        return;
    }
    
    //different photo modes have been defined in a enum. Single/Burst/HDR/EHDR..., not every mode is supported in all drone model.
    [camera setShootPhotoMode:DJICameraShootPhotoModeSingle withCompletion:^(NSError * _Nullable error) {
        if(error != nil)
        {
            NSLog(@"Image Mode setting error ocurred! : %@", error.localizedDescription);
            return;
        }
    }];
    if (camera != nil)
    {
        //check if the camera is storing photo before taking photos
        if (self.isStoringPhoto == YES)
        {
            NSLog(@"Storing Photo(s). Wait a second.");
            return;
        }
        
        [camera startShootPhotoWithCompletion:^(NSError * _Nullable error) {
            if(error != nil)
            {
                NSLog(@"Image Capture error ocurred! : %@", error.localizedDescription);
            }
        }];
    }
}

- (IBAction)doChangeMode:(id)sender {
    //A flip-flop switch the camera mode between photo shooting mode and recording mode.
    DJICamera *camera = [self getCamera];
    if(self.modeCamera == DJICameraModeShootPhoto){
        [self setCameraMode:camera withMode:DJICameraModeRecordVideo];
    }else if (self.modeCamera == DJICameraModeRecordVideo){
        [self setCameraMode:camera withMode:DJICameraModeShootPhoto];
    }else{
        NSLog(@"Unknown error when setting the mode");
    }
}

- (void)setCameraMode:(DJICamera *)camera withMode: (DJICameraMode) mode{
    if (camera != nil)
    {
        WeakRef(target);
        //withCompletion is a callback function.
        [camera setMode:mode withCompletion:^(NSError * _Nullable error) {
            WeakReturn(target); //if the view controller is nonexistent, return
            if(error != nil)
            {
                NSLog(@"Camera Mode setting failed. : %@", error.localizedDescription);
            }else{
                [target updateUI];//update the mode
            }
        }];
    }
}

- (void)updateUI{
    NSString *modeText = [self cameraModeStringTranslate:self.modeCamera];
    self.lblCurrentMode.text =[NSString stringWithFormat:@"当前相机模式：%@", modeText]; //The method was implemented in the following code
    self.lblRecordingDuration.text = [NSString stringWithFormat:@"录像时间：%d", self.currentRecordingTime]; // updateUI method will be called once the systemstate update, smalltalk message mechanism.
}

- (IBAction)doBack:(id)sender {
    
    NSLog(@"CLOSECLOSECLOSE");
    [self dismissViewControllerAnimated:YES completion:nil];
}

//(nonnull NSData *)videoData is the video stream
// in this implemetation of the protocol, we'll send the stream to the decoder provided by DJI
- (void)videoFeed:(nonnull DJIVideoFeed *)videoFeed didUpdateVideoData:(nonnull NSData *)videoData{
    [[DJIVideoPreviewer instance] push:(uint8_t *)videoData.bytes length:(int)videoData.length];
}

- (void)camera:(DJICamera *_Nonnull)camera didUpdateSystemState:(DJICameraSystemState *_Nonnull)systemState{
    
    self.modeCamera = systemState.mode;
    self.isStoringPhoto = systemState.isStoringPhoto;
    self.isRecordingVideo = systemState.isRecording;
    self.currentRecordingTime =  systemState.currentVideoRecordingTimeInSeconds;
    
    [self updateUI];
    
}

- (NSString *)cameraModeStringTranslate:(DJICameraMode) mode{
    //translate enum type to displayable string to the UI
    NSString *returnString = @"N/A";
    switch(mode){
        case DJICameraModeUnknown:
            returnString = @"Unkown Mode";
            break;
        case DJICameraModePlayback:
            returnString = @"Playback Mode";
            break;
        case DJICameraModeBroadcast:
            returnString = @"Broadcast Mode";
            break;
        case DJICameraModeShootPhoto:
            returnString = @"Photoshooting Mode";
            break;
        case DJICameraModeRecordVideo:
            returnString = @"Video-recording Mode";
            break;
        case DJICameraModeMediaDownload:
            returnString = @"Media-downloading Mode";
            break;
        default:
            break;
            
    }
    return returnString;
    
}
@end
