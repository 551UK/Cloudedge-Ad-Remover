#import <Foundation/Foundation.h>
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
