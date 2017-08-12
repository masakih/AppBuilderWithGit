// encoding=utf-8
PRODUCT_NAME=AppBuilderWithGit
PRODUCT_EXTENSION=app
BUILD_PATH=./build
DEPLOYMENT=Release
APP_BUNDLE=$(PRODUCT_NAME).$(PRODUCT_EXTENSION)
APP=$(BUILD_PATH)/$(DEPLOYMENT)/$(APP_BUNDLE)
APP_NAME=$(BUILD_PATH)/$(DEPLOYMENT)/$(PRODUCT_NAME)
SCHEME=AppBuilderWithGit
INFO_PLIST=AppBuilderWithGit/Info.plist

LOCALIZE_FILES=

VER_CMD=grep -A1 'CFBundleShortVersionString' $(INFO_PLIST) | tail -1 | tr -d "'\t</string>" 
VERSION=$(shell $(VER_CMD))

all: package

Localizable: $(LOCALIZE_FILES)
	genstrings -o AppBuilderWithGit/ja.lproj $^
	(cd AppBuilderWithGit/ja.lproj; ${MAKE} $@;)
#	genstrings -o AppBuilderWithGit/en.lproj $^
#	(cd AppBuilderWithGit/en.lproj; ${MAKE} $@;)


checkLocalizable:
#	(cd AppBuilderWithGit/en.lproj; ${MAKE} $@;)
	(cd AppBuilderWithGit/ja.lproj; ${MAKE} $@;)

deploy:
	test -z "`git status --porcelain`"

#release: Carthage updateRevision
release: updateRevision
	xcodebuild -derivedDataPath=build -configuration $(DEPLOYMENT)
	$(MAKE) restoreInfoPlist

package: deploy release
	REV=`git rev-parse --short HEAD`;	\
	ditto -ck -rsrc --keepParent $(APP) $(APP_NAME)-$(VERSION)-$${REV}.zip

updateRevision:
	if [ ! -f $(INFO_PLIST).bak ] ; then cp $(INFO_PLIST) $(INFO_PLIST).bak ; fi ;	\
	REV=`git rev-parse --short HEAD` ;	\
	sed -e "s/%%%%REVISION%%%%/$${REV}/" $(INFO_PLIST) > $(INFO_PLIST).r ;	\
	mv -f $(INFO_PLIST).r $(INFO_PLIST) ;	\

restoreInfoPlist:
	if [ -f $(INFO_PLIST).bak ] ; then mv -f $(INFO_PLIST).bak $(INFO_PLIST) ; fi

Carthage:
	carthage update
	rm -rf Carthage/Build/*OS
