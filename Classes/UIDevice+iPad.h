//
//  IPadHelper.h
//  swypPhotos
//
//  Created by Ethan Sherbondy on 1/14/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIDevice (iPad)
- (BOOL)isIPad;
@end

@interface NSString (iPad)
- (NSString *)addIPadSuffixWhenOnIPad;
@end