//
//  ViewController.m
//  SCVoiceConvertDemo
//
//  Created by jiangdianyi on 12/1/2017.
//  Copyright © 2017 d jiang. All rights reserved.
//

#import "SCViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceConverter.h"


@interface SCViewController () <AVAudioRecorderDelegate>
@property (strong, nonatomic) AVAudioRecorder   *audioRecorder;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) NSURL *wavFileURL;
@property (strong, nonatomic) NSURL *amrFileURL;
@property (copy, nonatomic) NSString *filename;
@end

#define UI_SCREEN_WIDTH       ([UIScreen mainScreen].bounds.size.width)
#define UI_SCREEN_HEIGHT      ([UIScreen mainScreen].bounds.size.height)

@implementation SCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *recordButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, UI_SCREEN_WIDTH - 40, 100)];
    recordButton.selected = NO;
    [recordButton setTitle:@"press to record" forState:UIControlStateNormal];
    [recordButton setTitle:@"press to stop" forState:UIControlStateSelected];
    [recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [recordButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    
    [recordButton addTarget:self action:@selector(didButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordButton];
    _label = [[UILabel alloc] initWithFrame:CGRectMake(20, 300, UI_SCREEN_WIDTH - 40, 200)];
    _label.numberOfLines = 0;
    [self.view addSubview:_label];
    
    UIBarButtonItem *bbil1 = [[UIBarButtonItem alloc] initWithTitle:@"wav to amr" style:UIBarButtonItemStylePlain target:self action:@selector(wav2amr)];
    UIBarButtonItem *bbir1 = [[UIBarButtonItem alloc] initWithTitle:@"amr to wav" style:UIBarButtonItemStylePlain target:self action:@selector(amr2wav)];
    
    self.navigationItem.leftBarButtonItems = @[bbil1];
    self.navigationItem.rightBarButtonItems = @[bbir1];
}

- (void)wav2amr {
    NSString *amrFilePath = [self amrFilePathFromFileName:self.filename];
    self.amrFileURL = [NSURL fileURLWithPath:amrFilePath];
    if (self.wavFileURL) {
        [VoiceConverter ConvertWavToAmr:self.wavFileURL.path amrSavePath:amrFilePath];
    }
}

- (void)playamr {
    
}

- (void)amr2wav {
    NSString *wavFilePath = [self wavFilePathFromFileName:@"copy"];
    [VoiceConverter ConvertAmrToWav:self.amrFileURL.path wavSavePath:wavFilePath];
}

- (void)playwav {
    
}


- (void)didButtonClick:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    
    if (sender.isSelected) {
        // start recording
        [self startRecording];
    } else {
        // stop recording
        [self stopRecording];
    }
}

- (void)startRecording {
    __weak typeof(&*self) weakSelf = self;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [weakSelf permissionGranted];
            } else {
            }
        });
    }];
}

- (void)stopRecording {
    [_audioRecorder stop];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    self.label.text = self.wavFileURL.path;
    self.filename = self.wavFileURL.path.lastPathComponent;
}





- (void)permissionGranted {
    if ([self configureSession]) {
        [self setupRecorder];
        NSLog(@"%@", @([_audioRecorder isRecording]));
        [_audioRecorder record];
        NSLog(@"%@", @([_audioRecorder isRecording]));
    }
}

- (void)setupRecorder {
    NSError *recorderSetupError = nil;
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    [settings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    [settings setValue :[NSNumber numberWithFloat:8000.0] forKey: AVSampleRateKey];
    [settings setValue :[NSNumber numberWithInt:1] forKey: AVNumberOfChannelsKey];
    [settings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
    //    [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    [settings setObject:[NSNumber numberWithInt:8] forKey:AVEncoderBitRateKey];
    self.wavFileURL = [self fileURL];
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.wavFileURL settings:settings error:&recorderSetupError];
    _audioRecorder.delegate = self;
    if (recorderSetupError) {
        NSLog(@"%@",recorderSetupError);
    }
    _audioRecorder.meteringEnabled = YES;
    [_audioRecorder prepareToRecord];
}

- (BOOL)configureSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if(sessionError){
        NSLog(@"Error creating session: %@", [sessionError description]);
    }
    else{
        [audioSession setActive:YES error:nil];
    }
    if (!audioSession.isInputAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"Audio input hardware not available"
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [cantRecordAlert show];
        return NO;
    } else {
        return YES;
    }
}

- (NSURL *)fileURL
{
    return [NSURL fileURLWithPath:[self filePath] isDirectory:NO];
}

- (NSString *)filePath {
    return [self wavFilePathFromFileName:[self fileName]];
}

- (NSString *)amrFilePathFromFileName:(NSString *)fileName {
    fileName = [[fileName lastPathComponent] stringByDeletingPathExtension];
    return [[[self audioCachesDirectory] stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"amr"];
}

- (NSString *)wavFilePathFromFileName:(NSString *)fileName {
    fileName = [[fileName lastPathComponent] stringByDeletingPathExtension];
    return [[[self audioCachesDirectory] stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"wav"];
}

+ (NSString *)ez_getCachePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0 ? [paths lastObject] : @"undefined");
}

- (NSString *)audioCachesDirectory {
    NSString *cachesPath = [[self ez_getCachePath] stringByAppendingPathComponent:@"audio"];
    if (![self ez_createDirectory:cachesPath]) {
        NSLog(@"create dir failed");
    }
    return cachesPath;
}

- (NSString *)ez_getCachePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0 ? [paths lastObject] : @"undefined");
}

- (BOOL)ez_createDirectory:(NSString*)path {
    
    if ([self ez_isDirectoryExist:path]) {
        return YES;
    }
    NSError* error;
    return [[NSFileManager defaultManager]createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
}
- (BOOL)ez_isDirectoryExist:(NSString*)directoryPath{
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    return isDirectory;
}

- (NSString *)fileName {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMddHHmmss";
    return [dateFormatter stringFromDate:[NSDate date]];
}


@end