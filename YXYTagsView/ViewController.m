//
//  ViewController.m
//  YXYTagsView
//
//  Created by talkweb on 03/11/2016.
//  Copyright © 2016 EAH. All rights reserved.
//

#import "ViewController.h"
#import "YXYTagsView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet YXYTagsView *tagsView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initTags];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initTags {
    
    NSMutableArray *tags = [NSMutableArray array];
    
    for (int i = 0; i < 29; i ++) {
        YXYTagModel *tag = [[YXYTagModel alloc] init];
        tag.title = [NSString stringWithFormat:@"标签%d",i];;
        tag.selectedBackImage = [UIImage imageNamed:@"btn_bg"];
        if(i % 2) {
            tag.defaultSelected = YES;
        }
        [tags addObject:tag];
    }
    
    self.tagsView.didSelected = ^(YXYTagButton *sender) {
        NSLog(@"%@", [NSString stringWithFormat:@"select %@",sender.data.title]);
    };
    
    self.tagsView.desSelected = ^(YXYTagButton *sender) {
        NSLog(@"%@", [NSString stringWithFormat:@"deselect %@",sender.data.title]);
    };
    
    [self.tagsView refreshWithTags:tags unflodStatus:NO];
}

- (IBAction)segAction:(UISegmentedControl *)sender {
    if(sender.selectedSegmentIndex == 0) {
        self.tagsView.minDisplayLines = 1;
        self.tagsView.allowMutiSelected = NO;
        [self initTags];
    }
    else if(sender.selectedSegmentIndex == 1) {
        self.tagsView.minDisplayLines = 2;
        self.tagsView.allowMutiSelected = YES;
        [self initTags];
    }
}

@end
