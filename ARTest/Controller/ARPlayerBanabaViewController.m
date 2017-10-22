//
//  ARPlayerBanabaViewController.m
//  ARTest
//
//  Created by 迟人华 on 2017/10/12.
//  Copyright © 2017年 迟人华. All rights reserved.
//

#import "ARPlayerBanabaViewController.h"
#import <SceneKit/SceneKit.h>
#import <SpriteKit/SpriteKit.h>
#import <ARKit/ARKit.h>
#import "Plane.h"

@interface ARPlayerBanabaViewController () <ARSCNViewDelegate, ARSessionDelegate>

//AR视图：展示3D界面
@property (nonatomic, strong) ARSCNView *arSCNView;

//AR会话，负责管理相机追踪配置及3D相机坐标
@property (nonatomic, strong) ARSession *arSession;

//会话追踪配置
@property (nonatomic, strong) ARConfiguration *arSessionConfiguration;

//Node对象
@property (nonatomic, strong) SCNNode *videoNode;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSArray *banabaTextArray;

@property (nonatomic, strong) NSMutableDictionary *planeArray;

@end

@implementation ARPlayerBanabaViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.arSCNView.delegate = self;
    [self.arSession runWithConfiguration:self.arSessionConfiguration];
    [self.view addSubview:self.arSCNView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"AR弹幕";
    
    self.planeArray = [NSMutableDictionary new];
    
    self.banabaTextArray = [[NSArray alloc] initWithObjects:@"哎呦不错哦～～", @"是的呢!", @"啊哈哈哈～", @"解说胸好大哦～", @"男的略丑...", @"王者！", @"憋吵吵！", @"第一", @"牛逼！", @"作者牛逼不？！", nil];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(banabaMove) userInfo:nil repeats:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.timer invalidate];
}

- (void)dealloc {
    self.videoNode = nil;
    
}

- (void)banabaMove {
    [self.videoNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(8, 2.5, -3)]];
    [self.videoNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(8, 2, -3)]];
    [self.videoNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(8, 1.5, -3)]];
    [self.videoNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(9, 1, -3)]];
    [self.videoNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(8, 0.5, -3)]];
    [self.videoNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(9, 0, -3)]];
    [self.videoNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(8, -0.5, -3)]];
}

- (NSString *)banabaTextFromArray {
    int index = arc4random() % 10;
    return self.banabaTextArray[index];
}

- (void)initNode {
    self.videoNode = [[SCNNode alloc] init];
    self.videoNode.geometry = [SCNBox boxWithWidth:6 height:0.01 length:3 chamferRadius:0];
    [self.videoNode setPosition:SCNVector3Make(0, -3, -5)];
    
//    [self.arSCNView.scene.rootNode addChildNode:self.videoNode];
    
    NSURL *videoURL1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"art.scnassets/video1" ofType:@"mp4"]];
    
    self.videoNode.geometry.materials = @[[SCNMaterial new], [SCNMaterial new], [SCNMaterial new], [SCNMaterial new], [self playerMaterialWithPlayAddress:videoURL1], [SCNMaterial new]];
}

- (SCNNode *)banabaNodeWithText:(NSString *)banabaStr vector3Make:(SCNVector3)vector3make {
    SCNText *banabaText = [SCNText textWithString:banabaStr extrusionDepth:0.03];
    banabaText.font = [UIFont systemFontOfSize:0.3];
    banabaText.firstMaterial.diffuse.contents = [UIColor whiteColor];
    
    __block SCNNode *banabaNode = [SCNNode nodeWithGeometry:banabaText];
    banabaNode.geometry = banabaText;
    banabaNode.position = vector3make;
    
    [banabaNode runAction:[SCNAction moveTo:SCNVector3Make(-10, vector3make.y, vector3make.z) duration:15] completionHandler:^{
        [banabaNode removeFromParentNode];
    }];
    
    return banabaNode;
}

- (SCNMaterial *)playerMaterialWithPlayAddress:(NSURL *)url {
    SKVideoNode *videoNode = [SKVideoNode videoNodeWithURL:url];
    videoNode.size = CGSizeMake(2000, 1000);
    videoNode.position = CGPointMake(videoNode.size.width/2, videoNode.size.height/2);
    videoNode.zRotation = M_PI;
    
    SKScene *skScene = [SKScene new];
    [skScene addChild:videoNode];
    skScene.size = videoNode.size;
    
    SCNMaterial *playerMaterial = [SCNMaterial material];
    playerMaterial.diffuse.contents = skScene;
    playerMaterial.locksAmbientWithDiffuse = YES;
    
    [videoNode play];
    
    return playerMaterial;
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
    
     [self.arSCNView.session runWithConfiguration:configuration options:ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors];
    
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
    _arSCNView.delegate = self;
    
    //初始化节点
    [self initNode];
    
    return _arSCNView;
}

#pragma mark -ARSessionDelegate
//会话位置更新
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    [self.videoNode setPosition:SCNVector3Make(-5 * frame.camera.transform.columns[3].x, -3 -5 * frame.camera.transform.columns[3].y, -5 -5 * frame.camera.transform.columns[3].z)];
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
        return;
    }
    
    if (node.childNodes.count > 0) {
        return;
    }

    Plane *plane = [[Plane alloc] initWithAnchor: (ARPlaneAnchor *)anchor];
//    [plane addChildNode:self.videoNode];
    self.videoNode.position = plane.position;
    [node addChildNode:plane];
        [self.arSCNView.scene.rootNode addChildNode:self.videoNode];
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
//    [node enumerateChildNodesUsingBlock:^(SCNNode * _Nonnull child, BOOL * _Nonnull stop) {
//        [child removeFromParentNode];
//    }];
//
//    Plane *plane = [[Plane alloc] initWithAnchor: (ARPlaneAnchor *)anchor];
//    [plane addChildNode:self.videoNode];
//    [node addChildNode:plane];
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {

//    [self.planeArray removeObjectForKey:anchor.identifier];
}

@end
