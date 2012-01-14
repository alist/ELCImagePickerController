//
//  IPadHelper.m
//  swypPhotos
//
//  Created by Ethan Sherbondy on 1/14/12.
//

#import "UIDevice+iPad.h"

@implementation UIDevice (iPad)

- (BOOL)isIPad{
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_3_2){
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            return YES;
        }
    }
    
    return NO;
}

@end

@implementation NSString (iPad)

- (NSString *)addIPadSuffixWhenOnIPad {
    if([[UIDevice currentDevice] isIPad]){
        return [self stringByAppendingString:@"-iPad"];
    }
    else {
        return self;
    }   
}

@end
