#import "Three20/TTAlertViewController.h"
#import "Three20/TTNavigator.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTAlertView : UIAlertView {
  UIViewController* _popupViewController;
}

@property(nonatomic,retain) UIViewController* popupViewController;

@end

@implementation TTAlertView

@synthesize popupViewController = _popupViewController;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _popupViewController = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_popupViewController);
  [super dealloc];
}

- (void)didMoveToSuperview {
  if (!self.superview) {
    [_popupViewController autorelease];
    _popupViewController = nil;
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTAlertViewController

@synthesize delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate {
  if (self = [super init]) {
    _delegate = delegate;
    _URLs = [[NSMutableArray alloc] init];
    
    if (title) {
      self.alertView.title = title;
    }
    if (message) {
      self.alertView.message = message;
    }
  }
  return self;
}


- (id)initWithTitle:(NSString*)title message:(NSString*)message {
  return [self initWithTitle:title message:message delegate:nil];
}

- (id)init {
  return [self initWithTitle:nil message:nil delegate:nil];
}
- (void)dealloc {
  TT_RELEASE_SAFELY(_URLs);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  TTAlertView* alertView = [[[TTAlertView alloc] initWithTitle:nil message:nil delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:nil] autorelease];
  alertView.popupViewController = self;
  self.view = alertView;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UTViewController (TTCategory)

- (BOOL)persistView:(NSMutableDictionary*)state {
  return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPopupViewController

- (void)showInView:(UIView*)view animated:(BOOL)animated {
  [self viewWillAppear:animated];
  [self.alertView show];
  [self viewDidAppear:animated];
}

- (void)dismissPopupViewControllerAnimated:(BOOL)animated {
  [self viewWillDisappear:animated];
  [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:animated];
  [self viewDidDisappear:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIAlertviewDelegate

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if ([_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
    [_delegate alertView:alertView clickedButtonAtIndex:buttonIndex];
  }
}

- (void)alertViewCancel:(UIAlertView*)alertView {
  if ([_delegate respondsToSelector:@selector(alertViewCancel:)]) {
    [_delegate alertViewCancel:alertView];
  }
}

- (void)willPresentAlertView:(UIAlertView*)alertView {
  if ([_delegate respondsToSelector:@selector(willPresentAlertView:)]) {
    [_delegate willPresentAlertView:alertView];
  }
}

- (void)didPresentAlertView:(UIAlertView*)alertView {
  if ([_delegate respondsToSelector:@selector(didPresentAlertView:)]) {
    [_delegate didPresentAlertView:alertView];
  }
}

- (void)alertView:(UIAlertView*)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
  if ([_delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
    [_delegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
  }
}

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  NSString* URL = [self buttonURLAtIndex:buttonIndex];
  if (URL) {
    TTOpenURL(URL);
  }
  if ([_delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
    [_delegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIAlertView*)alertView {
  return (UIAlertView*)self.view;
}

- (NSInteger)addButtonWithTitle:(NSString*)title URL:(NSString*)URL {
  if (URL) {
    [_URLs addObject:URL];
  } else {
    [_URLs addObject:[NSNull null]];
  }
  return [self.alertView addButtonWithTitle:title];
}

- (NSInteger)addCancelButtonWithTitle:(NSString*)title URL:(NSString*)URL {
  self.alertView.cancelButtonIndex = [self addButtonWithTitle:title URL:URL];
  return self.alertView.cancelButtonIndex;
}

- (NSString*)buttonURLAtIndex:(NSInteger)index {
  id URL = [_URLs objectAtIndex:index];
  return URL != [NSNull null] ? URL : nil;
}

@end
