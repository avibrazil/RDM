
#import <Foundation/Foundation.h>

#import <dlfcn.h>

#import "utils.h"


void CopyAllDisplayModes(CGDirectDisplayID display, modes_D4** modes, int* cnt)
{
	int nModes;
	CGSGetNumberOfDisplayModes(display, &nModes);
	
	if(nModes)
		*cnt = nModes;
	
	if(!modes)
		return;
		
	*modes = (modes_D4*) malloc(sizeof(modes_D4)* nModes);
	for(int i=0; i<nModes; i++)
	{
		
		CGSGetDisplayModeDescriptionOfLength(display, i, &(*modes)[i], 0xD4);
	}
}

void SetDisplayModeNum(CGDirectDisplayID display, int modeNum)
{
	CGDisplayConfigRef config;
	CGBeginDisplayConfiguration(&config);
	CGSConfigureDisplayMode(config, display, modeNum);
	CGCompleteDisplayConfiguration(config, kCGConfigurePermanently);
}