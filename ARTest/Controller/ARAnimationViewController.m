//
//  ARAnimationViewController.m
//  ARTest
//
//  Created by 迟人华 on 2017/9/25.
//  Copyright © 2017年 迟人华. All rights reserved.
//

#import "ARAnimationViewController.h"
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ReplayKit/ReplayKit.h>

@interface ARAnimationViewController () <ARSCNViewDelegate, ARSessionDelegate, RPPreviewViewControllerDelegate>
@property (nonatomic, strong) ARSCNView *sceneView;
@property (nonatomic, strong) SCNNode *characterNode;
@end


@implementation ARAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sceneView.delegate = self;
    self.sceneView.showsStatistics = YES;
    
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/characters/explorer/explorer_skinned.dae"];
    
    
    
    self.sceneView.scene = scene;
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(bounds.size.width/2-60, bounds.size.height - 200, 120, 100)];
    [button setTitle:@"点击录制" forState:UIControlStateNormal];
    [button setTitle:@"录制中" forState:UIControlStateSelected];
    [button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    RPScreenRecorder *recorder = [RPScreenRecorder sharedRecorder];
    if([recorder isAvailable]) {
        NSLog(@"支持录制");
    }else{
        NSLog(@"不支持录制");
    }
    
    [self.view addSubview:self.sceneView];
    [self.sceneView addSubview:button];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    [self.sceneView.session runWithConfiguration:configuration];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - action

-(void)clicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        RPScreenRecorder *recorder = [RPScreenRecorder sharedRecorder];
        recorder.microphoneEnabled = YES;
        [recorder startRecordingWithHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"start recorder error - %@",error);
            }
        }];
    }else {
        RPScreenRecorder *recorder = [RPScreenRecorder sharedRecorder];
        [recorder stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
            
            previewViewController.previewControllerDelegate = self;
            [self presentViewController:previewViewController animated:NO completion:^{
                NSLog(@"开始播放啦");
            }];
        }];
    }
}

- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController
{
    [previewController dismissViewControllerAnimated:YES completion:nil];
}

- (ARSCNView *)sceneView {
    if (_sceneView != nil) {
        return _sceneView;
    }
    _sceneView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    _sceneView.automaticallyUpdatesLighting = YES;
    _sceneView.delegate = self;
    
    return _sceneView;
}

@end
