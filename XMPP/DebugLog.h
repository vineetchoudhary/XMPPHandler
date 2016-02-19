//
//  DebugLog.h
//
//  Created by Vineet Choudhary
//  Copyright (c) Vineet Choudhary. All rights reserved.
//

#ifndef DebugLog_h
#define DebugLog_h


#if DEBUG
#define DebugLog(...) NSLog(__VA_ARGS__)
#else
#define DebugLog(...)
#endif

#endif /* DebugLog_h */
