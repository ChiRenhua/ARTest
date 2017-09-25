//
//  ARAnimationViewController.m
//  ARTest
//
//  Created by 迟人华 on 2017/9/25.
//  Copyright © 2017年 迟人华. All rights reserved.
//

#import "ARAnimationViewController.h"
#import <SceneKit/SceneKit.h>
#import <SpriteKit/SpriteKit.h>
#import <ARKit/ARKit.h>

@interface ARAnimationViewController () <ARSessionDelegate>

@property (nonatomic, strong) ARSCNView *arSCNView;
@property (nonatomic, strong) SCNNode *animationNode;
@property (nonatomic, strong) ARSession *arSession;
@property (nonatomic, strong) ARConfiguration *arSessionConfiguration;

@end

@implementation ARAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"AR动画";
}

- (void)viewWillAppear:(BOOL)animated {
    self.arSCNView.delegate = (id)self;
    
    [self.arSession runWithConfiguration:self.arSessionConfiguration];
    [self.view addSubview:self.arSCNView];
}

- (ARConfiguration *)arSessionConfiguration {
    if (_arSessionConfiguration != nil) {
        return _arSessionConfiguration;
    }
    
    //1.创建世界追踪会话配置（使用ARWorldTrackingSessionConfiguration效果更加好），需要A9芯片支持
    ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
    //2.设置追踪方向（追踪平面，后面会用到）
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    _arSessionConfiguration = configuration;
    //3.自适应灯光（相机从暗到强光快速过渡效果会平缓一些）
    _arSessionConfiguration.lightEstimationEnabled = YES;
    return _arSessionConfiguration;
}

- (ARSession *)arSession {
    if(_arSession != nil)
    {
        return _arSession;
    }
    _arSession = [[ARSession alloc] init];
    _arSession.delegate = self;
    return _arSession;
}

- (ARSCNView *)arSCNView {
    if (_arSCNView != nil) {
        return _arSCNView;
    }
    _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    _arSCNView.session = self.arSession;
    _arSCNView.automaticallyUpdatesLighting = YES;
    _arSCNView.delegate = (id)self;
    
    //初始化节点
//    [self initNode];
    
    return _arSCNView;
}

@end
