//
//  ViewController.m
//  MiChorus
//
//  Created by ADMIN on 2021/11/30.
//

#import "ViewController.h"
#import "FalseChrousVC.h"
#import "ChrousVC.h"

@interface ViewController ()
@property (nonatomic,strong) FalseChrousVC *falseChrousVC;
@property (nonatomic,strong) ChrousVC *chrousVC;

@end

@implementation ViewController

- (FalseChrousVC *)falseChrousVC
{
    if (!_falseChrousVC) {
        _falseChrousVC = [[FalseChrousVC alloc] initWithNibName:@"FalseChrousVC" bundle:nil];
    }
    return _falseChrousVC;
}

- (ChrousVC *)chrousVC
{
    if (!_chrousVC) {
        _chrousVC = [[ChrousVC alloc] initWithNibName:@"ChrousVC" bundle:nil];
    }
    return _chrousVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)onPressedBtnChorus:(id)sender {
    [self presentViewController:self.chrousVC animated:YES completion:nil];
}

- (IBAction)onPressedBtnFalseChorus:(id)sender {
    [self presentViewController:self.falseChrousVC animated:YES completion:nil];
}

@end
