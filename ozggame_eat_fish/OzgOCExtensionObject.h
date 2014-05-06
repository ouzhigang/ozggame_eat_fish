
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIKit.h>
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#import <AppKit/AppKit.h>
#endif

//NS

@interface NSString(ExtensionNSString)

- (NSUInteger)getReallyLength; //获取真实长度（中文为两个字节）

- (NSString*)toURLEncoding; //URL编码

- (NSString*)stringByAppendingFileSuffix:(NSString*)suffix; //添加文件名后缀（除去文件扩展名）

- (NSString*)md5;

@end

@interface NSArray(ExtensionNSArray)

- (NSArray*)randSort; //随机排序

@end

@interface NSData (ExtensionNSData)

- (NSData *)AES256EncryptWithKey:(NSString *)key;   //加密
- (NSData *)AES256DecryptWithKey:(NSString *)key;   //解密
- (NSString *)newStringInBase64FromData;            //追加64编码
+ (NSString*)base64encode:(NSString*)str;           //同上64编码

- (NSString*)md5;

@end

//UIKit

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface UIImage(ExtensionUIImage)

- (UIImage*)imageRotatedByRadians:(CGFloat)radians; //图片旋转 参数为弧度
- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees; //图片旋转 参数为角度
+ (UIImage*)imageWithUIView:(UIView*) view; //将UIView转成UIImage

@end

@interface UIColor(ExtensionUIColor)

+ (UIColor*) colorFromHexRGB:(NSString*) inColorString; //用十六进制的方式获取UIColor对象（参数的前面不用加#号）

@end
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#endif
