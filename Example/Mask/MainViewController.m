//
//  MainViewController.m
//  Masks
//
//  Created by Harry on 2019/4/16.
//  Copyright © 2019年 Harry. All rights reserved.
//

#import "MainViewController.h"
#import "PhotoViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *Photo;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_Photo addTarget:self action:@selector(EnterPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    // Do any additional setup after loading the view from its nib.
}


-(void)EnterPhoto:(UIButton*)sender{
    PhotoViewController *pcv = [[PhotoViewController alloc] init];
    [self.navigationController presentViewController:pcv animated:YES completion:nil];
    
    //NSLog(@"click do Sth");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
