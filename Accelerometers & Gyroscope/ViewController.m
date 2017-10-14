//
//  ViewController.m
//  Accelerometers&Gyroscope
//
//  Created by Kostya on 09.10.2017.
//  Copyright © 2017 SKS. All rights reserved.
//

#import "ViewController.h"
@import CoreMotion;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *staticButton;
@property (weak, nonatomic) IBOutlet UIButton *start;
@property (weak, nonatomic) IBOutlet UIButton *stop;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CMMotionManager *manager;
@property (assign, nonatomic) double x,y,z;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.staticLabel.text = @"no data";
    self.dynamicLabel.text = @"no data";
    self.staticButton.enabled = NO;
    self.start.enabled = NO;
    self.stop.enabled = NO;

    
    self.x = 0.0;
    self.y = 0.0;
    self.z = 0.0;
    
    self.manager = [[CMMotionManager alloc]init];
    if(self.manager.accelerometerAvailable)
    {
        self.staticButton.enabled = YES;
        self.start.enabled = YES;
        [self.manager startAccelerometerUpdates];
    }
    else
    {
        self.staticLabel.text = @"NO AccelerometerAvailable";
        self.dynamicLabel.text = @"NO AccelerometerAvailable";
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(react) name:UIScreenBrightnessDidChangeNotification object:nil];
    
}

- (IBAction)staticRequest:(id)sender
{
    CMAccelerometerData *aData = self.manager.accelerometerData;
    if(aData != nil)
    {
        CMAcceleration acceleration = aData.acceleration;
        self.staticLabel.text = [NSString stringWithFormat:@"x:%f\ny:%f\nz:%f",acceleration.x,acceleration.y,acceleration.z];
    }
}
- (IBAction)startDynamicCallBacs:(id)sender
{
    self.stop.enabled = YES;
    self.start.enabled = NO;
    
    self.manager.accelerometerUpdateInterval = 0.01;
    
    ViewController * __weak weakSelf = self; //break the loop in ios
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [self.manager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        double x = accelerometerData.acceleration.x;
        double y = accelerometerData.acceleration.y;
        double z = accelerometerData.acceleration.z;
        
        self.x = .9 * self.x +.1 * x;
        self.y = .9 * self.y +.1 * y;
        self.z = .9 * self.z +.1 * z;
        
        double rotation = -atan2(self.x,-self.y);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            weakSelf.imageView.transform = CGAffineTransformMakeRotation(rotation);
            weakSelf.dynamicLabel.text = [NSString stringWithFormat:@"x:%f\ny:%f\nz:%f",x,y,z];
            if(y<0)
            {
                self.imageView.alpha = 1.0;
            }
            else
            {
                self.imageView.alpha = 0.2;
            }
        }];
        
    }];
}

- (IBAction)stopDynamicCallbacks:(id)sender
{
    [self.manager stopAccelerometerUpdates];
    self.stop.enabled = NO;
    self.start.enabled = YES;
}

- (void)react
{
    double brightness = [[UIScreen mainScreen]brightness];
    self.imageView.alpha = brightness;
}
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
