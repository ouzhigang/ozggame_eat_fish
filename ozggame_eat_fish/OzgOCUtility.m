#import "OzgOCUtility.h"
#include "OzgOCObj.h"

@implementation OzgOCUtility

+ (BOOL) isEmail:(NSString*)email
{
    NSString *emailRegex = @"^\\w+((\\-\\w+)|(\\.\\w+))*@[A-Za-z0-9]+((\\.|\\-)[A-Za-z0-9]+)*.[A-Za-z0-9]+$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (NSString*) filterHTML:(NSString*)html
{
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO)
    {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL];
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text];
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString: [NSString stringWithFormat:@"%@>", text] withString:@" "];
    } // while //
    
    return html;
}

+ (NSDictionary*) getMultiLanguageDataWithFilePrefix:(NSString*)languageFilePrefix
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    //NSLog(@"%@", languages);
    
    NSString* currentLanguage = [languages objectAtIndex:0];
    
    NSString* suffix = nil;
    if([currentLanguage isEqual:@"zh-Hans"])
    {
        suffix = @"zh-Hans";
    }
    else
    {
        suffix = @"en";
    }
    
    NSString *appPath = [[NSBundle mainBundle] resourcePath];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/language-%@.plist", appPath, suffix];
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:filePath])
    {
        //NSLog(@"语言文件不存在");
        return nil;
    }
    
    NSDictionary *languageData = PP_AUTORELEASE([[NSDictionary alloc] initWithContentsOfFile:filePath]);
    return languageData;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

+ (BOOL)isRunAtIphone5
{
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat screenWidth = screen.bounds.size.width;
    CGFloat screenHeight = screen.bounds.size.height;
    if ((screenWidth == 568) || (screenHeight == 568))
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isRunAtIphone
{
    return [OzgOCUtility checkDevice:@"iPhone"];
}

+ (BOOL)isRunAtIpad
{
    return [OzgOCUtility checkDevice:@"iPad"];
}

+ (BOOL)isRunAtItouch
{
    return [OzgOCUtility checkDevice:@"iTouch"];
}

+ (UIImage *)getPicZoomImage:(UIImage *)image
{
    CGFloat picAfterZoomWidth = 960;
    CGFloat picAfterZoomHeight = 640;
    
    if([OzgOCUtility isRunAtIphone5])
    {
        //iphone5
        picAfterZoomWidth = 1136;
        picAfterZoomHeight = 640;
    }
    
    return [OzgOCUtility getPicZoomImage:image picAfterZoomWidth:picAfterZoomWidth picAfterZoomHeight:picAfterZoomHeight];
    
}

+ (UIImage*)getPicZoomImage:(UIImage*)image picAfterZoomWidth:(CGFloat)picAfterZoomWidth picAfterZoomHeight:(CGFloat)picAfterZoomHeight;
{
    UIImage *img = image;
    
    int h = img.size.height;
    int w = img.size.width;
    
    if(h <= picAfterZoomWidth && w <= picAfterZoomHeight)
    {
        //image = img;
    }
    else
    {
        float b = (float)picAfterZoomWidth / w < (float)picAfterZoomHeight / h ? (float)picAfterZoomWidth / w : (float)picAfterZoomHeight / h;
        
        CGSize itemSize = CGSizeMake(b * w, b * h);
        
        UIGraphicsBeginImageContext(itemSize);
        
        CGRect imageRect = CGRectMake(0, 0, b * w, b * h);
        
        [img drawInRect:imageRect];
        
        img = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    return img;
}

/*+ (CGSize)TrueSizeToIPhoneSize:(CGSize)trueSize
 {
 CGSize iphoneSize = CGSizeMake(trueSize.width / 2, trueSize.height / 2);
 return iphoneSize;
 }*/

+ (bool)checkDevice:(NSString*)name
{
    NSString* deviceType = [UIDevice currentDevice].model;
    //NSLog(@"deviceType = %@", deviceType);
    
    NSRange range = [deviceType rangeOfString:name];
    return range.location != NSNotFound;
}

+ (NSString*)getTheImagePath:(NSString*)imgFilePrefix withImgFileSuffix:(NSString*)imgFileSuffix
{
    if([OzgOCUtility isRunAtIphone5])
    {
        //iphone5
        return [NSString stringWithFormat:@"%@640X1136%@", imgFilePrefix, imgFileSuffix];
    }
    
    return [NSString stringWithFormat:@"%@640X960%@", imgFilePrefix, imgFileSuffix];
}

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#endif



+ (CGFloat)getCGRGBValue:(CGFloat)value
{
    //计算公式:三基色的值 / 255.0f
    return value / 255.0f;
}

+ (CGColorRef)getCGColorRefFromRed:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha
{
    CGFloat r = (CGFloat) red / 255.0;
    CGFloat g = (CGFloat) green / 255.0;
    CGFloat b = (CGFloat) blue / 255.0;
    CGFloat a = (CGFloat) alpha / 255.0;
    CGFloat components[4] = {r, g, b, a};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef color = CGColorCreate(colorSpace, components);
    CGColorSpaceRelease(colorSpace);
    
    CGColorRelease(color);
    // I need to auto release the color before returning from this.
    
    return color;
}

@end
