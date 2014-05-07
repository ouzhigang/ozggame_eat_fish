
#ifndef OzgOCObj_h
#define OzgOCObj_h

//判断是否运行在ARC状态
#if __has_feature(objc_arc) && __clang_major__ >= 3
#define PP_ARC_ENABLED 1
#endif // __has_feature(objc_arc)

//同时支持ARC和非ARC的处理
#if PP_ARC_ENABLED
//ARC
#define PP_RETAIN(xx) (xx)
#define PP_RELEASE(xx) xx = nil
#define PP_AUTORELEASE(xx) (xx)

#else
//非ARC
#define PP_RETAIN(xx) [xx retain]
#define PP_RELEASE(xx) [xx release], xx = nil
#define PP_AUTORELEASE(xx) [xx autorelease]

#endif

#endif
