//
//  MxAlgorithm.h
//  giftest
//
//  Created by jakerong on 11-11-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#ifndef  DEF_JAKERONG_MXALGORITHM_H
#define DEF_JAKERONG_MXALGORITHM_H
#include "MxImage.h"

void remove_image_background(MxImage* image);

#ifdef MX_IOS_SYSTEM
UIImage* removeImageBackground(UIImage* image);
#endif

#endif