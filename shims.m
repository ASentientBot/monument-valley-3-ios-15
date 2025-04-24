@import UIKit;

#import "auto.m"

id objc_retainAutoreleasedReturnValue(id);

id objc_claimAutoreleasedReturnValue(id object)
{
	return objc_retainAutoreleasedReturnValue(object);
}

@interface UIViewController(Shim)
@end

@implementation UIViewController(Shim)

-(void)setNeedsUpdateOfSupportedInterfaceOrientations
{
}

@end

char* jsonWithDictionary(NSDictionary* dictionary)
{
	NSMutableData* data=((NSMutableData*)[NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil].mutableCopy).autorelease;
	[data increaseLengthBy:1];
	return (char*)data.bytes;
}

void (*accessCallback)(char*)=NULL;

void ngp_access_set_event_callback(void (*callback)(char*))
{
	accessCallback=callback;
}

void ngp_request_player_access()
{
	@autoreleasepool
	{
		accessCallback(jsonWithDictionary(@{
			@"eventId":@"onUserStateChange",
			@"eventMsg":[NSString stringWithUTF8String:jsonWithDictionary(@{
				@"current":@{@"playerId":@"amy"},
				@"previous":@{@"playerId":@"william"}
			})]
		}));
	}
}

void ngp_profiles_get_current_profile(void (*callback)(char*))
{
	@autoreleasepool
	{
		callback(jsonWithDictionary(@{@"profileId":@"amy"}));
	}
}

void ngp_blob_store_get_blobs(long correlation,void (*callback)(long,char*))
{
	@autoreleasepool
	{
		callback(correlation,jsonWithDictionary(@{}));
	}
}
