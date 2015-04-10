#import <Foundation/Foundation.h>

#import <dlfcn.h>

#import "utils.h"




int cmdline_main(int argc, const char * argv[])
{
	//exit(0);
	
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
 	{
		int width = 0;
		int height = 0;
		CGFloat scale = 0.0f;
		int bitRes = 0;
		int displayNo = -1;
		double rotation = -1;
		
		bool listDisplays = 0;
		bool listModes = 0;
		
		for(int i=1; i<argc; i++)
		{
			if(argv[i][0]=='-')
			{
				if(strlen(argv[i])==2)
				{
					switch(argv[i][1])
					{
						case 'w':
							i++;
							width = atoi(argv[i]);
							break;
						case 'h':
							i++;
							height = atoi(argv[i]);
							break;
						case 's':
							i++;
							scale = atof(argv[i]);
							break;
						case 'b':
							i++;
							bitRes = atoi(argv[i]);
							break;
						case 'd':
							i++;
							displayNo = atoi(argv[i]);
							break;
						case 'l':
							if(argv[i][2]=='m')
								listModes = 1;
							if(argv[i][2]=='d')
								listDisplays = 1;
							break;
						case 'r':
							i++;
							rotation = atof(argv[i]);
							break;
						default:
							return -1;
					}
					continue;
				}
				if(argv[i][1]=='l' && strlen(argv[i])==3)
				{
					if(argv[i][2]=='m')
						listModes = 1;
					else if(argv[i][2]=='d')
						listDisplays = 1;
					else
						return -1;
					continue;
				}
				if(argv[i][1]=='-')
				{
					if(!strcmp(&argv[i][2], "width"))
					{
						i++;
						width = atoi(argv[i]);
					}
					else if(!strcmp(&argv[i][2], "height"))
					{
						i++;
						height = atoi(argv[i]);
					}
					else if(!strcmp(&argv[i][2], "scale"))
					{
						i++;
						scale = atof(argv[i]);
					}
					else if(!strcmp(&argv[i][2], "bits"))
					{
						i++;
						bitRes = atoi(argv[i]);
					}
					else if(!strcmp(&argv[i][2], "display"))
					{
						i++;
						displayNo = atoi(argv[i]);
					}
					else if(!strcmp(&argv[i][2], "displays"))
					{
						listDisplays = 1;
					}
					else if(!strcmp(&argv[i][2], "modes"))
					{
						listModes = 1;
					}
					else if(!strcmp(&argv[i][2], "rotation"))
					{
						i++;
						rotation = atof(argv[i]);
					}
					else
					{
						return -1;
					}
					continue;
				}
				return -1;
			}
			return -1;
		}

		uint32_t nDisplays;
		CGDirectDisplayID displays[0x10];
		CGGetOnlineDisplayList(0x10, displays, &nDisplays);
		
		//displays[0] = CGMainDisplayID();
		
		
		CGDirectDisplayID display;
	    
		if(displayNo > 0)
		{
			if(displayNo > nDisplays -1)
			{
				fprintf(stderr, "Error: display index %d exceeds display count %d\n", displayNo, nDisplays);
				exit(1);
			}
			display = displays[displayNo];
		}
		else
		{
		    display = CGMainDisplayID();
		}
		
		if(listDisplays)
		{
			for(int i=0; i<nDisplays; i++)
			{
				int modeNum;
				CGSGetCurrentDisplayMode(display, &modeNum);
				modes_D4 mode;
				CGSGetDisplayModeDescriptionOfLength(display, modeNum, &mode, 0xD4);
				
				int mBitres = (mode.derived.depth == 4) ? 32 : 16;
				
				fprintf(stdout, "Display %d: {resolution=%dx%d, scale = %.1f, freq = %d, bits/pixel = %d}\n", i, mode.derived.width, mode.derived.height, mode.derived.density, mode.derived.freq, mBitres);
				
			}
			
			return 0;
		}
		if(listModes)
		{
			int nModes;
			modes_D4* modes;
			CopyAllDisplayModes(display, &modes, &nModes);
			
			for(int i=0; i<nModes; i++)
			{
				modes_D4 mode = modes[i];
				if(width && mode.derived.width != width)
					continue;
				if(height && mode.derived.height != height)
					continue;
				int mBitres = (mode.derived.depth == 4) ? 32 : 16;
				if(bitRes && mBitres != bitRes)
					continue;
				if(scale && mode.derived.density != scale)
					continue;
				
				fprintf(stdout, "mode: {resolution=%dx%d, scale = %.1f, freq = %d, bits/pixel = %d}\n", mode.derived.width, mode.derived.height, mode.derived.density, mode.derived.freq, mBitres);
				
			}
			
			free(modes);
			
			return 0;
			/*
			CFArrayRef modes = CGDisplayCopyAllDisplayModes(display, NULL);
		    for (int i = 0; i < CFArrayGetCount(modes); i++) {
		        CGDisplayModeRef mode = (CGDisplayModeRef)CFArrayGetValueAtIndex(modes, i);
		        CFDictionaryRef infoDict = CGDisplayModeGetDictionary(mode);
				
		        CFNumberRef resolution = (CFNumberRef) CFDictionaryGetValue(infoDict, CFSTR("kCGDisplayResolution"));
		        CFNumberRef bits = (CFNumberRef) CFDictionaryGetValue(infoDict, CFSTR("BitsPerPixel"));
		        float modeScale = 1.0f;
		        int modeBitres;
		        if(resolution)
					CFNumberGetValue(resolution, kCFNumberFloatType, &modeScale);
		        CFNumberGetValue(bits, kCFNumberIntType, &modeBitres);
				
				int modeWidth = (int)CGDisplayModeGetWidth(mode);
				int modeHeight = (int)CGDisplayModeGetHeight(mode);
				
				//NSLog(@"%@", [mode description]);
				//NSLog(@"%@", [(NSDictionary*)infoDict description]);
				
				if(width && modeWidth != width)
					continue;
				if(height && modeHeight != height)
					continue;
				if(scale && modeScale != scale)
					continue;
				if(bitRes && modeBitres != bitRes)
					continue;
				
				
				
		        printf("mode: {resolution=%dx%d, scale = %.1f, bits/pixel = %d}\n", modeWidth,
		               modeHeight, modeScale, modeBitres);
		    }
		    CFRelease(modes);
			return 0;
			*/
		}
		
		if(rotation != -1.0f)
		{
			fprintf(stderr, "Sorry, cannot adjust rotation at this time!\n");
			exit(1);
		}
		
		// fill in missing details
		{
			int modeNum;
			CGSGetCurrentDisplayMode(display, &modeNum);
			modes_D4 mode;
			CGSGetDisplayModeDescriptionOfLength(display, modeNum, &mode, 0xD4);
			
			if(!width && !height)
			{
				width = mode.derived.width;
				height = mode.derived.height;
			}
			if(!scale)
			{
				scale = mode.derived.density;
			}
			int mBitres = (mode.derived.depth == 4) ? 32 : 16;
			if(!bitRes)
			{
				bitRes = mBitres;
			}
		}
		
		
		{
			int nModes;
			modes_D4* modes;
			CopyAllDisplayModes(display, &modes, &nModes);
			
			int iMode = -1;
			
			for(int i=0; i<nModes; i++)
			{
				modes_D4 mode = modes[i];
				if(width && mode.derived.width != width)
					continue;
				if(height && mode.derived.height != height)
					continue;
				int mBitres = (mode.derived.depth == 4) ? 32 : 16;
				if(bitRes && mBitres != bitRes)
					continue;
				if(scale && mode.derived.density != scale)
					continue;
				
				iMode = i;
				break;
				//fprintf(stdout, "mode: {resolution=%dx%d, scale = %.1f, freq = %d, bits/pixel = %d}\n", mode.derived.width, mode.derived.height, mode.derived.density, mode.derived.freq, mode.derived.depth);
			}
			
			if(iMode != -1)
			{
				SetDisplayModeNum(display, iMode);
			}
			else
			{
				fprintf(stderr, "Error: could not select a new mode\n");
			}
			
			free(modes);
		}
		
		
    }
	[pool release];
    return 0;
}
