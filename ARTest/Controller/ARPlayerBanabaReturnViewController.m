//
//  ARPlayerBanabaReturnViewController.m
//  ARTest
//
//  Created by 迟人华 on 2017/10/13.
//  Copyright © 2017年 迟人华. All rights reserved.
//

#import "ARPlayerBanabaReturnViewController.h"
#import <SceneKit/SceneKit.h>
#import <SpriteKit/SpriteKit.h>
#import <ARKit/ARKit.h>
#import "Plane.h"

#define VideoNodeKey @"VideoNode"
@interface ARPlayerBanabaReturnViewController ()

@property (nonatomic, strong) ARSCNView *sceneView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSArray *banabaTextArray;
@property (nonatomic, strong) NSArray *banabaColorArray;
@property (nonatomic, strong) SCNNode *selectedNode;
@property (nonatomic, retain) NSMutableDictionary<NSUUID *, Plane *> *planes;
@property (nonatomic, strong) NSMutableArray *videoNodeArray;

@end

@implementation ARPlayerBanabaReturnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"AR弹幕（弹幕满世界飘）";
    
    [self setupScene];
    [self addGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self startSession];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.sceneView.session pause];
    [self.timer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
}

- (void)banabaMoveWithVideoNode:(NSTimer *)timerInfo {
    SCNNode *videoNode = [[timerInfo userInfo] objectForKey:VideoNodeKey];
    SCNNode *TVScreenNode = [videoNode childNodeWithName:@"Layer0_001" recursively:YES];
    [TVScreenNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(0, 0, 0)]];
    [TVScreenNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(0, 0, 0)]];
    [TVScreenNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(0, 0, 0)]];
    [TVScreenNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(0, 0, 0)]];
    [TVScreenNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(0, 0, 0)]];
    [TVScreenNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(0, 0, 0)]];
    [TVScreenNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(0, 0, 0)]];
    [TVScreenNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(0, 0, 0)]];
    [TVScreenNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(0, 0, 0)]];
    [TVScreenNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(0, 0, 0)]];
    [TVScreenNode addChildNode:[self banabaNodeWithText:[self banabaTextFromArray] vector3Make:SCNVector3Make(0, 0, 0)]];
}

- (NSString *)banabaTextFromArray {
    int index = arc4random() % self.banabaTextArray.count;
    return self.banabaTextArray[index];
}

- (UIColor *)banabaColorFromArray {
    int index = arc4random() % self.banabaColorArray.count;
    return self.banabaColorArray[index];
}

- (int)randomValue {
    BOOL temp = arc4random() % 2;
    int index = arc4random() % 50;
    
    if (temp) {
        return index;
    } else {
        return -index;
    }
}

- (SCNNode *)videoNode {
    SCNScene *TVScene = [SCNScene sceneNamed:@"art.scnassets/TVmodel.dae"];
    SCNNode *videoNode = TVScene.rootNode;
    
    SCNNode *TVScreenNode = [videoNode childNodeWithName:@"Layer0_001" recursively:YES];
    
    SCNNode *playerNode = [[SCNNode alloc] init];
    playerNode.geometry = [SCNBox boxWithWidth:840 height:485 length:0.01 chamferRadius:0];
    NSURL *videoURL1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"art.scnassets/video1" ofType:@"mp4"]];
    
    playerNode.geometry.materials = @[[self playerMaterialWithPlayAddress:videoURL1], [SCNMaterial new], [SCNMaterial new], [SCNMaterial new], [SCNMaterial new], [SCNMaterial new]];
    
    [TVScreenNode addChildNode:playerNode];
    playerNode.position = SCNVector3Make(0, -16.5, 35);
    playerNode.rotation = SCNVector4Make(1, 0 ,0 , M_PI / 2);
    videoNode.scale = SCNVector3Make(0.001, 0.001, 0.001);
    
    return videoNode;
}

