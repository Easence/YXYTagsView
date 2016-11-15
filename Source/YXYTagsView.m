//
//  YXYTagsView.m
//  Yunxiaoyuan
//
//  Created by EA on 02/11/2016.
//  Copyright © 2016 Talkweb. All rights reserved.
//

#import "YXYTagsView.h"

//------------------YXYTagModel------------------

@interface YXYTagModel ()

@property (nonatomic, assign) BOOL alreadyDoDefault;

@end

@implementation YXYTagModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.titleEdgeInsets = UIEdgeInsetsMake(1, 15, 1, 15);
        self.selectedTitleColor = [UIColor whiteColor];
        self.normalTitleColor = [UIColor colorWithRed:0.1779 green:0.7011 blue:0.1934 alpha:1.0];
        self.titleFont = [UIFont systemFontOfSize:13];
    }
    return self;
}

@end


//------------------YXYTagButton------------------

@implementation YXYTagButton

- (void) setData:(YXYTagModel *)data {
    
    //如果布局过，并且数据源没有发生改变，则直接返回
    if(self.bounds.size.width > 0 && [data isEqual:_data]) {
        return;
    }
    
    _data = data;

    //设置标题颜色
    [self setTitleColor:data.normalTitleColor forState:UIControlStateNormal];
    [self setTitleColor:data.selectedTitleColor ? data.selectedTitleColor : data.normalTitleColor forState:UIControlStateSelected];
    
    //设置背景图
    [self setBackgroundImage:data.normalBackImage forState:UIControlStateNormal];
    [self setBackgroundImage:data.selectedBackImage forState:UIControlStateSelected];
    [self setBackgroundImage:data.highlightedBackImage forState:UIControlStateHighlighted];
    
    self.titleLabel.font = data.titleFont;//[UIFont systemFontOfSize:12];
    
    [self setTitle:data.title forState:UIControlStateNormal];
    
    [self setTitle:data.selectedTitle ? data.selectedTitle : data.title forState:UIControlStateSelected];
    
    [self sizeToFit];
    
    CGRect bounds = self.bounds;
    
    bounds.size.width += (data.titleEdgeInsets.left + data.titleEdgeInsets.right);
    bounds.size.height += (data.titleEdgeInsets.top + data.titleEdgeInsets.bottom);

    self.bounds = bounds;
    
    self.layer.cornerRadius = CGRectGetHeight(self.bounds) / 2;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = data.normalTitleColor.CGColor;

    
}

@end

//------------------YXYTagsView------------------

@interface YXYTagsView ()

@property (nonatomic, strong) NSArray<YXYTagModel *> *tags;
@property (nonatomic, strong) NSMutableArray<YXYTagButton *> *tagBtns;

//展开、收起按钮
@property (nonatomic, strong) UIButton* unfoldBtn;

//允许展示行数
@property (nonatomic, assign) NSUInteger displayLines;

@end

@implementation YXYTagsView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initData];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)initData {
    self.tagBtns = [NSMutableArray array];
    self.tags = [NSMutableArray array];
    
    self.minDisplayLines = 1;
    self.minSpacing = 10;

    self.unfoldBtn = [UIButton buttonWithType:UIButtonTypeCustom];
}

- (instancetype)initWithTags:(NSArray<YXYTagModel *> *)tags withUnflodBtnModel:(YXYTagModel *)unflodBtnModel withMinDisplayLine:(NSUInteger)lines {
    
    self = [super init];
    
    if(self) {
        self.tags = tags;
        self.unflodBtnModel = unflodBtnModel;
        [self relayoutTagBtns];
    }
    return self;
}

//根据数据刷新UI
- (void)refreshWithTags:(NSArray<YXYTagModel *> *)tags unflodStatus:(BOOL)isUnfloded {
    self.tags = tags;
    self.isUnfolded = isUnfloded;
    //先将原先的tag button全部移除
    [self.tagBtns enumerateObjectsUsingBlock:^(YXYTagButton * tagBtn, NSUInteger idx, BOOL * _Nonnull stop) {
        [tagBtn removeFromSuperview];
    }];
    
    [self.tagBtns removeAllObjects];
    
    if(tags.count <= 0) {
        return;
    }
    
    [self relayoutTagBtns];
}


