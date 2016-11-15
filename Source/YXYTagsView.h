//
//  YXYTagsView.h
//  Yunxiaoyuan
//
//  Created by EA on 02/11/2016.
//  Copyright © 2016 Talkweb. All rights reserved.
//

#import <UIKit/UIKit.h>

//------------------YXYTagModel------------------
@interface YXYTagModel : NSObject

//展示的标题
@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *selectedTitle;
//数据源
@property (nonatomic, strong) id data;

//未选中状态标题颜色
@property (nonatomic, strong) UIColor *normalTitleColor;
//未选中状态标题颜色
@property (nonatomic, strong) UIColor *selectedTitleColor;

//未选中状态背景图
@property (nonatomic, strong) UIImage *normalBackImage;

//选中状态背景图
@property (nonatomic, strong) UIImage *selectedBackImage;

//选中状态背景图
@property (nonatomic, strong) UIImage *highlightedBackImage;

//button的image
@property (nonatomic, strong) UIImage *image;


@property (nonatomic, assign) UIEdgeInsets titleEdgeInsets;

@property (nonatomic, strong) UIFont *titleFont;

//默认是否选中
@property (nonatomic, assign) BOOL defaultSelected;

@end


//------------------YXYTagButton------------------
@interface YXYTagButton : UIButton

@property (nonatomic, strong) YXYTagModel *data;

@end

//------------------YXYTagsView------------------
@interface YXYTagsView : UIView

//是否展开
@property (nonatomic, assign) BOOL isUnfolded;

//选中后的回调
@property (nonatomic, copy) void (^didSelected) (YXYTagButton* sender);

//取消选中后的回调
@property (nonatomic, copy) void (^desSelected) (YXYTagButton* sender);

//最少展示的行数,默认是1行
@property (nonatomic, assign) NSUInteger minDisplayLines;

//tag之间的最小距离
@property (nonatomic, assign) NSUInteger minSpacing;

//展开/收起按钮的数据
@property (nonatomic, strong) YXYTagModel *unflodBtnModel;

//是否允许多选
@property (nonatomic, assign) BOOL allowMutiSelected;

//展开/收起后通知外部size的变化
@property (nonatomic, copy) void (^needChangToFrame)(CGRect frame);

//初始化方法
- (instancetype)initWithTags:(NSArray<YXYTagModel *> *)tags withUnflodBtnModel:(YXYTagModel *)unflodBtnModel withMinDisplayLine:(NSUInteger)lines;

//根据不一样的tags数据源刷新UI
- (void)refreshWithTags:(NSArray<YXYTagModel *> *)tags unflodStatus:(BOOL)isUnfloded;

@end
