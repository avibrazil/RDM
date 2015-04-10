#!/usr/bin/env make -f

PREFIX=/usr
IDENTIFIER=net.alkalay.RDM

VERSION=2.0

CC=llvm-g++
PACKAGE_BUILD=/usr/bin/pkgbuild
ARCH_FLAGS=-arch x86_64

.PHONY: build

RDM.app: SetResX Resources Info.plist
	mkdir -p RDM.app/Contents/MacOS/
	cp SetResX RDM.app/Contents/MacOS/
	cp -r Info.plist Resources RDM.app/Contents


SetResX: main.o SRApplicationDelegate.o ResMenuItem.o cmdline.o utils.o 
	$(CC) $^ -o $@ $(ARCH_FLAGS) -framework Foundation -framework ApplicationServices -framework AppKit 


clean:
	rm -f SetResX
	rm -f *.o
	rm -rf RDM.app
	rm -rf pkgroot dmgroot
	rm -f *.pkg *.dmg

%.o: %.mm
	$(CC) $(CPPFLAGS) $(CFLAGS) $(ARCH_FLAGS) $< -c -o $@


screenresolution: main.o cg_utils.o
	$(CC) $(CPPFLAGS) $(CFLAGS) $(ARCH_FLAGS) -framework Foundation -framework ApplicationServices $^ -o $@

%.icns: %.png
	sips -s format icns $< --out $@

SwitchResolution.app: SwitchResolution.applescript resolution.icns
	osacompile -o $@ $<
	mv resolution.icns $@/Contents/Resources/applet.icns

version.h:
	sed -e "s/@VERSION@/\"$(VERSION)\"/" < version-tmpl.h > version.h

pkg: RDM.app
	mkdir -p pkgroot/Applications
	mv $< pkgroot/Applications/
	$(PACKAGE_BUILD) --root pkgroot/  --identifier $(IDENTIFIER) \
		--version $(VERSION) "RDM-$(VERSION).pkg" 
	rm -f RDM.pkg
	ln -s RDM-$(VERSION).pkg RDM.pkg

dmg: pkg
	mkdir -p dmgroot
	cp RDM-$(VERSION).pkg dmgroot/
	rm -f RDM-$(VERSION).dmg
	hdiutil makehybrid -hfs -hfs-volume-name "RDM $(VERSION)" \
		-o "RDM-$(VERSION).dmg" dmgroot/
	rm -f RDM.dmg
	ln -s RDM-$(VERSION).dmg RDM.dmg

.PHONY: pkg dmg install build clean
