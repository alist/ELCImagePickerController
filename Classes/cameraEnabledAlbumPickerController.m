//
//  cameraEnabledAlbumPickerController.m
//  swypPhotos
//
//  Created by Alexander List on 12/4/11.
//  Copyright (c) 2011 ExoMachina. All rights reserved.
//

#import "cameraEnabledAlbumPickerController.h"

@implementation cameraEnabledAlbumPickerController
- (void)viewDidLoad {
	[super viewDidLoad];
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
		UIBarButtonItem * cameraButton	=	[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(openCamera:)];
		[self.navigationItem setRightBarButtonItem:cameraButton];
		[cameraButton release];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetLibraryChanged:) name:ALAssetsLibraryChangedNotification object:nil];
}

-(void) openCamera:(id)sender{
	UIImagePickerController * imagePicker	=	[[UIImagePickerController alloc] init];
	[imagePicker setDelegate:self];
	[imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
	[imagePicker setShowsCameraControls:TRUE];
	[imagePicker setAllowsEditing:TRUE];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
		//ipads must display popover
		if (_imagePickerPopover == nil){
			_imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
		}
		[_imagePickerPopover setContentViewController:imagePicker];
		[_imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:FALSE];
	}else{
		[self presentModalViewController:imagePicker animated:TRUE];
	}
	[imagePicker release];
}

-(void)	dealloc{
	[_imagePickerPopover release];
	_imagePickerPopover		= nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super release];
}

-(void)	assetLibraryChanged: (id) sender{
	[self.navigationItem setTitle:@"Loading..."];
	
	//    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.parent action:@selector(cancelImagePicker)];
	//	[self.navigationItem setRightBarButtonItem:cancelButton];
	//	[cancelButton release];
	
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.assetGroups = tempArray;
    [tempArray release];
    
    library = [[ALAssetsLibrary alloc] init];      
	
    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^
				   {
					   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
					   
					   // Group enumerator Block
					   void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
					   {
						   if (group == nil) 
						   {
							   return;
						   }
						   
						   [self.assetGroups addObject:group];
						   
						   // Reload albums
						   [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
					   };
					   
					   // Group Enumerator Failure Block
					   void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
						   
						   if ([error code] == ALAssetsLibraryAccessGloballyDeniedError){
							   UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Access Needed" message:@"Your library include personal location information.\nTo access your library, please enable Location Services (in Settings > General)." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
							   [alert show];
							   [alert release];
						   }else{
							   
							   UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
							   [alert show];
							   [alert release];
						   }
						   
						   NSLog(@"A problem occured %@", [error description]);	                                 
					   };	
					   
					   // Enumerate Albums
					   [library enumerateGroupsWithTypes:ALAssetsGroupAll
											  usingBlock:assetGroupEnumerator 
											failureBlock:assetGroupEnumberatorFailure];
					   
					   [pool release];
				   });    

}

#pragma mark - Delegation 
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	UIImage * selectedImage	=	[info valueForKey:UIImagePickerControllerEditedImage];
	UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil);
	
	if (_imagePickerPopover){
		[_imagePickerPopover dismissPopoverAnimated:TRUE];
	}else{
		[self dismissModalViewControllerAnimated:TRUE];
	}
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	if (_imagePickerPopover){
		[_imagePickerPopover dismissPopoverAnimated:TRUE];
	}else{
		[self dismissModalViewControllerAnimated:TRUE];
	}
}

@end
