

typedef union
{
	uint8_t rawData[0xDC];
	struct 
	{
		uint32_t mode;
		uint32_t flags;		// 0x4
		uint32_t width;		// 0x8
		uint32_t height;	// 0xC
		uint32_t depth;		// 0x10
		uint32_t dc2[42];
		uint16_t dc3;
		uint16_t freq;		// 0xBC
		uint32_t dc4[4];
		float density;		// 0xD0
		// freq = 0xBC
		// density = 0xD0
	//	uint32_t freq;
	} derived;
} modes_D4;

extern "C"
{
 	void CGSGetCurrentDisplayMode(CGDirectDisplayID display, int* modeNum);
	void CGSConfigureDisplayMode(CGDisplayConfigRef config, CGDirectDisplayID display, int modeNum);
	void CGSGetNumberOfDisplayModes(CGDirectDisplayID display, int* nModes);
	void CGSGetDisplayModeDescriptionOfLength(CGDirectDisplayID display, int idx, modes_D4* mode, int length);
};


void CopyAllDisplayModes(CGDirectDisplayID display, modes_D4** modes, int* cnt);
void SetDisplayModeNum(CGDirectDisplayID display, int modeNum);

