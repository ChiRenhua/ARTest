//
//  ARPeopleViewController.m
//  ARTest
//
//  Created by Renhuachi on 2017/10/27.
//  Copyright © 2017年 迟人华. All rights reserved.
//

#import "ARPeopleViewController.h"
#import <SceneKit/SceneKit.h>
#import <SpriteKit/SpriteKit.h>
#import <ARKit/ARKit.h>
#import "Plane.h"
#import "ARCharacterNode.h"

@interface ARPeopleViewController ()
@property (nonatomic, strong) ARSCNView *arSceneView;
@property (nonatomic, retain) NSMutableDictionary<NSUUID *, Plane *> *planes;
@property (nonatomic, strong) ARCharacterNode *selectedNode;
@property (nonatomic, strong) NSMutableArray *characterArray;

@property (nonatomic,assign) CGFloat lastPtx;
@property (nonatomic,assign) CGFloat curPtx;
@property (nonatomic,assign) CGFloat curAngle;
@end

@implementation ARPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"AR人物";
    self.navigationController.navigationBarHidden = YES;
    [self setupScene];
    [self setupButtons];
    [self addGestureRecognizer];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startSession];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.arSceneView.session pause];
}

- (void)setupScene {
    self.arSceneView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    self.arSceneView.delegate = (id)self;
    self.planes = [NSMutableDictionary new];
    self.characterArray = [NSMutableArray new];
    
    //    self.arSceneView.showsStatistics = YES;
    self.arSceneView.autoenablesDefaultLighting = YES;
    //    self.arSceneView.debugOptions = ARSCNDebugOptionShowFeaturePoints;
    
    self.arSceneView.scene = [SCNScene new];
    [self.view addSubview:self.arSceneView];
}

- (void)setupButtons {
    //    CGRect bounds = [UIScreen mainScreen].bounds;
    //    UIButton *moveForward = [[UIButton alloc] initWithFrame:CGRectMake(bounds.size.width/4-60, bounds.size.height - 100, 120, 100)];
    //    [moveForward setTitle:@"前进" forState:UIControlStateNormal];
    //    [moveForward addTarget:self action:@selector(runForwardAction) forControlEvents:UIControlEventTouchUpInside];
    //
    //    UIButton *moveBack = [[UIButton alloc] initWithFrame:CGRectMake(bounds.size.width/4*3-60, bounds.size.height - 100, 120, 100)];
    //    [moveBack setTitle:@"后退" forState:UIControlStateNormal];
    //    [moveBack addTarget:self action:@selector(runBackAction) forControlEvents:UIControlEventTouchUpInside];
    //
    //    UIButton *stop = [[UIButton alloc] initWithFrame:CGRectMake(bounds.size.width/4*2-60, bounds.size.height - 100, 120, 100)];
    //    [stop setTitle:@"停！" forState:UIControlStateNormal];
    //    [stop addTarget:self action:@selector(stopRun) forControlEvents:UIControlEventTouchUpInside];
    //
    //    [self.arSceneView addSubview:moveForward];
    //    [self.arSceneView addSubview:moveBack];
    //    [self.arSceneView addSubview:stop];
    
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(10, 32, 70, 25)];
    [back setTitle:@"🔙返回" forState:UIControlStateNormal];
    back.titleLabel.textAlignment = NSTextAlignmentLeft;
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.arSceneView addSubview:back];
}

- (void)runForwardAction {
    ARCharacterNode *node = [self.characterArray firstObject];
    [node doRunActionWithDirection:ARCharacterDirection_Forward];
}

- (void)runBackAction {
    ARCharacterNode *node = [self.characterArray firstObject];
    [node doRunActionWithDirection:ARCharacterDirection_Back];
}

- (void)stopRun {
    ARCharacterNode *node = [self.characterArray firstObject];
    [node stopRunAction];
}

- (void)goBack {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Add Gesture Recognizer
- (void)addGestureRecognizer {
    
    // Tap Gesture
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAddARSceneNodeFrom:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.arSceneView addGestureRecognizer:tapGestureRecognizer];
    
    // Long Press Gesture
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleRemoveARSceneNodeFrom:)];
    longPressGestureRecognizer.minimumPressDuration = 0.5;
    [self.arSceneView addGestureRecognizer:longPressGestureRecognizer];
    
    // Pan Press Gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMoveARSceneNodeFrom:)];
    [panGestureRecognizer setMaximumNumberOfTouches:1];
    [panGestureRecognizer setMinimumNumberOfTouches:1];
    [self.arSceneView addGestureRecognizer:panGestureRecognizer];
    
    // Pinch Press Gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleScaleARSceneNodeFrom:)];
    [self.arSceneView addGestureRecognizer:pinchGestureRecognizer];
}

#pragma mark - Handle Gesture Recognizer

- (void)handleAddARSceneNodeFrom: (UITapGestureRecognizer *)tapGestureRecognizer {
    
    if (self.characterArray.count) {
        return;
    }
    
    CGPoint tapPoint = [tapGestureRecognizer locationInView:self.arSceneView];
    NSArray<ARHitTestResult *> *result = [self.arSceneView hitTest:tapPoint types:ARHitTestResultTypeExistingPlaneUsingExtent];
    
    if (!self.selectedNode) {
        self.selectedNode = [[ARCharacterNode alloc] init];
    }
    
    if (result.count == 0) {
        [self.selectedNode loadData];
        self.selectedNode.scale = SCNVector3Make(0.009, 0.009, 0.009);
        self.selectedNode.position = SCNVector3Make(0, -1, -2);
        [self.characterArray addObject:self.selectedNode];
        [self.arSceneView.scene.rootNode addChildNode:self.selectedNode];
        
        return;
    }
    
    
    
    ARHitTestResult * hitResult = [result firstObject];
    [self insertGeometry:hitResult];
}

