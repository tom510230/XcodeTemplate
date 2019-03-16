//
//  MxGifImage.c
//  giftest
//
//  Created by jakerong on 11-11-1.
//  Copyright 2011年 tencent. All rights reserved.
//

#include "MxGifImage.h"

struct ColorRGB24
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
};
struct ColorRGBA32
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a;
};

enum GIF_FLAG
{
	GIF_FLAG_SINGLE_FRAME    = 0x01,
	GIF_FLAG_TRANSPARENT_IMG = 0x02,
	GIF_FLAG_ERROR_IMG       = 0x04,
	GIF_FLAG_REWIND_MARK     = 0x08,
	GIF_FLAG_LOOP_END        = 0x10,
};

// get current time as ms. implement this for different system.
unsigned long MxGifGetCurrentTickCount()
{
#ifdef MX_IOS_SYSTEM
    unsigned long long time = CFAbsoluteTimeGetCurrent()*1000;
    time = time << 32;
    time = time >> 32;
    return time;
#else
    return GetTickCount();
#endif
}

int MxGifImage::getFrame()
{
	if(!m_gif)return 0;
	GifFrame* frame = new GifFrame;
	if (!frame)
	{
		return 0;
	}
	if (m_flag&GIF_FLAG_REWIND_MARK)
	{
		m_id = 0;
		m_extinfo.duration=10;
		m_extinfo.disposal = 1;
		m_extinfo.transcolor = -1;
		m_lastRect.x = 0;
        m_lastRect.y = 0;
        m_lastRect.width = 0;
        m_lastRect.height = 0;
		m_lastDisposal = 1;
        mxZero(m_img);
	}
	int ret = m_gif->nextframe(*frame,m_extinfo);
	if (ret)
	{
		bool isFullFrame = (frame->rect.x==0&&frame->rect.y==0&&frame->rect.width==m_gif->m_width&&frame->rect.height==m_gif->m_height);
		if (m_extinfo.transcolor>=0||!isFullFrame)
		{
			m_flag |= GIF_FLAG_TRANSPARENT_IMG;
		}
		if ((m_flag&GIF_FLAG_REWIND_MARK)&&ret==2)
		{
			m_flag |= GIF_FLAG_SINGLE_FRAME;
		}
		//m_flag |= GIF_FLAG_TRANSPARENT_IMG;
		if (m_extinfo.duration<4)
		{
			m_extinfo.duration = 10;
		}
		// dispose
		if (m_lastDisposal==2) // 上一帧的disposal为restore background的情况下,恢复上一帧所在位置背景透明。
		{
            const GifFrameRect& rect = m_lastRect;
            MxImage* bmp = m_img;
            
            if(rect.y<bmp->height&&0<rect.y+rect.height&&rect.x<bmp->width&&0<rect.x+rect.width)
            {
                int xx = MAX(rect.x, 0);
                int yy = MAX(rect.y, 0);
                int width = MIN(rect.x+rect.width, bmp->width) - xx;
                int height = MIN(rect.y+rect.height, bmp->height) - yy;
                
                uchar* dptr = (bmp->imageData + bmp->widthStep*yy + xx*bmp->nChannels);
                
                for( ; height--; dptr += bmp->widthStep )
                {
                    int i = 0;
                    
                    for( ; i < width; i++ )
                    {
                        ColorRGBA32* d = (ColorRGBA32*)((dptr)+(i*4));
                        d->r = 0;
                        d->g = 0;
                        d->b = 0;
                        d->a = 0;
                    }
                }
            }
		}
        
        if (m_lastDisposal==3 && m_bak) // 上一帧的disposal为restore previous的情况下,恢复上一帧所在位置为bak。
		{
            const GifFrameRect& rect = m_lastRect;
            MxImage* bmp = m_img;
            
            if(rect.y<bmp->height&&0<rect.y+rect.height&&rect.x<bmp->width&&0<rect.x+rect.width)
            {
                int xx = MAX(rect.x, 0);
                int yy = MAX(rect.y, 0);
                int width = MIN(rect.x+rect.width, bmp->width) - xx;
                int height = MIN(rect.y+rect.height, bmp->height) - yy;
                
                uchar* sptr = m_bak->imageData + rect.width*(yy-rect.y) + (xx-rect.x)*m_bak->nChannels;
                uchar* dptr = (bmp->imageData + bmp->widthStep*yy + xx*bmp->nChannels);
                
                int lineWidth = width*4;
                
                for( ; height--; sptr+=m_bak->widthStep, dptr += bmp->widthStep )
                {
                    memcpy(dptr, sptr, lineWidth);
                }
            }
		}

		SAFE_RELEASE_MXIMAGE(m_bak); // 如果有，清除上一个m_bak。(m_lastDisposal==3，丢弃上一帧)
		// draw frame
		if (m_extinfo.disposal==3) // 当前disposal为restore previous，备份所在位置到m_bak。
		{
			m_bak = mxCreateImage(frame->rect.width, frame->rect.height, 4);
            
			if(m_bak)
			{
                const GifFrameRect& rect = frame->rect;
                MxImage* bmp = m_img;
                
                if(rect.y<bmp->height&&0<rect.y+rect.height&&rect.x<bmp->width&&0<rect.x+rect.width)
                {
                    int xx = MAX(rect.x, 0);
                    int yy = MAX(rect.y, 0);
                    int width = MIN(rect.x+rect.width, bmp->width) - xx;
                    int height = MIN(rect.y+rect.height, bmp->height) - yy;
                    
                    uchar* sptr = m_bak->imageData + rect.width*(yy-rect.y) + (xx-rect.x)*m_bak->nChannels;
                    uchar* dptr = (bmp->imageData + bmp->widthStep*yy + xx*bmp->nChannels);
                    
                    int lineWidth = width*4;
                    
                    for( ; height--; sptr+=m_bak->widthStep, dptr += bmp->widthStep )
                    {
                        memcpy(sptr, dptr, lineWidth);
                    }
                }
			}
		}

        fillImage(m_img,*frame,m_extinfo.transcolor);
        
		m_lastDisposal = m_extinfo.disposal;
		//m_lastRect = frame->rect;
		m_lastRect.x = frame->rect.x;
		m_lastRect.y = frame->rect.y;
		m_lastRect.width = frame->rect.width;
		m_lastRect.height = frame->rect.height;
	}
	if (m_flag&GIF_FLAG_REWIND_MARK)
	{
		m_flag &=(~GIF_FLAG_REWIND_MARK);
	}
	delete frame;
	return ret;
}

