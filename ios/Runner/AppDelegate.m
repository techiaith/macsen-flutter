#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    if (@available(iOS 10.0, *)) {
      [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
    }

    self.macsenApp = [[FlutterMacsenMainActivity alloc]
                      initWithController:(FlutterViewController*)self.window.rootViewController];
        
    //
    [GeneratedPluginRegistrant registerWithRegistry:self];
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];

}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    NSLog(@"openUrl called: %@ %@", url, options);
    
    [self.macsenApp openUrl:url options:options];
    
    return true;
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    [self.macsenApp didBecomeActive];
}

-(void)applicationWillResignActive:(UIApplication *)application {
    [self.macsenApp willResignActive];
}

@end
