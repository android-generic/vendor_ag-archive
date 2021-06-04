Android-Generic Project - V2.0

How to setup: (pc only for now, gsi & emu will be added back soon)
	. build/envsetup.sh
	ag-menu pc

This will initially generate the menu items with what is available for modules. 
Next, we need to go in order:
- 01-generate-base-gui
- 02 generate-others
- 02-generate-remove-project
- 03-sync-project

At this point, you may see "fatal: remove-project element specifies non-existent project: ........."
This means that your ROM removed an item from manifest a different way than we were expecting from the script. 
cd into .repo/local_manifests/01-remove.xml and comment out the line the sync script was complaining about

If any other errors show up with sync, try to manually run:

	repo sync --force-sync -j4

Otherwise, we can continue to the next step:
- 05-apply-base-patches
	
(or you can use the generate-base script for the legacy script)



Using the following functions (available after '. build/envsetup.sh'):
- apply-x86-patches - Applies main x86 patches found in vendor/x86/utils/android_r/google_diff/x86
- apply-x86-extras - Applies any patches found in vendor/x86/utils/android_r/google_diff/x86-extras
- apply-kernel-patches kernel_version - USAGE: kernel_version=(5.4, 5.10, 5.11, 5.12) so far - EX: ( $ apply-kernel-patches 5.4 )- Apply kernel patches for Android 11 5.4-lts (patch folder is found in vendor/x86/utils/android_r/google_diff/kernel

Also added (but not used YET):
get-cros-files-x86
get-cros-files-x86_64
