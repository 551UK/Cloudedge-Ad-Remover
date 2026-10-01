#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static void CEInvokeCurrentHistory(id controller) {
    if (!controller) return;

    SEL videoViewSel = NSSelectorFromString(@"videoView");
    if (![controller respondsToSelector:videoViewSel]) return;

    IMP videoViewImp = [controller methodForSelector:videoViewSel];
    if (!videoViewImp) return;

    id videoView = ((id (*)(id, SEL))videoViewImp)(controller, videoViewSel);
    if (!videoView) return;

    SEL historySel = NSSelectorFromString(@"didLookbackVideo");
    if (![videoView respondsToSelector:historySel]) return;

    IMP historyImp = [videoView methodForSelector:historySel];
    if (!historyImp) return;

    ((void (*)(id, SEL))historyImp)(videoView, historySel);
}

static void CEPlayButtonUseHistory(id self, SEL _cmd) {
    (void)_cmd;
    CEInvokeCurrentHistory(self);
}

static void CEAnalysisPlaybackUseHistory(id self, SEL _cmd, id view) {
    (void)_cmd;
    (void)view;
    CEInvokeCurrentHistory(self);
}

static void CEReplaceMethodIfPresent(Class cls, SEL sel, IMP imp) {
    if (!cls || !sel || !imp) return;
    Method method = class_getInstanceMethod(cls, sel);
    if (!method) return;
    method_setImplementation(method, imp);
}

static void CEInstallPlaybackHistoryFixNow(void) {
    Class cls = objc_getClass("WYMsgAlarmVideoPlayVC");
    if (!cls) return;

    CEReplaceMethodIfPresent(cls,
                             NSSelectorFromString(@"didClickPlayVideoView"),
                             (IMP)CEPlayButtonUseHistory);

    CEReplaceMethodIfPresent(cls,
                             NSSelectorFromString(@"analysisViewDidPhotoAction:"),
                             (IMP)CEAnalysisPlaybackUseHistory);

    CEReplaceMethodIfPresent(cls,
                             NSSelectorFromString(@"analysisViewDidPhotoTrialAction:"),
                             (IMP)CEAnalysisPlaybackUseHistory);
}

__attribute__((constructor))
static void CEInstallPlaybackHistoryFix(void) {
    CEInstallPlaybackHistoryFixNow();

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        CEInstallPlaybackHistoryFixNow();
    });
}


#pragma mark - Alarm list Play button

static char CEAlarmListPlayButtonKey;
static void (*CEOrigAlarmListCellLayoutSubviews)(id, SEL) = NULL;
static BOOL CEAlarmListCellHookInstalled = NO;

static UIButton *CEAlarmListPlayButtonForCell(id cell) {
    UIButton *button = objc_getAssociatedObject(cell, &CEAlarmListPlayButtonKey);
    if (button) return button;

    if (![cell isKindOfClass:UITableViewCell.class]) return nil;
    if (![cell respondsToSelector:NSSelectorFromString(@"playbackAction")]) return nil;

    UITableViewCell *tableCell = (UITableViewCell *)cell;

    button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.accessibilityLabel = @"Play recording";
    button.tintColor = UIColor.systemTealColor;
    button.layer.cornerRadius = 17.0;
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = UIColor.systemTealColor.CGColor;
    button.backgroundColor = UIColor.clearColor;
    button.clipsToBounds = YES;
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                              UIViewAutoresizingFlexibleTopMargin |
                              UIViewAutoresizingFlexibleBottomMargin;

    UIImageSymbolConfiguration *config =
        [UIImageSymbolConfiguration configurationWithPointSize:14.0
                                                        weight:UIImageSymbolWeightSemibold];
    UIImage *image = [UIImage systemImageNamed:@"play.fill" withConfiguration:config];
    [button setImage:image forState:UIControlStateNormal];

    [button addTarget:cell
               action:NSSelectorFromString(@"playbackAction")
     forControlEvents:UIControlEventTouchUpInside];

    [tableCell.contentView addSubview:button];
    objc_setAssociatedObject(cell,
                             &CEAlarmListPlayButtonKey,
                             button,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return button;
}

static void CELayoutAlarmListPlayButton(id self) {
    UIButton *button = CEAlarmListPlayButtonForCell(self);
    if (!button) return;

    UITableViewCell *cell = (UITableViewCell *)self;
    CGRect bounds = cell.contentView.bounds;

    const CGFloat size = 34.0;
    const CGFloat rightInset = 40.0;
    CGFloat x = CGRectGetWidth(bounds) - rightInset - size;
    CGFloat y = floor((CGRectGetHeight(bounds) - size) * 0.5);

    button.frame = CGRectMake(x, y, size, size);
    button.hidden = NO;
    button.alpha = 1.0;
    button.enabled = YES;
    button.userInteractionEnabled = YES;

    [cell.contentView bringSubviewToFront:button];
}

static void CEAlarmListCellLayoutSubviews(id self, SEL _cmd) {
    if (CEOrigAlarmListCellLayoutSubviews) {
        CEOrigAlarmListCellLayoutSubviews(self, _cmd);
    }
    CELayoutAlarmListPlayButton(self);
}

static void CEInstallAlarmListPlayButton(void) {
    if (CEAlarmListCellHookInstalled) return;

    Class cls = objc_getClass("WYMsgAlarmDetailSortTableViewCell");
    if (!cls) return;

    SEL layoutSel = @selector(layoutSubviews);
    Method layoutMethod = class_getInstanceMethod(cls, layoutSel);
    if (!layoutMethod) return;

    IMP inheritedOrOwn = method_getImplementation(layoutMethod);
    const char *types = method_getTypeEncoding(layoutMethod);

    if (class_addMethod(cls, layoutSel, (IMP)CEAlarmListCellLayoutSubviews, types)) {
        CEOrigAlarmListCellLayoutSubviews = (void (*)(id, SEL))inheritedOrOwn;
    } else {
        Method ownMethod = class_getInstanceMethod(cls, layoutSel);
        CEOrigAlarmListCellLayoutSubviews =
            (void (*)(id, SEL))method_setImplementation(ownMethod,
                                                        (IMP)CEAlarmListCellLayoutSubviews);
    }

    CEAlarmListCellHookInstalled = YES;
}

__attribute__((constructor))
static void CEInstallAlarmListPlayButtonConstructor(void) {
    CEInstallAlarmListPlayButton();

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        CEInstallAlarmListPlayButton();
    });
}
