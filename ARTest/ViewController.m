//
//  ViewController.m
//  ARTest
//
//  Created by 迟人华 on 2017/8/1.
//  Copyright © 2017年 迟人华. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <ARSCNViewDelegate, ARSessionDelegate>

//AR视图：展示3D界面
@property (nonatomic, strong)ARSCNView *arSCNView;

//AR会话，负责管理相机追踪配置及3D相机坐标
@property(nonatomic,strong)ARSession *arSession;

//会话追踪配置
@property(nonatomic,strong)ARSessionConfiguration *arSessionConfiguration;

//Node对象
@property(nonatomic, strong) SCNNode *testNode;

@end

    
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view addSubview:self.arSCNView];
    self.arSCNView.delegate = self;
    
    [self.arSession runWithConfiguration:self.arSessionConfiguration];
}

- (void)initNode {
    self.testNode = [[SCNNode alloc] init];
    self.testNode.geometry = [SCNPlane planeWithWidth:1 height:0.5];
    [self.testNode setPosition:SCNVector3Make(0, 0, 0)];
    
    [self.arSCNView.scene.rootNode addChildNode:self.testNode];
    
    NSString *videoPath=[[NSBundle mainBundle] pathForResource:@"art.scnassets/video" ofType:@"mp4"];
    NSURL *videoURL=[NSURL fileURLWithPath:videoPath];
    
    SKVideoNode *videoNode = [SKVideoNode videoNodeWithURL:videoURL];
    videoNode.size = CGSizeMake(500, 250);
    videoNode.position = CGPointMake(videoNode.size.width/2, videoNode.size.height/2);
    videoNode.zRotation = M_PI;
    SKScene *skScene = [SKScene new];
    [skScene addChild:videoNode];
    skScene.size = videoNode.size;
    
    
    self.testNode.geometry.firstMaterial.diffuse.contents = skScene;
    [videoNode play];
    
}

- (ARSessionConfiguration *)arSessionConfiguration
{
    if (_arSessionConfiguration != nil) {
        return _arSessionConfiguration;
    }
    
    //1.创建世界追踪会话配置（使用ARWorldTrackingSessionConfiguration效果更加好），需要A9芯片支持
    ARWorldTrackingSessionConfiguration *configuration = [[ARWorldTrackingSessionConfiguration alloc] init];
    //2.设置追踪方向（追踪平面，后面会用到）
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    _arSessionConfiguration = configuration;
    //3.自适应灯光（相机从暗到强光快速过渡效果会平缓一些）
    _arSessionConfiguration.lightEstimationEnabled = YES;
    return _arSessionConfiguration;
}

- (ARSession *)arSession
{
    if(_arSession != nil)
    {
        return _arSession;
    }
    _arSession = [[ARSession alloc] init];
    _arSession.delegate = self;
    return _arSession;
}

- (ARSCNView *)arSCNView
{
    if (_arSCNView != nil) {
        return _arSCNView;
    }
    _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    _arSCNView.session = self.arSession;
    _arSCNView.automaticallyUpdatesLighting = YES;
    _arSCNView.delegate = self;
    
    //初始化节点
    [self initNode];
    
    return _arSCNView;
}

#pragma mark -ARSessionDelegate
//会话位置更新
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame
{
    //监听手机的移动，实现近距离查看太阳系细节，为了凸显效果变化值*3
    [self.testNode setPosition:SCNVector3Make(-3 * frame.camera.transform.columns[3].x, -0.1 - 3 * frame.camera.transform.columns[3].y, -2 - 3 * frame.camera.transform.columns[3].z)];
}


@end

