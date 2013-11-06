#import "OzgCCUtility.h"

@implementation OzgCCUtility

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
    
    NSDictionary *languageData = [[[NSDictionary alloc] initWithContentsOfFile:filePath] autorelease];
    return languageData;
}

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
    return [OzgCCUtility checkDevice:@"iPhone"];
}

+ (BOOL)isRunAtIpad
{
    return [OzgCCUtility checkDevice:@"iPad"];
}

+ (BOOL)isRunAtItouch
{
    return [OzgCCUtility checkDevice:@"iTouch"];
}

+ (NSString*)getTheImagePath:(NSString*)imgFilePrefix withImgFileSuffix:(NSString*)imgFileSuffix
{
    if([OzgCCUtility isRunAtIphone5])
    {
        //iphone5
        return [NSString stringWithFormat:@"%@640X1136%@", imgFilePrefix, imgFileSuffix];
    }
    
    return [NSString stringWithFormat:@"%@640X960%@", imgFilePrefix, imgFileSuffix];
}

+ (UIImage *)getPicZoomImage:(UIImage *)image
{
    CGFloat picAfterZoomWidth = 960;
    CGFloat picAfterZoomHeight = 640;
    
    if([OzgCCUtility isRunAtIphone5])
    {
        //iphone5
        picAfterZoomWidth = 1136;
        picAfterZoomHeight = 640;
    }
    
    return [OzgCCUtility getPicZoomImage:image picAfterZoomWidth:picAfterZoomWidth picAfterZoomHeight:picAfterZoomHeight];
    
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

+ (UIColor *)colorFromHexRGB:(NSString*) inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    result = [UIColor colorWithRed: (float)redByte / 0xff green: (float)greenByte/ 0xff blue: (float)blueByte / 0xff alpha:1.0];
    return result;
}

+ (bool)checkDevice:(NSString*)name
{
    NSString* deviceType = [UIDevice currentDevice].model;
    //NSLog(@"deviceType = %@", deviceType);
    
    NSRange range = [deviceType rangeOfString:name];
    return range.location != NSNotFound;
}

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

//cocos2d
+ (CCAnimate*) createAnimate:(NSString*)plist
{
    NSMutableArray *spriteFrames = [NSMutableArray array];
    NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], plist]];
    
    NSInteger loops = [(NSString*)[root objectForKey:@"loop"] integerValue];
    float delay = [(NSString*)[root objectForKey:@"delay"] floatValue];
    NSArray *frames = (NSArray*)[root objectForKey:@"frames"];
    NSDictionary *rectDict = (NSDictionary*)[root objectForKey:@"rect"];
    
    CGFloat rectX = [(NSString*)[rectDict objectForKey:@"x"] floatValue];
    CGFloat rectY = [(NSString*)[rectDict objectForKey:@"y"] floatValue];
    CGFloat rectWidth = [(NSString*)[rectDict objectForKey:@"width"] floatValue];
    CGFloat rectHeight = [(NSString*)[rectDict objectForKey:@"height"] floatValue];
    CGRect rect = CGRectMake(rectX, rectY, rectWidth, rectHeight);

    for (NSObject *item in frames)
    {
        NSString *itemStr = (NSString*)item;
        
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:itemStr];
        CCSpriteFrame *spriteFrame = [CCSpriteFrame frameWithTexture:texture rect:rect];
        [spriteFrames addObject:spriteFrame];
        
    }
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:spriteFrames delay:delay];
    [animation setLoops:loops];
    
    CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
    return animate;
}

+ (void)clearAnimate:(NSString*)plist
{
    NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], plist]];
    NSArray *frames = (NSArray*)[root objectForKey:@"frames"];
    for (NSObject *item in frames)
    {
        NSString *itemStr = (NSString*)item;
        [[CCTextureCache sharedTextureCache] removeTextureForKey:itemStr];
    }
    
}

+ (NSString*)getImagePath:(NSString*)path
{
    if([OzgCCUtility isRunAtIphone5])
    {
        NSString *ext = [path pathExtension];
        return [NSString stringWithFormat:@"%@.%@", [[path stringByDeletingPathExtension] stringByAppendingString:@"-ip5"], ext];
    }
    else
        return path;
}

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
