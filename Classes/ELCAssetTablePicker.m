//
//  AssetTablePicker.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"
#import "UIDevice+iPad.h"

@implementation ELCAssetTablePicker

@synthesize parent;
@synthesize selectedAssetsLabel;
@synthesize assetGroup, elcAssets;

static NSUInteger rowsPerColumn;

-(NSUInteger)cellSize {
    return [[UIDevice currentDevice] isIPad] ? 96 : 80;
}

-(void)updateRowsPerColumn {
    rowsPerColumn = floor(self.view.frame.size.width/[self cellSize]);
    NSLog(@"%i rows per column.", rowsPerColumn);
}

-(void)toggleCheckMode {
    isInCheckMode = !isInCheckMode;
}

-(void)viewDidLoad {        
	[self.tableView setSeparatorColor:[UIColor clearColor]];
	[self.tableView setAllowsSelection:NO];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
    [tempArray release];
	
//	UIBarButtonItem *doneButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];
//	[self.navigationItem setRightBarButtonItem:doneButtonItem];
    
    UIBarButtonItem *selectModeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(toggleCheckMode)];
    
    self.navigationItem.rightBarButtonItem = selectModeButton;
    
    isInCheckMode = YES;
    
    [selectModeButton release];
    
	[self.navigationItem setTitle:@"Loading..."];

	[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    
    // Show partial while full list loads
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:.5];
	
	[self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 75, 0)];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateRowsPerColumn];
}

-(void)preparePhotos {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	
    NSLog(@"enumerating photos");
    [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) 
     {         
         if(result == nil) 
         {
             return;
         }
         
         ELCAsset *elcAsset = [[[ELCAsset alloc] initWithAsset:result] autorelease];
         [elcAsset setParent:self];
         [self.elcAssets addObject:elcAsset];
     }];    
    NSLog(@"done enumerating photos");
	
	[self.tableView reloadData];
	[self.navigationItem setTitle:@"Pick Photos"];
    
    [pool release];

}

- (void) doneAction:(id)sender {
	
	NSMutableArray *selectedAssetsImages = [[[NSMutableArray alloc] init] autorelease];
	    
	for(ELCAsset *elcAsset in self.elcAssets) 
    {		
		if([elcAsset selected]) {
			
			[selectedAssetsImages addObject:[elcAsset asset]];
		}
	}
        
    [(ELCAlbumPickerController*)self.parent selectedAssets:selectedAssetsImages];
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ceil([self.assetGroup numberOfAssets] / rowsPerColumn);
}

- (NSArray*)assetsForIndexPath:(NSIndexPath*)_indexPath {
    
	int index = (_indexPath.row*rowsPerColumn);
	int maxIndex = (_indexPath.row*rowsPerColumn+(rowsPerColumn-1));
    
	// NSLog(@"Getting assets for %d to %d with array count %d", index, maxIndex, [assets count]);
    
    NSMutableArray *assetArray = [NSMutableArray array];
    for (int i = 0; i < rowsPerColumn; i++) {
        if ((maxIndex-i) < [self.elcAssets count]) {
            [assetArray addObject:[self.elcAssets objectAtIndex:index+(rowsPerColumn-i-1)]];
        }
    }
    
    if (assetArray.count > 0) {
        return [NSArray arrayWithArray:assetArray];      
    } else {
        return nil;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
        
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) 
    {		        
        cell = [[[ELCAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:CellIdentifier] autorelease];
    }	
	else 
    {		
		[cell setAssets:[self assetsForIndexPath:indexPath]];
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[UIDevice currentDevice] isIPad] ? 95 : 79;
}

- (int)totalSelectedAssets {
    
    int count = 0;
    
    for(ELCAsset *asset in self.elcAssets) 
    {
		if([asset selected]) 
        {            
            count++;	
		}
	}
    
    return count;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self updateRowsPerColumn];
    [self.tableView reloadData];
}

- (void)dealloc 
{
    [elcAssets release];
    [selectedAssetsLabel release];
    [super dealloc];    
}

@end
