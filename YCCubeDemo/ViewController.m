//
//  ViewController.m
//  YCCubeDemo
//
//  Created by Daniel on 2019/8/20.
//  Copyright © 2019 OYC. All rights reserved.
//

#import "ViewController.h"
#import "DHVector.h"

// 手指的最大位移量和当手指达到最大位移量时对应的旋转角度，用来插值计算每次手指移动应该旋转多少度
static const CGFloat maxTranslate_ = 100.f;
static const CGFloat maxRotateRadian_   =   M_PI * 2;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) CATransformLayer *cubeLayer;

// 上次的向量
@property (nonatomic) DHVector *lastTranslation;

@end

@implementation ViewController

- (CALayer *)faceWithTransform:(CATransform3D)transform {
    
    CALayer *layer = [CALayer layer];
    layer.frame = self.containerView.bounds;
    
    layer.transform = transform;
    
    CGFloat red = arc4random() % 255;
    CGFloat green = arc4random() % 255;
    CGFloat blue = arc4random() % 255;
    
    layer.backgroundColor = [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0].CGColor;
    
    return layer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat cubeW = self.containerView.frame.size.width;
    
    CATransform3D sublayerTransform = CATransform3DIdentity;
    sublayerTransform.m34 = -1.0 / 500.0;
    self.containerView.layer.sublayerTransform = sublayerTransform;
    
    // 盒子
    self.cubeLayer = [CATransformLayer layer];
    self.cubeLayer.frame = self.containerView.bounds;
    [self.containerView.layer addSublayer:self.cubeLayer];
    
    // face1
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DMakeTranslation(0, 0, cubeW / 2);
    [self.cubeLayer addSublayer:[self faceWithTransform:transform]];
    
    // face2
    transform = CATransform3DMakeTranslation(-cubeW / 2, 0, 0);
    transform = CATransform3DRotate(transform, -M_PI_2, 0, 1, 0);
    [self.cubeLayer addSublayer:[self faceWithTransform:transform]];
    
    // face3
    transform = CATransform3DMakeTranslation(0, -cubeW / 2, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 1, 0, 0);
    [self.cubeLayer addSublayer:[self faceWithTransform:transform]];
    
    // face4
    transform = CATransform3DMakeTranslation(0, cubeW / 2, 0);
    transform = CATransform3DRotate(transform, -M_PI_2, 1, 0, 0);
    [self.cubeLayer addSublayer:[self faceWithTransform:transform]];
    
    // face5
    transform = CATransform3DMakeTranslation(cubeW / 2, 0, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
    [self.cubeLayer addSublayer:[self faceWithTransform:transform]];
    
    // face6
    transform = CATransform3DMakeTranslation(0, 0, -cubeW / 2);
    [self.cubeLayer addSublayer:[self faceWithTransform:transform]];
    
    transform = CATransform3DMakeRotation(-M_PI_4, 0, 1, 0);
    transform = CATransform3DRotate(transform, -M_PI_4, 1, 0, 0);
    self.cubeLayer.transform = transform;
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    
    CGPoint panTranslation = [sender translationInView:self.view];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
    
        self.lastTranslation = [[DHVector alloc] initWithCoordinateExpression:panTranslation];
        
    }else if (sender.state == UIGestureRecognizerStateChanged) {
        
        // 通过这个位移生成一个向量，这就是我们当前的位移向量。
        DHVector *vector = [[DHVector alloc] initWithCoordinateExpression:panTranslation];
        
        // 用当前的位移向量-上次的位移向量得到我们手指的位移偏移量
        DHVector *translateVector = [DHVector aVector:vector substractedByOtherVector:self.lastTranslation];
        
        // 把这个向量保存起来，下次调用这个方法的时候需要拿到这次的向量，用来做减法
        // 下次再调用这个方法的时候的lastTranslation就是这次的位移向量，所以用这次的位移向量覆盖掉lastTranslation（用这次的位移向量给lastTranslation赋值）
        self.lastTranslation = vector;
        
        // 生成旋转向量，也就是要传给CATransform3DRotate函数的向量，它通过translateVector顺时针旋转90度（PI/2）得到
        DHVector *rotateVector = [DHVector vectorWithVector:translateVector];
//        [rotateVector rotateClockwiselyWithRadian:M_PI/2];
        
        CGFloat radianX = -rotateVector.coordinateExpression.y / maxTranslate_ * maxRotateRadian_;
        CGFloat radianY = rotateVector.coordinateExpression.x / maxTranslate_ * maxRotateRadian_;
        
        self.cubeLayer.transform = CATransform3DRotate(self.cubeLayer.transform, radianX, 1, 0, 0);
        self.cubeLayer.transform = CATransform3DRotate(self.cubeLayer.transform, radianY, 0, 1, 0);
    }else if (sender.state == UIGestureRecognizerStateEnded) {
        
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DMakeRotation(-M_PI_4, 0, 1, 0);
        transform = CATransform3DRotate(transform, -M_PI_4, 1, 0, 0);
        self.cubeLayer.transform = transform;
    }
}
@end