- (SCNNode *)banabaNodeWithText:(NSString *)banabaStr vector3Make:(SCNVector3)vector3make {
    SCNText *banabaText = [SCNText textWithString:banabaStr extrusionDepth:3];
    banabaText.font = [UIFont systemFontOfSize:30];
    banabaText.firstMaterial.diffuse.contents = [self banabaColorFromArray];
    
    __block SCNNode *banabaNode = [SCNNode nodeWithGeometry:banabaText];
    banabaNode.geometry = banabaText;
    banabaNode.position = vector3make;
    banabaNode.rotation = SCNVector4Make(1, 0 ,0 , M_PI / 2);
    
    [banabaNode runAction:[SCNAction moveTo:SCNVector3Make([self randomValue] / 0.01, -5000, [self randomValue] / 0.01) duration:30] completionHandler:^{
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

#pragma mark - Add Gesture Recognizer

- (void)addGestureRecognizer {
    
    // Tap Gesture
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAddARSceneNodeFrom:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.sceneView addGestureRecognizer:tapGestureRecognizer];
    
    // Long Press Gesture
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleRemoveARSceneNodeFrom:)];
    longPressGestureRecognizer.minimumPressDuration = 0.5;
    [self.sceneView addGestureRecognizer:longPressGestureRecognizer];
    
    // Pan Press Gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMoveARSceneNodeFrom:)];
    [panGestureRecognizer setMaximumNumberOfTouches:1];
    [panGestureRecognizer setMinimumNumberOfTouches:1];
    [self.sceneView addGestureRecognizer:panGestureRecognizer];
    
    // Pinch Press Gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleScaleARSceneNodeFrom:)];
    [self.sceneView addGestureRecognizer:pinchGestureRecognizer];
}

#pragma mark - Handle Gesture Recognizer

- (void)handleAddARSceneNodeFrom: (UITapGestureRecognizer *)tapGestureRecognizer {
    
    CGPoint tapPoint = [tapGestureRecognizer locationInView:self.sceneView];
    NSArray<ARHitTestResult *> *result = [self.sceneView hitTest:tapPoint types:ARHitTestResultTypeExistingPlaneUsingExtent];
    
    if (result.count == 0) {
        return;
    }
    
    if (self.videoNodeArray.count) {
        return;
    }
    
    ARHitTestResult * hitResult = [result firstObject];
    [self insertGeometry:hitResult];
}

- (void)handleRemoveARSceneNodeFrom: (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    
    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint holdPoint = [longPressGestureRecognizer locationInView:self.sceneView];
    NSArray<SCNHitTestResult *> *result = [self.sceneView hitTest:holdPoint
                                                          options:@{SCNHitTestBoundingBoxOnlyKey: @YES, SCNHitTestFirstFoundOnlyKey: @YES}];
    if (result.count == 0) {
        return;
    }
    
    SCNHitTestResult * hitResult = [result firstObject];
    if (![hitResult.node.parentNode isKindOfClass:[Plane class]]) {
        [[hitResult.node parentNode] removeFromParentNode];
        [self.videoNodeArray removeAllObjects];
    }
}

-(void)handleMoveARSceneNodeFrom:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint tapPoint = [panGestureRecognizer locationInView:self.sceneView];
        NSArray <SCNHitTestResult *> *result = [self.sceneView hitTest:tapPoint options:nil];
        
        if ([result count] == 0) {
            return;
        }
        SCNHitTestResult *hitResult = [result firstObject];
        if (![hitResult.node.parentNode isKindOfClass:[Plane class]]) {
            self.selectedNode = [[hitResult node] parentNode];
        }
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (self.selectedNode) {
            CGPoint tapPoint = [panGestureRecognizer locationInView:self.sceneView];
            NSArray <ARHitTestResult *> *hitResults = [self.sceneView hitTest:tapPoint types:ARHitTestResultTypeFeaturePoint];
            ARHitTestResult *result = [hitResults lastObject];
            
            SCNMatrix4 matrix = SCNMatrix4FromMat4(result.worldTransform);
            SCNVector3 vector = SCNVector3Make(matrix.m41, matrix.m42, matrix.m43);
            [self.selectedNode setPosition:vector];
        }
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.selectedNode = nil;
    }
}

