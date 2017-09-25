//
//  ARPlayerViewController.m
//  ARTest
//
//  Created by 迟人华 on 2017/8/1.
//  Copyright © 2017年 迟人华. All rights reserved.
//

#import "ARPlayerViewController.h"

@interface ARPlayerViewController () <ARSCNViewDelegate, ARSessionDelegate>

//AR视图：展示3D界面
@property (nonatomic, strong) ARSCNView *arSCNView;

//AR会话，负责管理相机追踪配置及3D相机坐标
@property (nonatomic, strong) ARSession *arSession;

//会话追踪配置
@property (nonatomic, strong) ARConfiguration *arSessionConfiguration;

//Node对象
@property (nonatomic, strong) SCNNode *testNode;

@property (nonatomic, strong) NSMutableArray *playerBtnArray;

@property (nonatomic, assign) BOOL isPlaying;

@end

@implementation ARPlayerViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidLoad];
    
    self.playerBtnArray = [[NSMutableArray alloc] init];
    
    self.arSCNView.delegate = self;
    [self.arSession runWithConfiguration:self.arSessionConfiguration];
    [self.view addSubview:self.arSCNView];
}

- (void)viewDidLoad {
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (void)dealloc {
    self.testNode = nil;
    self.playerBtnArray = nil;
    
}

- (void)initNode {
    self.testNode = [[SCNNode alloc] init];
    self.testNode.geometry = [SCNBox boxWithWidth:1 height:0.5 length:1 chamferRadius:0];
    [self.testNode setPosition:SCNVector3Make(0, 0, - 2)];
    
    [self.arSCNView.scene.rootNode addChildNode:self.testNode];
    
    NSURL *videoURL1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"art.scnassets/video1" ofType:@"mp4"]];
    NSURL *videoURL2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"art.scnassets/video2" ofType:@"mp4"]];
    NSURL *videoURL3 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"art.scnassets/video3" ofType:@"mp4"]];
    NSURL *videoURL4 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"art.scnassets/video4" ofType:@"m4v"]];
    
    self.testNode.geometry.materials = @[[self playerMaterialWithPlayAddress:videoURL1],
                                         [self playerMaterialWithPlayAddress:videoURL2],
                                         [self playerMaterialWithPlayAddress:videoURL3],
                                         [self playerMaterialWithPlayAddress:videoURL4],
                                         [self playerMaterialWithPlayAddress:videoURL4],
                                         [self playerMaterialWithPlayAddress:videoURL4],];
}

- (SCNMaterial *)playerMaterialWithPlayAddress:(NSURL *)url {
    SKVideoNode *videoNode = [SKVideoNode videoNodeWithURL:url];
    videoNode.size = CGSizeMake(500, 250);
    videoNode.position = CGPointMake(videoNode.size.width/2, videoNode.size.height/2);
    videoNode.zRotation = M_PI;
    
    SKSpriteNode *playerBtnNode = [[SKSpriteNode alloc] initWithImageNamed:@"play"];
    playerBtnNode.size = CGSizeMake(100, 100);
    playerBtnNode.position = CGPointMake(videoNode.size.width/2, videoNode.size.height/2);
    
    SKSpriteNode *pauseBtnNode = [[SKSpriteNode alloc] initWithImageNamed:@"pause"];
    pauseBtnNode.size = CGSizeMake(100, 100);
    pauseBtnNode.position = CGPointMake(videoNode.size.width/2, videoNode.size.height/2);
    pauseBtnNode.alpha = 0;
    
    SKScene *skScene = [SKScene new];
    [skScene addChild:videoNode];
    [skScene addChild:playerBtnNode];
    skScene.size = videoNode.size;
    
    [self.playerBtnArray addObject:skScene];
    
    SCNMaterial *playerMaterial = [SCNMaterial material];
    playerMaterial.diffuse.contents = skScene;
    playerMaterial.locksAmbientWithDiffuse = YES;
    
    self.isPlaying = NO;
    
    return playerMaterial;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint loaction = [touch locationInView:self.arSCNView];
    NSArray *hitTestArray = [self.arSCNView hitTest:loaction options:nil];
    
    if (hitTestArray.count > 0) {
        [self.playerBtnArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SKScene *skScene = (SKScene *)obj;
            SKNode *node = [skScene nodeAtPoint:loaction];
            
            if ([node isKindOfClass:[SKScene class]]) {
                SKScene *targetScene = (SKScene *)node;
                [targetScene.children enumerateObjectsUsingBlock:^(SKNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[SKVideoNode class]]) {
                        SKVideoNode *videoNode = (SKVideoNode *)obj;
                        
                        if (self.isPlaying) {
                            [videoNode pause];
                            self.isPlaying = NO;
                        }else {
                            [videoNode play];
                            self.isPlaying = YES;
                        }
                    }else {
                        obj.alpha = !obj.alpha;
                    }
                    
                }];
            }
        }];
    }
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
    _arSCNView.delegate = self;
    
    //初始化节点
    [self initNode];
    
    return _arSCNView;
}

#pragma mark -ARSessionDelegate
//会话位置更新
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    [self.testNode setPosition:SCNVector3Make(-5 * frame.camera.transform.columns[3].x, -5 * frame.camera.transform.columns[3].y, -3 -5 * frame.camera.transform.columns[3].z)];
}

@end

