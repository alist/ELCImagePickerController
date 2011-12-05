//
//  cameraEnabledAlbumPickerController.h
//  swypPhotos
//
//  Created by Alexander List on 12/4/11.
//  Copyright (c) 2011 ExoMachina. All rights reserved.
//

#import "ELCAlbumPickerController.h"

@interface cameraEnabledAlbumPickerController : ELCAlbumPickerController <UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
	UIPopoverController *			_imagePickerPopover;	
}
@end
