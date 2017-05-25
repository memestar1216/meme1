#import <UIKit/UIKit.h>

#import "BTThreeDSecureLookupResult.h"
#import "BTThreeDSecureErrors.h"
#import "BTCardPaymentMethod.h"
#import "BTWebViewController.h"

typedef NS_ENUM(NSInteger, BTThreeDSecureViewControllerCompletionStatus) {
    BTThreeDSecureViewControllerCompletionStatusFailure = 0,
    BTThreeDSecureViewControllerCompletionStatusSuccess,
};

@protocol BTThreeDSecureAuthenticationViewControllerDelegate;

///  A view controller that authenticates a cardholder for 3D Secure
///
///  @warning Do not initialize this view controller directly. Instead, use 
///           `BTThreeDSecure` to initiate the 3D Secure flow.
///
///  Initialize this view controller with a BTThreeDSecureLookupResult, which contains the
///  information that is needed to obtain cardholder authorization via the issuing bank's login
///  within a web view for a particular card.
///
///  You can perform the prerequisite lookup via the
///  -[BTClient lookupNonceForThreeDSecure:transactionAmount:success:failure:] instance method.
///
///  An initialized BTThreeDSecureViewController will challenge the user as soon as it is presented
///  and cannot be reused.
///
///  On success, the original payment method nonce is consumed, and you will receive a new payment
///  method nonce. Transactions created with this nonce will be 3D Secure.
///
///  This view controller is not always necessary to achieve a successful 3D Secure verification. Sometimes,
///  the lookup will consume the original nonce and return an upgraded 3D Secure nonce directly.
///
///  @see BTThreeDSecure
@interface BTThreeDSecureAuthenticationViewController : BTWebViewController

///  Initializes a 3D Secure authentication view controller
///
///  @param lookupResult Contains the result of the 3D Secure lookup
///
///  @return A view controller or nil when authentication is not possible and/or required.
- (instancetype)initWithLookupResult:(BTThreeDSecureLookupResult *)lookupResult NS_DESIGNATED_INITIALIZER;

///  The delegate is notified when the 3D Secure authentication flow completes
@property (nonatomic, weak) id<BTThreeDSecureAuthenticationViewControllerDelegate> delegate;

@end

@protocol BTThreeDSecureAuthenticationViewControllerDelegate <NSObject>

///  The delegate will receive this message after the user has successfully authenticated with 3D Secure
///
///  On Braintree's servers, this nonce will point to both a card and its 3D Secure verification.
///
///  This implementation is responsible for receiving the 3D Secure payment method nonce and transmitting
///  it to your server for server-side operations. Upon completion, you must call the completionBlock.
///
///  Do *not* dismiss the view controller in this method. See threeDSecureViewControllerDidFinish:.
///
///  @param viewController  The 3D Secure view controller
///  @param card            The new payment method that should be used for creating a 3D Secure transaction
///  @param completionBlock A block that must be called upon completion of any asynchronous work that processes the received card
- (void)threeDSecureViewController:(BTThreeDSecureAuthenticationViewController *)viewController
               didAuthenticateCard:(BTCardPaymentMethod *)card
                        completion:(void (^)(BTThreeDSecureViewControllerCompletionStatus status))completionBlock;

///  The delegate will receive this message when 3D Secure authentication fails
///
///  This can occur due to a system error, lack of issuer participation or failed user authentication.

///  Do *not* dismiss the view controller in this method. See threeDSecureViewControllerDidFinish:.
///
///  @param viewController  The 3D Secure view controller
///  @param error           The error that caused 3D Secure to fail
- (void)threeDSecureViewController:(BTThreeDSecureAuthenticationViewController *)viewController
                  didFailWithError:(NSError *)error;

///  The delegate will receive this message upon completion of the 3D Secure flow, possibly including async work
///  that happens in your implementation of threeDSecureViewController:didAuthenticateNonce:completion:
///
/// This method will be called in both success and failure cases.
///
///  You should dismiss the provided view controller in your implementation.
///
///  @param viewController The 3D Secure view controller
- (void)threeDSecureViewControllerDidFinish:(BTThreeDSecureAuthenticationViewController *)viewController;

@optional

- (void)threeDSecureViewController:(BTThreeDSecureAuthenticationViewController *)viewController didPresentErrorToUserForURLRequest:(NSURLRequest *)request;

@end