- (void)handleScaleARSceneNodeFrom: (UIPinchGestureRecognizer *)pinchGestureRecognizer {
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint tapPoint = [pinchGestureRecognizer locationOfTouch:1 inView:self.sceneView];
        NSArray <SCNHitTestResult *> *result = [self.sceneView hitTest:tapPoint options:nil];
        if ([result count] == 0) {
            tapPoint = [pinchGestureRecognizer locationOfTouch:0 inView:self.sceneView];
            result = [self.sceneView hitTest:tapPoint options:nil];
            if ([result count] == 0) {
                return;
            }
        }
        
        SCNHitTestResult *hitResult = [result firstObject];
        self.selectedNode = [[hitResult node] parentNode];
    }
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (self.selectedNode) {
            CGFloat pinchScaleX = pinchGestureRecognizer.scale * self.selectedNode.scale.x;
            CGFloat pinchScaleY = pinchGestureRecognizer.scale * self.selectedNode.scale.y;
            CGFloat pinchScaleZ = pinchGestureRecognizer.scale * self.selectedNode.scale.z;
            [self.selectedNode setScale:SCNVector3Make(pinchScaleX, pinchScaleY, pinchScaleZ)];
        }
        pinchGestureRecognizer.scale = 1;
    }
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.selectedNode = nil;
    }
}

#pragma mark - Additional Utils

- (void)insertGeometry:(ARHitTestResult *)hitResult {
    SCNNode *node = [self videoNode];
    float insertionYOffset = 0.01;
    node.position = SCNVector3Make(
                                   hitResult.worldTransform.columns[3].x,
                                   hitResult.worldTransform.columns[3].y + insertionYOffset,
                                   hitResult.worldTransform.columns[3].z
                                   );
    [self.videoNodeArray addObject:node];
    [self.sceneView.scene.rootNode addChildNode:node];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObject:node forKey:VideoNodeKey];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(banabaMoveWithVideoNode:) userInfo:dic repeats:YES];

}

#pragma mark - Configure SCNScene

- (void)setupSceneView {
    self.sceneView.delegate = (id)self;
    self.sceneView.autoenablesDefaultLighting = YES;
    self.sceneView.showsStatistics = YES;
}

- (void)setupScene {
    self.sceneView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    self.sceneView.delegate = (id)self;
    self.planes = [NSMutableDictionary new];
    self.banabaTextArray = [[NSArray alloc] initWithObjects:@"哎呦不错哦～～", @"是的呢!", @"啊哈哈哈～", @"解说胸好大哦～", @"男的略丑...", @"王者！", @"憋吵吵！", @"第一", @"牛逼！", @"作者牛逼不？！", nil];
    
    self.banabaColorArray = [[NSArray alloc] initWithObjects:[UIColor blackColor], [UIColor darkGrayColor], [UIColor lightGrayColor], [UIColor whiteColor], [UIColor grayColor], [UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], [UIColor yellowColor], [UIColor magentaColor], [UIColor orangeColor], [UIColor purpleColor], [UIColor brownColor], nil];
    self.videoNodeArray = [NSMutableArray new];
    
    self.sceneView.showsStatistics = YES;
    self.sceneView.autoenablesDefaultLighting = YES;
    self.sceneView.debugOptions = ARSCNDebugOptionShowFeaturePoints;
    
    self.sceneView.scene = [SCNScene new];
    [self.view addSubview:self.sceneView];
}

#pragma mark - Configure ARSession

- (void)startSession {
    
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    [self.sceneView.session runWithConfiguration:configuration];
}

- (void)refreshSession {
    
    for (NSUUID *planeId in self.planes) {
        [self.planes[planeId] remove];
    }
    for (SCNNode *cube in self.videoNodeArray) {
        [cube removeFromParentNode];
    }
    
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    [self.sceneView.session runWithConfiguration:configuration options:ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors];
}

#pragma mark - ARSCNViewDelegate

- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
        return;
    }
    
    Plane *plane = [[Plane alloc] initWithAnchor: (ARPlaneAnchor *)anchor];
    [self.planes setObject:plane forKey:anchor.identifier];
    [node addChildNode:plane];
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    Plane *plane = [self.planes objectForKey:anchor.identifier];
    if (plane == nil) {
        return;
    }
    [plane update:(ARPlaneAnchor *)anchor];
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    
    [self.planes removeObjectForKey:anchor.identifier];
}

- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
}

#pragma mark - ARSessionObserver

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
}

- (void)sessionWasInterrupted:(ARSession *)session {
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    [self refreshSession];
}


@end