void MxGifImage::fillImage(MxImage* bmp, const GifFrame & frame, int transcolor)
{
	int depth;
	unsigned char* pal;
	if (frame.colormap)
	{
		pal = frame.colormap;
		depth = frame.colordepth;
	}
	else
	{
		pal = m_gif->m_globalcolormap;
		depth = m_gif->m_colordepth;
	}
	if(!pal)return;
	if (!frame.pixels)return; // --rongkf 2010-08-23 edited
	const GifFrameRect& rect = frame.rect;
    
    if(!((rect.y<bmp->height)&&(0<rect.y+rect.height)))return;
    if(!((rect.x<bmp->width)&&(0<rect.x+rect.width)))return;
    
    int xx = MAX(rect.x, 0);
    int yy = MAX(rect.y, 0);
    int width = MIN(rect.x+rect.width, bmp->width) - xx;
    int height = MIN(rect.y+rect.height, bmp->height) - yy;

	unsigned long mask = (1<<depth)-1;
    
    const uchar* sptr = frame.pixels + rect.width*(yy-rect.y) + (xx-rect.x);
    uchar* dptr = (bmp->imageData + bmp->widthStep*yy + xx*bmp->nChannels);

    for( ; height--; sptr += rect.width, dptr += bmp->widthStep )
    {
        int i = 0;
        
        for( ; i < width; i++ )
        {
            int index = *(sptr+i);
            if (index!=transcolor)
            {
                index = index&mask;
                ColorRGB24* s = (ColorRGB24*)((pal)+(index*3));
                ColorRGBA32* d = (ColorRGBA32*)((dptr)+(i*4));
                d->r = s->r;
                d->g = s->g;
                d->b = s->b;
                d->a = 255;
            }
            
        }
    }
}

