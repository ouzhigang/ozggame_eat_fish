#import <Foundation/Foundation.h>

@interface OzgOCUtility : NSObject

+ (BOOL) isEmail:(NSString*)email; //判断是否为Email地址
+ (NSString*) filterHTML:(NSString*)html; //过滤html

/*
 language-en.plist
 language-zh-Hans.plist
 这两个文件的key是一样的，value均是对应语言的版本
 
 多语言处理Demo：
 NSDictionary *languageData = [HonGeeUtility getMultiLanguageDataWithFilePrefix:@"language"];
 
 //NSLog(@"%@", [languageData objectForKey:@"str1"]);
 
 UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 150)];
 lab.text = [languageData objectForKey:@"str1"];
 [self.view addSubview:lab];
 
 */
+ (NSDictionary*) getMultiLanguageDataWithFilePrefix:(NSString*)languageFilePrefix;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
+ (BOOL)isRunAtIphone5; //判断是否是用iphone5运行
+ (BOOL)isRunAtIphone; //判断是否是用iphone运行
+ (BOOL)isRunAtIpad; //判断是否是用ipad运行
+ (BOOL)isRunAtItouch; //判断是否是用itouch运行

+ (UIImage*)getPicZoomImage:(UIImage*)image;//按照屏幕比例放缩图片（目前只支持竖屏和iphone，ipad未支持）
+ (UIImage*)getPicZoomImage:(UIImage*)image picAfterZoomWidth:(CGFloat)picAfterZoomWidth picAfterZoomHeight:(CGFloat)picAfterZoomHeight; //放缩图片

//+ (CGSize)TrueSizeToIPhoneSize:(CGSize)trueSize; //按照实际像素返回iphone设备的大小

+ (bool)checkDevice:(NSString*)name; //判断运行设备

+ (NSString*)getTheImagePath:(NSString*)imgFilePrefix withImgFileSuffix:(NSString*)imgFileSuffix; //传入文件名的前缀和后缀，然后获取兼容各设备的图片路径.Demo：传入前缀bg，后缀传入.png，则返回bg???X???.png。（目前只支持竖屏和iphone，ipad未支持）

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#endif

+ (CGFloat)getCGRGBValue:(CGFloat)value; //传入RGB值0-255，计算并返回CG库用的值
+ (CGColorRef)getCGColorRefFromRed:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha; //传入0-255的RGBA值，返回CGColorRef

@end
