//
//  WebViewController.m
//  Cordova WebView Plugin
//
//  Created by Marcus Koehler on 27.10.14.
//
//

#import "WebViewController.h"

#define RGBCOLOR(rgbValue) [UIColor \
colorWithRed:	((float)((rgbValue & 0x00FF0000) >> 16))/0xFF \
green:			((float)((rgbValue & 0x0000FF00) >>  8))/0xFF \
blue:			((float)((rgbValue & 0x000000FF) >>  0))/0xFF \
alpha:			1.0 \
]

@interface WebViewController (private) <UIWebViewDelegate>
@end

@implementation WebViewController

- (id)initWithOptions: (NSDictionary*) _options
{
    if ((self = [super init]) != nil)
    {
        options = _options;
        //self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    UIColor *bgColor = [self colorWithRGBHexString:[options objectForKey:@"backgroundColor"]];
    UIColor *iconColor = [self colorWithRGBHexString:[options objectForKey:@"iconColor"]];

    //bool isPDF = [[options objectForKey:@"isPDF"] boolValue];

    bool showNavigationBar = [[options objectForKey:@"showNavigationBar"] boolValue];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIView * navigtionBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, showNavigationBar ? 64:0)];
    navigtionBar.backgroundColor = bgColor;
    [self.view addSubview:navigtionBar];
    
    if(!showNavigationBar){
        navigtionBar.hidden = true;
    }
    
    UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, navigtionBar.frame.size.height-20)];
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [navigtionBar addSubview:bottomView];


    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(60, (bottomView.frame.size.height-40)/2, 40, 40)];
    [closeButton addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setImage:[self tintedImageWithColor:iconColor image:[UIImage imageNamed:@"ic_nav_close.png"]]forState:UIControlStateNormal];
    closeButton.tintColor = iconColor;
    closeButton.backgroundColor = [UIColor clearColor];
    [bottomView addSubview:closeButton];
    
    backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (bottomView.frame.size.height-40)/2, 60, 40)];
    [backButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[self tintedImageWithColor:iconColor image:[UIImage imageNamed:@"ic_nav_back.png"]]forState:UIControlStateNormal];
    //backButton.enabled = NO;
    [bottomView addSubview: backButton];
    
  
        UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake((bottomView.frame.size.width - 100)/2, 0, 100, bottomView.frame.size.height)];
        titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleView.backgroundColor = [UIColor clearColor];
        titleView.textAlignment = NSTextAlignmentCenter;
        
        if([options objectForKey:@"titleColor"] != nil){
            titleView.textColor = [self colorWithRGBHexString:[options objectForKey:@"titleColor"]];
        }
        if([options objectForKey:@"titleFontSize"] != nil){
            titleView.font = [UIFont systemFontOfSize:[[options objectForKey:@"titleFontSize"] integerValue]];
        }
        if([options objectForKey:@"title"] != nil){
            titleView.text = [options objectForKey:@"title"];
        }
        
        [bottomView addSubview:titleView];

        
        forwardButton = [[UIButton alloc] initWithFrame:CGRectMake(60, (titleView.frame.size.height-40)/2, 40, 40)];
        [forwardButton addTarget:self action:@selector(onForward) forControlEvents:UIControlEventTouchUpInside];
        forwardButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [forwardButton setImage:[self tintedImageWithColor:iconColor image:[UIImage imageNamed:@"ic_nav_forward.png"]]forState:UIControlStateNormal];
        forwardButton.enabled = NO;
        //[middleView addSubview: forwardButton];

        refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(bottomView.frame.size.width-50, (bottomView.frame.size.height-40)/2, 40, 40)];
        [refreshButton addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventTouchUpInside];
        [refreshButton setImage:[self tintedImageWithColor:iconColor image:[UIImage imageNamed:@"ic_nav_refresh.png"]]forState:UIControlStateNormal];
        [bottomView addSubview:refreshButton];
    


    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, navigtionBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - navigtionBar.frame.size.height)];
    webView.scrollView.bounces = false;
    webView.autoresizesSubviews = true;
    webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    webView.scalesPageToFit = true;
    webView.backgroundColor = [UIColor whiteColor];
    webView.delegate = self;
    [self.view addSubview:webView];


    ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    ai.center = CGPointMake(webView.bounds.size.width/2, (webView.bounds.size.height/2));
    ai.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    [webView addSubview:ai];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = false;
    NSString *urlString = [options objectForKey:@"url"];

	if ([options objectForKey:@"urlEncoding"] != nil)
	{
		bool encodeURL = [[options objectForKey:@"urlEncoding"] boolValue];
		if (encodeURL)
			urlString = [[options objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}

	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = false;
}

#pragma mark -
#pragma mark Webview Delegate

- (bool) webView:(UIWebView *)_webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //forwardButton.enabled = _webView.canGoForward;
    //backButton.enabled = _webView.canGoBack;
    NSURL *url = request.URL;
    if([url.scheme  isEqual: @"hybrid"]){
        if([url.host isEqual:@"back"]){
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        return false;
    }
    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [ai startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [ai stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [ai stopAnimating];
}

#pragma mark -

- (void) onClose
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onRefresh
{
    [webView reload];
}

- (void) onForward
{
    if (webView.canGoForward)
        [webView goForward];
}

- (void) onBack
{
    if (webView.canGoBack){
        [webView goBack];
    } else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark Helper

- (UIColor*)colorWithRGBHexString:(NSString *)stringToConvert
{
    unsigned hexNum;

    if ([stringToConvert hasPrefix:@"#"])
        stringToConvert = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];

    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    if (![scanner scanHexInt:&hexNum]) return nil;
    return [self colorWithRGBHex:hexNum];
}

- (UIColor*)colorWithRGBHex:(UInt32)hex
{
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;

    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0];
}

- (UIImage*)tintedImageWithColor:(UIColor*)tintColor image: (UIImage*) image
{
    CGSize imgSize = image.size;
    CGRect imgRect = CGRectMake(0, 0, imgSize.width, imgSize.height);
    UIGraphicsBeginImageContextWithOptions(imgSize, false, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // draw alpha-mask
    [image drawInRect:imgRect blendMode:kCGBlendModeNormal alpha:1.0];

    // draw tint color, preserving alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [tintColor setFill];
    CGContextFillRect(context, imgRect);

    UIImage* tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;
}

@end
