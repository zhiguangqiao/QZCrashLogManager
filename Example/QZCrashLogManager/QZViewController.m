//
//  QZViewController.m
//  QZCrashLogManager
//
//  Created by qiaozhiguang on 12/31/2015.
//  Copyright (c) 2015 qiaozhiguang. All rights reserved.
//

#import "QZViewController.h"
#import "QZCrashLogManager.h"
@interface QZViewController ()

@end

@implementation QZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)crash:(id)sender {
    [[NSArray array]objectAtIndex:0];
}

- (IBAction)showLog:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Log" message:[[QZCrashLogManager getCrashLog] description] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
