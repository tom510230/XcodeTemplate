//
//  MxAlgorithm.cpp
//  giftest
//
//  Created by jakerong on 11-11-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#include "MxAlgorithm.h"
#include <vector>
#include "MxImage.h"

using std::vector;

#define IMGPOINT(image,p) (*(image->imageData + p.x + p.y * image->widthStep))
#define SET_IMGPOINT(image,p,val) ((*(image->imageData + p.x + p.y * image->widthStep))=val)
#define UNCHECK 0
#define CHECKED_OK 255
#define CHECKED_FAIL 2

#define MEAN_DIFF 1
#define GRADIENT_DIFF 4

void process_image_points(MxImage* image,MxImage* flag_img,vector<MxPoint>* stack,int mean)
{    
    while(stack->size()>0)
    {
        MxPoint p = (MxPoint)*stack->rbegin();
        stack->pop_back();
        
        if(p.x < 0 || p.x > image->width - 1 || p.y < 0 || p.y > image->height - 1)continue;
        
        unsigned char flag = IMGPOINT(flag_img,p);
        
        if(flag!=UNCHECK)continue;
        
        int val = (unsigned char)IMGPOINT(image,p);
        
        // check
        
        bool isOK = false;
        
        if(mean - MEAN_DIFF <=  val && val <= mean + MEAN_DIFF)
        {
            isOK = true;
        }
        
        if(!isOK)
        {
            for ( int i = -1 ; i <= 1; i++)
            {
                for (int j = -1 ; j <= 1; j++)
                {
                    if(i==0 && j==0)continue;
                    
                    if(i== 1 && j== 1)continue;
                    if(i== 1 && j==-1)continue;
                    if(i==-1 && j== 1)continue;
                    if(i==-1 && j==-1)continue;
                    
                    if(p.x+i < 0 || p.x+i > image->width - 1 || p.y+j < 0 || p.y+j > image->height - 1)continue;
                    
                    MxPoint pn = mxPoint(p.x+i, p.y+j);
                    flag = IMGPOINT(flag_img,pn);
                    if(flag==CHECKED_OK)
                    {
                        int valn = (unsigned char)IMGPOINT(image,pn);
                        if(valn - GRADIENT_DIFF <= val && val <= valn + GRADIENT_DIFF)
                        {
                            SET_IMGPOINT(flag_img,pn,CHECKED_OK);
                            isOK = true;
                            break;
                        }
                    }
                }
                if(isOK)
                {
                    break;
                }
            }        
        }
        
        if(isOK){
            
            SET_IMGPOINT(flag_img,p,CHECKED_OK);
            
            //            stack->push_back(cvPoint(p.x-1, p.y-1));
            stack->push_back(mxPoint(p.x  , p.y-1));
            //            stack->push_back(cvPoint(p.x+1, p.y-1));
            stack->push_back(mxPoint(p.x-1, p.y  ));
            stack->push_back(mxPoint(p.x+1, p.y  ));
            //            stack->push_back(cvPoint(p.x-1, p.y+1));
            stack->push_back(mxPoint(p.x  , p.y+1));
            //            stack->push_back(cvPoint(p.x+1, p.y+1));            
            
        }else{
            SET_IMGPOINT(flag_img,p,CHECKED_FAIL);
        }
        
    }
}


int find_background_color(MxImage* gray)
{
    /* color statistics */
    
    int colors[256] = {0};
    
    uchar* src = gray->imageData;
    int width = gray->width;
    // top
    int height = 3;
    for( ; height--; src += gray->widthStep )
    {
        for(int i = 0; i < width; i++ )
        {
            colors[src[i]]++;
        }
    }
    // bottom
    height = 3;
    src = gray->imageData + (gray->height-height)*gray->widthStep;
    for( ; height--; src -= gray->widthStep )
    {
        for(int i = 0; i < width; i++ )
        {
            colors[src[i]]++;
        }
    }
    height = gray->height;
    // left
    width = 3;
    //src = gray->imageData;
    for( ; width--; )
    {
        src = gray->imageData + width;
        for(int i = 0; i < height; i++,src += gray->widthStep)
        {
            colors[*src]++;
        }
    }
    // right
    width = 3;
    //src = gray->imageData;
    for( ; width--; )
    {
        src = gray->imageData + (gray->width - width-1);
        for(int i = 0; i < height; i++,src += gray->widthStep)
        {
            colors[*src]++;
        }
    }
    int bkColor = 0;
    int max_count = 0;
    for(int i = 0; i < 256; i++ )
    {
        if (colors[i]>max_count) {
            max_count = colors[i];
            bkColor = i;
        }
    }
    return bkColor;
}


void remove_image_background(MxImage* image)
{
    if (image->nChannels!=4) return;

    MxImage* gray = mxCreateImage(image->width, image->height, 1);
    mxConvertRGBA2Gray(image, gray);
    
    MxImage* flag = mxCreateImage(image->width, image->height, 1);
    mxZero(flag);
    
    vector<MxPoint> proc_stack;
    
    for (int i = 0; i < gray->width; i++) {
        proc_stack.push_back(mxPoint(i, 0));
        proc_stack.push_back(mxPoint(i, 1));

//        proc_stack.push_back(mxPoint(i, gray->height - 1));   
//        proc_stack.push_back(mxPoint(i, gray->height - 2));
    }
    for (int j = 0; j < gray->height; j++) {
        proc_stack.push_back(mxPoint(0,j));
        proc_stack.push_back(mxPoint(1,j));

        proc_stack.push_back(mxPoint(gray->width - 1,j));      
        proc_stack.push_back(mxPoint(gray->width - 2,j));
    }
    
    int background_color = find_background_color(gray);
    process_image_points(gray, flag, &proc_stack, background_color);
    
    const uchar* fptr = flag->imageData;
    uchar* dptr = image->imageData;
    int width = image->width;
    int height = image->height;
    for( ; height--; fptr += flag->widthStep, dptr += image->widthStep )
    {
        uchar* dst = dptr;
        for (int i = 0; i < width; i++,dst+=image->nChannels) {
            if (fptr[i]==CHECKED_OK) {
                dst[0] = dst[1] = dst[2] = dst[3] = 0;
            }
        }
    }
    
    SAFE_RELEASE_MXIMAGE(gray);
    SAFE_RELEASE_MXIMAGE(flag);
}


#ifdef MX_IOS_SYSTEM
UIImage* removeImageBackground(UIImage* image)
{
    MxImage* tmp = MxImageFromUIImage(image);
    remove_image_background(tmp);
    UIImage* out = UIImageFromMxImage(tmp);
    SAFE_RELEASE_MXIMAGE(tmp);
    return out;
}
#endif




