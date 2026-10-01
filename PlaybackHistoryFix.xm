#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static void CEUseHistoryAction(id self, SEL _cmd) {
    (void)_cmd;
    if (!self) return;

    SEL videoViewSel = NSSelectorFromString(@"videoView");
    if (![self respondsToSelector:videoViewSel]) return;

    IMP videoViewImp = [self methodForSelector:videoViewSel];
    if (!videoViewImp) return;

    id videoView = ((id (*)(id, SEL))videoViewImp)(self, videoViewSel);
    if (!videoView) return;

    SEL historySel = NSSelectorFromString(@"didLookbackVideo");
    if (![videoView respondsToSelector:historySel]) return;

    IMP historyImp = [videoView methodForSelector:historySel];
    if (!historyImp) return;

    ((void (*)(id, SEL))historyImp)(videoView, historySel);
}

__attribute__((constructor))
static void CEInstallPlaybackHistoryFix(void) {
    Class cls = objc_getClass("WYMsgAlarmVideoPlayVC");
    if (!cls) return;

    SEL sel = NSSelectorFromString(@"didClickPlayVideoView");
    Method method = class_getInstanceMethod(cls, sel);
    if (!method) return;

    method_setImplementation(method, (IMP)CEUseHistoryAction);
}
