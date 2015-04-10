


static inline CFDictionaryRef CGDisplayModeGetDictionary(CGDisplayModeRef mode) {
    CFDictionaryRef infoDict = ((CFDictionaryRef *)mode)[2]; // DIRTY, dirty, smelly, no good very bad hack
    return infoDict;
}


@interface ResMenuItem : NSMenuItem
{
	CGDirectDisplayID _display;
	
	int modeNum;
	
	//CGDisplayModeRef _mode;
	
	float refreshRate;
	float scale;
	int colorDepth;
	int width;
	int height;
}



- (id) initWithDisplay: (CGDirectDisplayID) display andMode: (modes_D4*) mode;

- (CGDirectDisplayID) display;

- (void) setTextFormat: (int) textFormat;


//- (CGDisplayModeRef) mode;

- (int) modeNum;

- (int) colorDepth;
- (int) width;
- (int) height;
- (float) refreshRate;
- (float) scale;

- (NSComparisonResult) compareResMenuItem: (ResMenuItem*) otherItem;

@end