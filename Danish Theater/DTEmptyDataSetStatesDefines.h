//
//  DTEmptyDataSetStatesDefines.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/12/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#ifndef DTEmptyDataSetStatesDefines_h
#define DTEmptyDataSetStatesDefines_h

typedef enum : NSUInteger {
    DTEmptyDataSetStateUndefined,
    DTEmptyDataSetStateAnErrorOccurred,
    DTEmptyDataSetStateInitial, // delete
    DTEmptyDataSetStateOffline,
    DTEmptyDataSetStateNoResultsFound, // delete
    DTEmptyDataSetStateNoContent,
    DTEmptyDataSetStateLoading
} DTEmptyDataSetState;

#endif /* DTEmptyDataSetStatesDefines_h */
