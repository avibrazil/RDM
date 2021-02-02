


#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "utils.h"
#import "ResMenuItem.h"

@implementation ResMenuItem : NSMenuItem


- (id) initWithDisplay: (CGDirectDisplayID) display andMode: (modes_D4*) mode
{
	if((self = [super initWithTitle: @"" action: @selector(setMode:) keyEquivalent: @""]) && display && mode)
	{
        _display = display;

		modeNum = mode->derived.mode;
		scale = mode->derived.density;
        
		width = mode->derived.width;
		height = mode->derived.height;
		
		refreshRate = mode->derived.freq;
		
		colorDepth = (mode->derived.depth == 4) ? 32 : 16;
		
		
		NSString* title;
		if(scale == 2.0f)
		{
			if(refreshRate)
			{
				title = [NSString stringWithFormat: @"%d × %d ⚡️, %.0f Hz", width, height, refreshRate];
			}
			else
			{
				title = [NSString stringWithFormat: @"%d × %d ⚡️", width, height];
			}
		}
		else
		{
			if(refreshRate)
			{
				title = [NSString stringWithFormat: @"%d × %d, %.0f Hz", width, height, refreshRate];
			}
			else
			{
				title = [NSString stringWithFormat: @"%d × %d", width, height];
			}
		}
		[self setTitle: title];
	
		return self;
	}
	else
	{
		return NULL;
	}
}

- (void) setTextFormat: (int) textFormat
{
	NSString* title = nil;
	if(textFormat == 1)
	{
		if(scale == 2.0f)
		{
			title = [NSString stringWithFormat: @"%d × %d ⚡", width, height];
		}
		else
		{
			title = [NSString stringWithFormat: @"%d × %d", width, height];
		}
	}
	
	if(textFormat == 2)
	{
		title = [NSString stringWithFormat: @"%.0f Hz", refreshRate];
	}
	if(title)
		[self setTitle: title];
	
	
	
}

- (CGDirectDisplayID) display
{
	return _display;
}

- (int) modeNum
{
	return modeNum;
}

- (int) colorDepth
{
	return colorDepth;
}

- (int) width
{
	return width;
}

- (int) height
{
	return height;
}

- (float) refreshRate
{
	return refreshRate;
}

- (float) scale
{
	return scale;
}

- (NSComparisonResult) compareResMenuItem: (ResMenuItem*) otherItem
{
	{
		int o_width = [otherItem width];
		if(width < o_width)
			return NSOrderedDescending;
		else if(width > o_width)
			return NSOrderedAscending;
//		return NSOrderedSame;
	}
	{
		int o_scale = [otherItem scale];
		if(scale < o_scale)
			return NSOrderedDescending;
		else if(scale > o_scale)
			return NSOrderedAscending;
//		return NSOrderedSame;
	}
	{
		int o_height = [otherItem height];
		if(height < o_height)
			return NSOrderedDescending;
		else if(height > o_height)
			return NSOrderedAscending;
//		return NSOrderedSame;
	}
	{
		int o_refreshRate = [otherItem refreshRate];
		if(refreshRate < o_refreshRate)
			return NSOrderedDescending;
		else if(refreshRate > o_refreshRate)
			return NSOrderedAscending;
		return NSOrderedSame;
	}


}

@end