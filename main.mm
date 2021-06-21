

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "SRApplicationDelegate.h"
#import "cmdline.h"


int main(int argc, const char* argv[])
{
	int ret = -1;
	if(argc > 1)
	{
		ret = cmdline_main(argc, argv);
	}
	
	if(ret == -1)
	{
		fprintf(stderr, "Commandline options\n"
						"  --width    (-w)  Width\n"
						"  --height   (-h)  Height\n"
						"  --freq    (-f)  Frequency (in Hz, e.g. 30 or 60, default=not specified)\n"
						"  --scale    (-s)  Scale (2.0 = Retina, default=current)\n"
						"  --bits     (-b)  Color depth (default=current)\n"
						"  --display  (-d)  Select display # (default=main)\n"
						"  --displays (-ld) List available displays\n"
						"  --modes    (-lm) List available modes\n"
						"\nCurrently running GUI.  Use ^C or close from menu\n");
		
		NSAutoreleasePool* pool = [NSAutoreleasePool new];
		NSApplication* app = [NSApplication sharedApplication];

		[app setDelegate: [SRApplicationDelegate new]];

		//NSApplication* app = [SRApplication sharedApplication];
		[app performSelectorOnMainThread: @selector(run) withObject: nil waitUntilDone: YES];

		[pool release];
	}
	
	
}