//
//  ARMainViewController.m
//  ARTest
//
//  Created by 迟人华 on 2017/9/25.
//  Copyright © 2017年 迟人华. All rights reserved.
//

#import "ARMainViewController.h"
#import "ARPlayerViewController.h"
#import "ARAnimationViewController.h"
#import "ARPlayerBanabaViewController.h"
#import "ARPlayerBanabaReturnViewController.h"
#import "ARPeopleViewController.h"

@interface ARMainViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *cellArr;

@end

@implementation ARMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Demo";
    
    self.cellArr = [[NSArray alloc] initWithObjects:@"AR播放器", @"AR动画", @"AR弹幕（视频在地上）", @"AR弹幕（弹幕满世界飘）", @"AR人物", nil];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 70;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    cell.textLabel.text = self.cellArr[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellArr.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            ARPlayerViewController *arPlayerVC = [ARPlayerViewController new];
            [self.navigationController pushViewController:arPlayerVC animated:YES];
        }
            
            break;
        case 1: {
            ARAnimationViewController *arAnimationVC = [ARAnimationViewController new];
            [self.navigationController pushViewController:arAnimationVC animated:YES];
        }
            
            break;
        case 2: {
            ARPlayerBanabaViewController *arBanabaVC = [ARPlayerBanabaViewController new];
            [self.navigationController pushViewController:arBanabaVC animated:YES];
        }
            break;
        case 3: {
            ARPlayerBanabaReturnViewController *arBanabaVC = [ARPlayerBanabaReturnViewController new];
            [self.navigationController pushViewController:arBanabaVC animated:YES];
        }
            break;
        case 4: {
            ARPeopleViewController *arPeopleVC = [ARPeopleViewController new];
            [self.navigationController pushViewController:arPeopleVC animated:YES];
        }
            break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

