set -e

ipa="$(realpath "$1")"
mainDecrypted="$(realpath "$2")"
unityDecrypted="$(realpath "$3")"

cd "$(dirname "$0")"
rm -rf build
mkdir build
cd build

unzip "$ipa"
cp "$mainDecrypted" Payload/Monument3.app/Monument3
cp "$unityDecrypted" Payload/Monument3.app/Frameworks/UnityFramework.framework/UnityFramework

for name in SC_Info NetflixGames.framework NetflixGames-companion.framework
do
	find Payload -name "$name" | while read folder
	do
		rm -rf "$folder"
	done
done

defaults write "$PWD/Payload/Monument3.app/Info.plist" MinimumOSVersion 15.0

{
	echo -n '__asm__("'
	for register in {1..30}
	do
		echo -n ".global _objc_retain_x$register\\\n_objc_retain_x$register:\\\nmov x0, x$register\\\nb _objc_retain\\\n.global _objc_release_x$register\\\n_objc_release_x$register:\\\nmov x0, x$register\\\nb _objc_release\\\n"
	done
	echo '");'
	
	for symbol in ngp_access_get_player_authorization_code ngp_access_hide_netflix_button ngp_access_show_netflix_button ngp_achievements_get_achievements ngp_achievements_show_panel ngp_achievements_unlock_achievement ngp_blob_store_delete ngp_blob_store_read ngp_blob_store_resolve_conflict ngp_blob_store_write ngp_get_sdk_version ngp_leaderboards_get_current_player_entry ngp_leaderboards_get_info ngp_leaderboards_get_more_entries ngp_leaderboards_get_player_centric_entries ngp_leaderboards_get_top_entries ngp_messaging_handle_deeplink ngp_messaging_handle_notification_event ngp_messaging_register_notification_token ngp_performance_set_crash_reporter_config_callback ngp_profiles_get_legacy_gamer_access_token ngp_profiles_get_legacy_id ngp_profiles_get_profiles ngp_profiles_reset_preferred_language ngp_profiles_set_preferred_language ngp_show_netflix_access_ui_if_necessary ngp_social_get_friends ngp_social_get_presence_info ngp_social_set_social_event_callback ngp_social_show_sheet ngp_stats_get_aggregated_stat ngp_stats_submit_record ngp_stats_submit_record_now ngp_telemetry_get_should_enable_player_attribution ngp_telemetry_log_event ngp_test_login
	do
		echo "id $symbol(){return nil;}"
	done
	
	for class in PLCrashReporterConfig PLCrashReporter PLCrashReport
	do
		echo "@interface $class:NSObject\n@end\n@implementation $class\n@end"
	done
} > auto.m

clang -fmodules -dynamiclib -arch arm64 -miphoneos-version-min=15 -isysroot "$(xcrun -sdk iphoneos --show-sdk-path)" -Xlinker -reexport_library -Xlinker /usr/lib/libobjc.A.dylib ../shims.m -I . -o Payload/Monument3.app/Frameworks/impostor.dylib

install_name_tool -change /usr/lib/libobjc.A.dylib @rpath/impostor.dylib Payload/Monument3.app/Monument3
install_name_tool -change /usr/lib/libobjc.A.dylib @rpath/impostor.dylib Payload/Monument3.app/Frameworks/UnityFramework.framework/UnityFramework
install_name_tool -change @rpath/NetflixGames.framework/NetflixGames @rpath/impostor.dylib Payload/Monument3.app/Frameworks/UnityFramework.framework/UnityFramework
install_name_tool -change @rpath/NetflixGames-companion.framework/NetflixGames-companion @rpath/impostor.dylib Payload/Monument3.app/Frameworks/UnityFramework.framework/UnityFramework

zip -r fixed.ipa Payload
