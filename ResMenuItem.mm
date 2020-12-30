


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

		int a = width;
		int b = height;
		int t;
		while (b != 0) {
			t = b;
			b = a % b;
			a = t;
		}
		_w = width / a;
		_h = height / a;
		if (_h == 5) {
			_w *= 2;
			_h *= 2;
		}

		NSString* title;
		if(scale == 2.0f)
		{
			if(refreshRate)
			{
				title = [NSString stringWithFormat: @"%d × %d, %.0f Hz ⚡️", width, height, refreshRate];
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

- (int) _w
{
	return _w;
}

- (int) _h
{
	return _h;
}

- (float) refreshRate
{
	return refreshRate;
}

- (float) scale
{
	return scale;
}

- (float) aspect
{
	return float(_w) / _h;
}

- (NSComparisonResult) compareResMenuItem: (ResMenuItem*) otherItem
{
	{
		float aspect = [self aspect];
		float o_aspect = [otherItem aspect];
		if (aspect < o_aspect)
			return NSOrderedAscending;
		else if (aspect > o_aspect)
			return NSOrderedDescending;
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
		int o_refreshRate = [otherItem refreshRate];
		if(refreshRate < o_refreshRate)
			return NSOrderedDescending;
		else if(refreshRate > o_refreshRate)
			return NSOrderedAscending;
		return NSOrderedSame;
	}


}

@end