- (void)handleRemoveARSceneNodeFrom: (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    
    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint holdPoint = [longPressGestureRecognizer locationInView:self.arSceneView];
    NSArray<SCNHitTestResult *> *result = [self.arSceneView hitTest:holdPoint
                                                            options:@{SCNHitTestBoundingBoxOnlyKey: @YES, SCNHitTestFirstFoundOnlyKey: @YES}];
    if (result.count == 0) {
        return;
    }
    
    SCNHitTestResult * hitResult = [result firstObject];
    if (![hitResult.node.parentNode isKindOfClass:[Plane class]]) {
        [[hitResult.node parentNode] removeFromParentNode];
        [self.characterArray removeAllObjects];
    }
}

-(void)handleMoveARSceneNodeFrom:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint pt = [panGestureRecognizer locationInView:self.arSceneView];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint tapPoint = [panGestureRecognizer locationInView:self.arSceneView];
        NSArray <SCNHitTestResult *> *result = [self.arSceneView hitTest:tapPoint options:nil];
        
        if ([result count] == 0) {
            return;
        }
        
        self.lastPtx = self.curPtx = pt.x;
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (self.selectedNode) {
            self.curPtx = pt.x;
            
            CGFloat offsetX = self.curPtx - self.lastPtx;
            CGFloat angle = offsetX / [UIScreen mainScreen].bounds.size.width * M_PI;
            
            angle += self.curAngle;
            NSLog(@"angle = %f",angle);
            self.selectedNode.rotation = SCNVector4Make(0, 1, 0, angle);
        }
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.selectedNode) {
            self.curAngle = self.selectedNode.rotation.w;
        }
    }
}

- (void)handleScaleARSceneNodeFrom: (UIPinchGestureRecognizer *)pinchGestureRecognizer {
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint tapPoint = [pinchGestureRecognizer locationOfTouch:1 inView:self.arSceneView];
        NSArray <SCNHitTestResult *> *result = [self.arSceneView hitTest:tapPoint options:nil];
        if ([result count] == 0) {
            tapPoint = [pinchGestureRecognizer locationOfTouch:0 inView:self.arSceneView];
            result = [self.arSceneView hitTest:tapPoint options:nil];
            if ([result count] == 0) {
                return;
            }
        }
    }
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (self.selectedNode) {
            CGFloat pinchScaleX = pinchGestureRecognizer.scale * self.selectedNode.scale.x;
            CGFloat pinchScaleY = pinchGestureRecognizer.scale * self.selectedNode.scale.y;
            CGFloat pinchScaleZ = pinchGestureRecognizer.scale * self.selectedNode.scale.z;
            [self.selectedNode setScale:SCNVector3Make(pinchScaleX, pinchScaleY, pinchScaleZ)];
            
            CGPoint tapPoint = [pinchGestureRecognizer locationInView:self.arSceneView];
            NSArray <ARHitTestResult *> *hitResults = [self.arSceneView hitTest:tapPoint types:ARHitTestResultTypeFeaturePoint];
            ARHitTestResult *result = [hitResults lastObject];
            
            SCNMatrix4 matrix = SCNMatrix4FromMat4(result.worldTransform);
            SCNVector3 vector = SCNVector3Make(matrix.m41, matrix.m42, matrix.m43);
            [self.selectedNode setPosition:vector];
        }
        pinchGestureRecognizer.scale = 1;
    }
}

#pragma mark - Additional Utils
- (void)insertGeometry:(ARHitTestResult *)hitResult {
    if (!self.selectedNode) {
        self.selectedNode = [[ARCharacterNode alloc] init];
    }
    [self.selectedNode loadData];
    self.selectedNode.scale = SCNVector3Make(0.009, 0.009, 0.009);
    self.selectedNode.position = SCNVector3Make(
                                                hitResult.worldTransform.columns[3].x,
                                                hitResult.worldTransform.columns[3].y,
                                                hitResult.worldTransform.columns[3].z
                                                );
    [self.characterArray addObject:self.selectedNode];
    [self.arSceneView.scene.rootNode addChildNode:self.selectedNode];
}

#pragma mark - Configure ARSession

- (void)startSession {
    
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    [self.arSceneView.session runWithConfiguration:configuration];
}

- (void)refreshSession {
    
    for (NSUUID *planeId in self.planes) {
        [self.planes[planeId] remove];
    }
    for (SCNNode *cube in self.characterArray) {
        [cube removeFromParentNode];
    }
    
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    [self.arSceneView.session runWithConfiguration:configuration options:ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors];
}

#pragma mark - ARSCNViewDelegate

- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
        return;
    }
    
    //    Plane *plane = [[Plane alloc] initWithAnchor: (ARPlaneAnchor *)anchor];
    //    [self.planes setObject:plane forKey:anchor.identifier];
    //    [node addChildNode:plane];
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    //    Plane *plane = [self.planes objectForKey:anchor.identifier];
    //    if (plane == nil) {
    //        return;
    //    }
    //    [plane update:(ARPlaneAnchor *)anchor];
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    
    //    [self.planes removeObjectForKey:anchor.identifier];
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

#pragma mark - Others methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

