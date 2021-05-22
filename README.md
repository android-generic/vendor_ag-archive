Simple patching system in a vendor profile

Using the following functions (available after '. build/envsetup.sh'):
- apply-x86-patches - Applies main x86 patches found in vendor/x86/utils/android_r/google_diff/x86
- apply-x86-extras - Applies any patches found in vendor/x86/utils/android_r/google_diff/x86-extras
- apply-kernel-patches kernel_version - USAGE: kernel_version=(5.4, 5.10, 5.11, 5.12) so far - EX: ( $ apply-kernel-patches 5.4 )- Apply kernel patches for Android 11 5.4-lts (patch folder is found in vendor/x86/utils/android_r/google_diff/kernel

Also added (but not used YET):
get-cros-files-x86
get-cros-files-x86_64
