

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "SRApplicationDelegate.h"

#import "utils.h"
#import "ResMenuItem.h"






@implementation SRApplicationDelegate

- (void) showAbout
{
  [NSApp activateIgnoringOtherApps:YES];
  [NSApp orderFrontStandardAboutPanel:self];
}


- (void) quit
{
	[NSApp terminate: self];
}



- (void) refreshStatusMenu
{
	if(statusMenu)
		[statusMenu release];
	
	statusMenu = [[NSMenu alloc] initWithTitle: @""];
	
	uint32_t nDisplays;
	CGDirectDisplayID displays[0x10];
	CGGetOnlineDisplayList(0x10, displays, &nDisplays);
	
	for(int i=0; i<nDisplays; i++)
	{
		CGDirectDisplayID display = displays[i];
		{
			NSMenuItem* item;
			NSString* title = i ? [NSString stringWithFormat: @"Display %d", i+1] : @"Main Display";
			item = [[NSMenuItem alloc] initWithTitle: title action: nil keyEquivalent: @""];
			[item setEnabled: NO];
			[statusMenu addItem: item];
		}
		
		
		int mainModeNum;
		CGSGetCurrentDisplayMode(display, &mainModeNum);
		//modes_D4 mainMode;
		//CGSGetDisplayModeDescriptionOfLength(display, mainModeNum, &mainMode, 0xD4);
		ResMenuItem* mainItem = nil;
		
		
		int nModes;
		modes_D4* modes;
		CopyAllDisplayModes(display, &modes, &nModes);
		
		{
			NSMutableArray* displayMenuItems = [NSMutableArray new];
			//ResMenuItem* mainItem = nil;
			
			for(int j = 0; j <nModes; j++)
		    {
				ResMenuItem* item = [[ResMenuItem alloc] initWithDisplay: display andMode: &modes[j]];
				//[item autorelease];
				if(mainModeNum == j)
				{
					mainItem = item;
					[item setState: NSControlStateValueOn];
				}
				[displayMenuItems addObject: item];
				[item release];
			}
			int idealColorDepth = 32;
			double idealRefreshRate = 0.0f;
			if(mainItem)
			{
				idealColorDepth = [mainItem colorDepth];
				idealRefreshRate = [mainItem refreshRate];
			}
			[displayMenuItems sortUsingSelector: @selector(compareResMenuItem:)];
		
		
			NSMenu* submenu = [[NSMenu alloc] initWithTitle: @""];
			
			ResMenuItem* lastAddedItem = nil;
			for(int j=0; j < [displayMenuItems count]; j++)
			{
				ResMenuItem* item = [displayMenuItems objectAtIndex: j];
				if([item colorDepth] == idealColorDepth)
				{
					if([item refreshRate] == idealRefreshRate)
					{
						[item setTextFormat: 1];
					}
					
					if(lastAddedItem && [lastAddedItem width]==[item width] && [lastAddedItem height]==[item height] && [lastAddedItem scale]==[item scale])
					{
						double lastRefreshRate = lastAddedItem ? [lastAddedItem refreshRate] : 0;
						double refreshRate = [item refreshRate];
						if(!lastAddedItem || (lastRefreshRate != idealRefreshRate && (refreshRate == idealRefreshRate || refreshRate > lastRefreshRate)))
						{
							if(lastAddedItem)
							{
								[submenu removeItem: lastAddedItem];
								lastAddedItem = nil;
							}
							[submenu addItem: item];
							lastAddedItem = item;
						}
					}
					else
					{	
						[submenu addItem: item];
						lastAddedItem = item;
					}
				}
			}
			
			NSString* title;
			{
				if([mainItem scale] == 2.0f)
				{
					title = [NSString stringWithFormat: @"%d × %d ⚡️️", [mainItem width], [mainItem height]];
				}
				else
				{
					title = [NSString stringWithFormat: @"%d × %d", [mainItem width], [mainItem height]];
				}
			}
			
			
			NSMenuItem* resolution = [[NSMenuItem alloc] initWithTitle: title action: nil keyEquivalent: @""];
			[resolution setSubmenu: submenu];
			[submenu release];
			[statusMenu addItem: resolution];
			[resolution release];
			
			[displayMenuItems release];
		}
		
		{
			NSMutableArray* displayMenuItems = [NSMutableArray new];
			ResMenuItem* mainItem = nil;
			for(int j = 0; j < nModes; j++)
		    {
				ResMenuItem* item = [[ResMenuItem alloc] initWithDisplay: display andMode: &modes[j]];
				[item setTextFormat: 2];
				//[item autorelease];
				if(mainModeNum == j)
				{
					mainItem = item;
					[item setState: NSControlStateValueOn];
				}
				[displayMenuItems addObject: item];
				[item release];
			}
			int idealColorDepth = 32;
			double idealRefreshRate = 0.0f;
			if(mainItem)
			{
				idealColorDepth = [mainItem colorDepth];
				idealRefreshRate = [mainItem refreshRate];
			}
			[displayMenuItems sortUsingSelector: @selector(compareResMenuItem:)];
			
			
			NSMenu* submenu = [[NSMenu alloc] initWithTitle: @""];
			for(int j=0; j< [displayMenuItems count]; j++)
			{
				ResMenuItem* item = [displayMenuItems objectAtIndex: j];
				if([item colorDepth] == idealColorDepth)
				{
					if([mainItem width]==[item width] && [mainItem height]==[item height] && [mainItem scale]==[item scale])
					{
						[submenu addItem: item];
					}
				}
			}
			if(idealRefreshRate)
			{
				NSMenuItem* freq = [[NSMenuItem alloc] initWithTitle: [NSString stringWithFormat: @"%.0f Hz", [mainItem refreshRate]] action: nil keyEquivalent: @""];
			
				if([submenu numberOfItems] > 1)
				{
					[freq setSubmenu: submenu];
				}
				else
				{
					[freq setEnabled: NO];
				}
				[statusMenu addItem: freq];
				[freq release];
			}
			[submenu release];
			
			[displayMenuItems release];
			
		}
		
		
		free(modes);
		
		
		[statusMenu addItem: [NSMenuItem separatorItem]];
	}
	
	[statusMenu addItemWithTitle: @"About RDM" action: @selector(showAbout) keyEquivalent: @""];
	
	
	[statusMenu addItemWithTitle: @"Quit" action: @selector(quit) keyEquivalent: @""];
	[statusMenu setDelegate: self];
	[statusItem setMenu: statusMenu];
}


- (void) setMode: (ResMenuItem*) item
{
	CGDirectDisplayID display = [item display];
	int modeNum = [item modeNum];
	
	SetDisplayModeNum(display, modeNum);
	/*
	
	CGDisplayConfigRef config;
    if (CGBeginDisplayConfiguration(&config) == kCGErrorSuccess) {
        CGConfigureDisplayWithDisplayMode(config, display, mode, NULL);
        CGCompleteDisplayConfiguration(config, kCGConfigureForSession);
    }*/
	[self refreshStatusMenu];
}

- (void) applicationDidFinishLaunching: (NSNotification*) notification
{
//	NSLog(@"Finished launching");
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength: NSSquareStatusItemLength] retain];
	
	NSImage* statusImage = [NSImage imageNamed: @"StatusIcon"];
	statusItem.button.image = statusImage;
	[statusItem.button.cell setHighlightsBy: NSContentsCellMask];

  BOOL supportsDarkMenu = !(floor(NSAppKitVersionNumber) < 1343);
  if (supportsDarkMenu) {
    // [[statusItem image] setTemplate:YES];
	  [statusItem.button.image setTemplate: YES];
  }

	[self refreshStatusMenu];
	
}

@end