void MxGifImage::flashFrameWithInnerTick()
{
    unsigned long timetick = MxGifGetCurrentTickCount();
    flashFrame(timetick);
}

void MxGifImage::flashFrame(unsigned long timetick)
{
	if (m_flag&(GIF_FLAG_ERROR_IMG|GIF_FLAG_SINGLE_FRAME|GIF_FLAG_LOOP_END))return;
	if(!m_gif)return;
	if ((timetick - m_lastTimeTick)>(unsigned long)(m_extinfo.duration*10))
	{
		m_lastTimeTick = timetick;
		switch(getFrame())
		{
            case 1:
			{
				++m_id;
			}
                break;
            case 0:
            case 2:
			{
				m_id = 0;
				if (--m_gif->m_loopcount) // 如果m_loopcount==0循环2**32次。
				{
					m_gif->rewind();
					m_flag |= GIF_FLAG_REWIND_MARK;
				}
				else
				{
					m_flag |= GIF_FLAG_LOOP_END;
				}
			}
                break;
            default:
			{
			}
		}
	}
}

void MxGifImage::flashFrameIgnoreTick()
{
    int res = getFrame();
    switch(res)
    {
        case 1:
        {
            ++m_id;
        }
            break;
        case 0:
        case 2:
        {
            m_id = 0;
            if (--m_gif->m_loopcount) // 如果m_loopcount==0循环2**32次。
            {
                m_gif->rewind();
                m_flag |= GIF_FLAG_REWIND_MARK;
            }
            else
            {
                m_flag |= GIF_FLAG_LOOP_END;
            }
            return;
        }
            break;
        default:
        {
            return;                
        }
    }
}

void MxGifImage::seedToEnd()
{
    int res;
    while (1) {
        res = getFrame();
        switch(res)
		{
            case 1:
			{
				++m_id;
			}
                break;
            case 0:
            case 2:
			{
				m_id = 0;
				if (--m_gif->m_loopcount) // 如果m_loopcount==0循环2**32次。
				{
					m_gif->rewind();
					m_flag |= GIF_FLAG_REWIND_MARK;
				}
				else
				{
					m_flag |= GIF_FLAG_LOOP_END;
				}
                return;
			}
                break;
            default:
			{
                return;                
			}
		}
    }
}

bool MxGifImage::loadFromBufferNoCopy(uchar* buf,int len )
{
	m_flag = GIF_FLAG_ERROR_IMG;
	releaseDecode();
    
	m_gif = new GifDecoder;
	if(!m_gif)return false;
	if(!m_gif->load((unsigned char*)buf,len))return false;

	SAFE_RELEASE_MXIMAGE(m_img);
	m_img = mxCreateImage(m_gif->m_width, m_gif->m_height, 4);

	m_flag |= GIF_FLAG_REWIND_MARK;
    m_lastTimeTick = MxGifGetCurrentTickCount();
	int s = getFrame();
	if (s==0)
	{
		return false;
	}
	else
	{
		m_flag &= (~GIF_FLAG_ERROR_IMG);
	}
	if (m_flag&GIF_FLAG_SINGLE_FRAME)
	{
        // single frame
	}
	return true;
}

bool MxGifImage::isSingleFrameImage()
{
    return (m_flag&GIF_FLAG_SINGLE_FRAME);
}

int MxGifImage::frameID()
{
	return m_gif?m_id:-1;
}

int MxGifImage::width()
{
    return m_gif?m_gif->m_width:0;
}

int MxGifImage::height()
{
    return m_gif?m_gif->m_height:0;
}

MxImage* MxGifImage::image()
{
    return m_img;
}

int MxGifImage::duration()
{
    return m_extinfo.duration*10;
}

void MxGifImage::releaseDecode()
{
    MX_SAFE_DELETE(m_gif);
    SAFE_RELEASE_MXIMAGE(m_img);
    SAFE_RELEASE_MXIMAGE(m_bak);
}

MxGifImage::MxGifImage()
:m_gif(NULL)
,m_flag(0)
,m_img(NULL)
,m_bak(NULL)
,m_lastDisposal(0)
,m_id(-1)
,m_lastTimeTick(0)
{

}

MxGifImage::~MxGifImage()
{
    releaseDecode();
}
