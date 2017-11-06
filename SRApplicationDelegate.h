


@interface SRApplicationDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>
{
	NSMenu* statusMenu;
	NSStatusItem* statusItem;
}
- (void) refreshStatusMenu;
@end

