#import "OzgCCUtility.h"

@implementation OzgCCUtility

#ifdef __CC_PLATFORM_IOS
+ (NSString*)getImagePath:(NSString*)path
{
    if([OzgOCUtility isRunAtIphone5])
    {
        NSString *ext = [path pathExtension];
        return [NSString stringWithFormat:@"%@.%@", [[path stringByDeletingPathExtension] stringByAppendingString:@"-ip5"], ext];
    }
    else
        return path;
}
#elif defined(__CC_PLATFORM_MAC)
+ (NSString*)getImagePath:(NSString*)path;
{
    return path;
}
#endif

+ (BOOL)randomRate:(CGFloat)rate
{
    if(CCRANDOM_0_1() <= rate)
        return YES;
    
    return NO;
}

+ (CGFloat)randomRange:(CGFloat)minValue withMaxValue:(CGFloat)maxValue
{
    CGFloat val = maxValue - minValue;
    val = minValue + (val * CCRANDOM_0_1());
    return val;
}

@end