//重新布局所有的标签按钮
- (void)relayoutTagBtns {

    NSInteger needAddBtnCount = self.tags.count - self.tagBtns.count;
    
    //需要添加button
    if(needAddBtnCount > 0) {
        
        for (NSInteger i = 0; i < needAddBtnCount; i ++) {
            
            YXYTagButton *button = [YXYTagButton buttonWithType:UIButtonTypeCustom];
            [self.tagBtns addObject:button];
        }
        
    } else {
        //需要移除多余button
        [self.tagBtns removeObjectsInRange:NSMakeRange(self.tags.count, -needAddBtnCount)];
    }
    
    //设置收起/展开按钮的状态
    [self setUnflodBtnWithStatus:self.isUnfolded];
    
    CGFloat lineWidth = self.minSpacing;
    NSUInteger lineNum = 1;

    //布局的最后一个tag的索引
    NSInteger lastLayoutIndex = 0;
    
    for (NSInteger i = 0; i < self.tags.count; i ++) {
        
        YXYTagButton *button = self.tagBtns[i];

        [button setData:self.tags[i]];
        
        //如果默认选中
        if(self.tags[i].defaultSelected && !self.tags[i].alreadyDoDefault) {
            self.tags[i].alreadyDoDefault = YES;
            if(!button.isSelected) {
                [self tagBtnAction:button];
            }
        }
        
        CGFloat buttonWidth = ceilf(CGRectGetWidth(button.bounds));
        
        //如果按钮的宽度大于（YXYTagsView自身的宽度+两倍边距），则设置合适的宽度
        if(buttonWidth >= CGRectGetWidth(self.bounds)) {
            buttonWidth = ceilf(CGRectGetWidth(self.bounds) - self.minSpacing * 2);
        }
        
        //设置button的frame
        CGRect btnFrame = button.frame;
        btnFrame.origin.x = ceilf(lineWidth);
        btnFrame.origin.y = ceilf(lineNum * self.minSpacing + (lineNum - 1) * CGRectGetHeight(button.bounds));
        btnFrame.size.width = ceilf(buttonWidth);
        
        button.frame = btnFrame;
        
        //所有tag的总长度
        lineWidth += buttonWidth;
        //末尾边距
        lineWidth += self.minSpacing;
        
        //如果button没有添加进来，则添加一次
        if(!button.superview) {
            [button removeTarget:self action:@selector(tagBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(tagBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
        
        NSInteger curLayoutIndex = i;
        BOOL hasLayoutUnflodBtn = NO;
        
        lastLayoutIndex = i;

        //如果允许展示行数的tag已经超过了自身的宽度
        if(lineWidth > CGRectGetWidth(self.bounds)) {
            
            //如果大于等于最小展示行数
            if(lineNum >= self.displayLines) {
                
                while (lineWidth >= CGRectGetWidth(self.bounds)) {
                    
                    //如果是只有一个，则直接返回
                    if(lastLayoutIndex <= 0) {
                        break;
                    }
                    
                    YXYTagButton *btn = self.tagBtns[curLayoutIndex];
                    
                    //移除最后一个button
                    [btn removeFromSuperview];
                    
                    lineWidth -= ceilf((CGRectGetWidth(btn.bounds) + self.minSpacing));
                    
                    if(!hasLayoutUnflodBtn) {
                        //加上展开按钮的宽度
                        lineWidth += ceilf(CGRectGetWidth(self.unfoldBtn.bounds) + self.minSpacing);
                    }
                    
                    hasLayoutUnflodBtn = YES;
                    curLayoutIndex--;
                    
                    lastLayoutIndex = curLayoutIndex;
                    
                }
                
                break;
                
            }
            else {
                lineWidth = self.minSpacing;
                lineNum ++;
                i--;
            }
        }
    }
    
    //将多余的tags从父view移除
    for (NSInteger i = lastLayoutIndex + 1; i < self.tagBtns.count; i ++) {
        [self.tagBtns[i] removeFromSuperview];
    }
    
    //如果是收起状态，并且全部按钮都展示出来了，则不需要布局展开按钮
    if(!self.isUnfolded && lastLayoutIndex == self.tagBtns.count - 1) {
        if(self.unfoldBtn.superview) {
            [self.unfoldBtn removeFromSuperview];
        }
    }
    else {
        //布局展开/收起按钮
        YXYTagButton *lastTagBtn = self.tagBtns[lastLayoutIndex];
        CGRect unfoldBtnRect = CGRectMake(CGRectGetWidth(self.frame) - self.minSpacing - CGRectGetWidth(self.unfoldBtn.frame), CGRectGetMinY(lastTagBtn.frame), CGRectGetWidth(self.unfoldBtn.frame), CGRectGetHeight(lastTagBtn.frame));
        
        //如果tag的最后一行无法放下布局展开/收起按钮，则另起一行
        if(CGRectGetMaxX(lastTagBtn.frame) + CGRectGetWidth(self.unfoldBtn.bounds) + self.minSpacing * 2 > CGRectGetWidth(self.bounds)) {
            unfoldBtnRect.origin.y += CGRectGetMaxY(lastTagBtn.bounds) + self.minSpacing;
        }
        
        self.unfoldBtn.frame = unfoldBtnRect;
        
        //如果没有把展开/收起按钮添加进来，则添加进来
        if(!self.unfoldBtn.superview) {
            [self addSubview:self.unfoldBtn];
        }
    }

    //计算总高度
    CGRect selfFrame = self.frame;
    selfFrame.size.height = CGRectGetMaxY(self.unfoldBtn.frame) + self.minSpacing;
    self.frame = selfFrame;
    
    if(self.needChangToFrame) {
        self.needChangToFrame(self.frame);
    }
}

//tag按钮的事件
- (void)tagBtnAction:(YXYTagButton *)tagBtn {
    
    //如果是单选，并且已经选择，则直接返回
    if(tagBtn.selected && !self.allowMutiSelected) return;
    
    tagBtn.selected = !tagBtn.selected;
    
    //如果只允许单选
    if(!self.allowMutiSelected) {
        //反选其他的按钮
        for (YXYTagButton *otherBtn in self.tagBtns) {
            
            if(![otherBtn isEqual:tagBtn]) {
                //给上一个选中按钮，发送反选事件
                if(otherBtn.isSelected && self.desSelected) {
                    self.desSelected(otherBtn);
                }
                
                otherBtn.selected = !tagBtn;
            }
        }
    }
    
    //给选中按钮，发送选中事件
    if(self.didSelected && tagBtn.selected) {
        self.didSelected(tagBtn);
    }
    else if(!tagBtn.isSelected && self.desSelected) {
        self.desSelected(tagBtn);
    }
}

//收起展开按钮的事件
- (void)unflodAction:(UIButton *)sender {
    
    self.isUnfolded = !self.isUnfolded;
    [self relayoutTagBtns];
}

//设置展开按钮的状态
- (void) setUnflodBtnWithStatus:(BOOL)isUnfolded {
    
    if(!self.unfoldBtn.superview) {
        [self addSubview:self.unfoldBtn];
        [self.unfoldBtn removeTarget:self action:@selector(unflodAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.unfoldBtn addTarget:self action:@selector(unflodAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSString *title = self.unflodBtnModel.title ? self.unflodBtnModel.title : @"更多标签";
    UIImage *image = [UIImage imageNamed:@"ico_tag_down"];
    
    self.displayLines = self.minDisplayLines;
    
    if(isUnfolded) {
        title = self.unflodBtnModel.selectedTitle ? self.unflodBtnModel.selectedTitle :  @"收起";
        image = [UIImage imageNamed:@"ico_tag_up"];
        self.displayLines = UINT_MAX;
    }
    
    self.unfoldBtn.contentEdgeInsets = UIEdgeInsetsZero;
    self.unfoldBtn.titleEdgeInsets = UIEdgeInsetsZero;
    self.unfoldBtn.imageEdgeInsets = UIEdgeInsetsZero;
    self.unfoldBtn.bounds = CGRectZero;
    
    //设置标题颜色
    [self.unfoldBtn setTitleColor:self.unflodBtnModel.normalTitleColor ? self.unflodBtnModel.normalTitleColor : [UIColor colorWithRed:0.1779 green:0.7011 blue:0.1934 alpha:1.0] forState:UIControlStateNormal];
    
    self.unfoldBtn.titleLabel.font = self.unflodBtnModel.titleFont ? self.unflodBtnModel.titleFont : [UIFont systemFontOfSize:13];
    
    [self.unfoldBtn setTitle:title forState:UIControlStateNormal];
    
    [self.unfoldBtn setBackgroundImage:self.unflodBtnModel.normalBackImage forState:UIControlStateNormal];
    [self.unfoldBtn setBackgroundImage:self.unflodBtnModel.selectedBackImage forState:UIControlStateSelected];
    [self.unfoldBtn setBackgroundImage:self.unflodBtnModel.highlightedBackImage forState:UIControlStateHighlighted];
    
    [self.unfoldBtn sizeToFit];
   
    CGRect titleRect = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.unfoldBtn.titleLabel.font} context:nil];
    
    
    CGFloat titleWidth = ceilf(titleRect.size.width);
    CGFloat titleHeight = ceilf(titleRect.size.height);
    
    //设置背景图
    [self.unfoldBtn setImage:image forState:UIControlStateNormal];
    
    CGRect bounds = self.unfoldBtn.bounds;
    bounds.size.width = ceilf(titleHeight + titleWidth + image.size.width);
    bounds.size.height = ceilf(titleHeight / 2 * 3);
    
    UIEdgeInsets titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, ceilf(image.size.width));
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsMake(0, ceilf(titleWidth + image.size.width * 2 + 4), 0, 0);

    self.unfoldBtn.bounds = bounds;
    
    self.unfoldBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -ceilf(image.size.width), 0, 0);
    self.unfoldBtn.titleEdgeInsets = titleEdgeInsets;
    self.unfoldBtn.imageEdgeInsets = imageEdgeInsets;
    
    
}

//

@end
