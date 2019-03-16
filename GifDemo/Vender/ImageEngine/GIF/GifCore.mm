//
//  GifCore.h
//  MicroMessenger
//
//  Created by jakerong on 11-11-1.
//  Copyright 2011年 tencent. All rights reserved.
//
#include "GifCore.h"

#ifndef ASSERT
#define ASSERT(x) 
#endif

////////////////////////////////////////////////////////////////////////// lzw.h
struct LZWContext;

class LZWReader
{
	LZWContext* m_lzw;
	int getCode();
public:
	bool init();
	void release();
public:
	bool open(unsigned char *inbuf, int len,int initCodeSize);
	int read(unsigned char* outbuf,int len);
	unsigned char* seekToEnd();
public:
	LZWReader();
	~LZWReader();
};

////////////////////////////////////////////////////////////////////////// lzw.cpp

#define LZW_MAXBITS                 12
#define LZW_SIZTABLE                (1<<LZW_MAXBITS)
#define LZW_BIT_MASK(s)             ((1<<(s))-1)

struct LZWContext 
{
	unsigned char* pbuf;
	unsigned char* ebuf;

	int bbits;
	unsigned int bbuf;

	int cursize;                ///< The current code size
	int curmask;
	int codesize;
	int clear_code;
	int end_code;
	int newcodes;               ///< First available code
	int top_slot;               ///< Highest code for current size
	int slot;                   ///< Last read code
	int fc, oc;
	unsigned char *sp;
	unsigned char stack[LZW_SIZTABLE];
	unsigned char suffix[LZW_SIZTABLE];
	unsigned short prefix[LZW_SIZTABLE];
	int bs;                     ///< current buffer size for GIF
};

bool LZWReader::init()
{
	if (!m_lzw)
	{
		m_lzw = new LZWContext;
	}
	return m_lzw!=NULL;
}

void LZWReader::release()
{
	MX_SAFE_DELETE(m_lzw);
}

LZWReader::LZWReader()
:m_lzw(NULL)
{

}

LZWReader::~LZWReader()
{
	release();
}

bool LZWReader::open( unsigned char *inbuf, int len, int initCodeSize )
{
	if(initCodeSize < 1 || initCodeSize >= LZW_MAXBITS)
		return false;
	/* read buffer */
	m_lzw->pbuf = inbuf;
	m_lzw->ebuf = m_lzw->pbuf + len;
	m_lzw->bbuf = 0;
	m_lzw->bbits = 0;
	m_lzw->bs = 0;

	/* decoder */
	m_lzw->codesize = initCodeSize;
	m_lzw->cursize = m_lzw->codesize + 1;
	m_lzw->curmask = LZW_BIT_MASK(m_lzw->cursize);
	m_lzw->top_slot = 1 << m_lzw->cursize;
	m_lzw->clear_code = 1 << m_lzw->codesize;
	m_lzw->end_code = m_lzw->clear_code + 1;
	m_lzw->slot = m_lzw->newcodes = m_lzw->clear_code + 2;
	m_lzw->oc = m_lzw->fc = -1;
	m_lzw->sp = m_lzw->stack;

	return true;
}

int LZWReader::read( unsigned char* buf,int len )
{
	int l, c, code, oc, fc;
	unsigned char *sp;

	if (m_lzw->end_code < 0)
		return 0;

	l = len;
	sp = m_lzw->sp;
	oc = m_lzw->oc;
	fc = m_lzw->fc;

	for (;;) {
		while (sp > m_lzw->stack) {
			*buf++ = *(--sp);
			if ((--l) == 0)
				goto the_end;
		}
		c = getCode();
		if (c == m_lzw->end_code) {
			break;
		} else if (c == m_lzw->clear_code) {
			m_lzw->cursize = m_lzw->codesize + 1;
			m_lzw->curmask = LZW_BIT_MASK(m_lzw->cursize);
			m_lzw->slot = m_lzw->newcodes;
			m_lzw->top_slot = 1 << m_lzw->cursize;
			fc= oc= -1;
		} else {
			code = c;
			if (code == m_lzw->slot && fc>=0) {
				*sp++ = fc;
				code = oc;
			}else if(code >= m_lzw->slot)
				break;
			while (code >= m_lzw->newcodes) {
				*sp++ = m_lzw->suffix[code];
				code = m_lzw->prefix[code];
			}
			*sp++ = code;
			if (m_lzw->slot < m_lzw->top_slot && oc>=0) {
				m_lzw->suffix[m_lzw->slot] = code;
				m_lzw->prefix[m_lzw->slot++] = oc;
			}
			fc = code;
			oc = c;
			if (m_lzw->slot >= m_lzw->top_slot) {
				if (m_lzw->cursize < LZW_MAXBITS) {
					m_lzw->top_slot <<= 1;
					m_lzw->curmask = LZW_BIT_MASK(++m_lzw->cursize);
				}
			}
		}
	}
	m_lzw->end_code = -1;
the_end:
	m_lzw->sp = sp;
	m_lzw->oc = oc;
	m_lzw->fc = fc;
	return len - l;
}

unsigned char* LZWReader::seekToEnd()
{
	while(m_lzw->pbuf < m_lzw->ebuf && m_lzw->bs>0){
		m_lzw->pbuf += m_lzw->bs;
		m_lzw->bs = *m_lzw->pbuf++;
	}
	return m_lzw->pbuf;
}

int LZWReader::getCode()
{
	int c;
	while (m_lzw->bbits < m_lzw->cursize) {
		if (!m_lzw->bs) {
			m_lzw->bs = *m_lzw->pbuf++;
		}
		m_lzw->bbuf |= (*m_lzw->pbuf++) << m_lzw->bbits;
		m_lzw->bbits += 8;
		m_lzw->bs--;
	}
	c = m_lzw->bbuf;
	m_lzw->bbuf >>= m_lzw->cursize;
	m_lzw->bbits -= m_lzw->cursize;
	return c & m_lzw->curmask;
}

////////////////////////////////////////////////////////////////////////// gifcore.cpp

#define _ARM_

#ifdef _ARM_
#define GET_BYTE(dst,src) memcpy(&(dst),src,1);dst&=0xFF;
#define GET_WORD(dst,src) memcpy(&(dst),src,2);dst&=0xFFFF;
#define GET_DWORD(dst,src) memcpy(&(dst),src,4);
#else
#define GET_BYTE(dst,src) dst = *src;
#define GET_WORD(dst,src) dst = *((unsigned short*)src);
#define GET_DWORD(dst,src) dst = *((unsigned long*)src);
#endif

GifDecoder::GifDecoder(void)
	:m_pos(NULL)
	,m_maxpos(NULL)
	,m_minpos(NULL)
{
}

GifDecoder::~GifDecoder(void)
{
}

bool GifDecoder::load( unsigned char* buffer,unsigned long len )
{
	if(!(buffer && len>0))return false;
	m_pos = m_minpos = buffer;
	m_maxpos = buffer+len;
	if(m_maxpos-m_pos<13)return false; // Signature(6) + GlobalDescriptor(7)
	// Signature : 'GIF87a' or 'GIF89a' 
	if (!(m_pos[0]=='G' && m_pos[1]=='I' && m_pos[2]=='F' && m_pos[3]=='8' && (m_pos[4]=='7'||m_pos[4]=='9') && m_pos[5]=='a'))return false;
	m_pos+=6;
	//m_width = *((unsigned short*)m_pos);
	GET_WORD(m_width,m_pos);
	m_pos+=2;
	//m_height = *((unsigned short*)m_pos);
	GET_WORD(m_height,m_pos);
	m_pos+=2;
	if (*m_pos&0x80) // has global colormap?
	{
		m_colordepth = ((*m_pos++)&0x7)+1;
		m_colordepth&=0xff;
		m_bkcolor = *m_pos++;
		m_bkcolor&=0xff;
		++m_pos; // ignore AspectRatio
		m_globalcolormap = m_pos;
		m_pos += (1<<m_colordepth)*3;
	}
	else
	{
		// 如果没有全局颜色表，这几个变量都没有意义。
		m_colordepth = -1;
		m_bkcolor = -1;
		m_globalcolormap = NULL;
		m_pos+=3;
	}
	// NETSCAPE2.0块必须紧跟GlobalDescriptor
	if(m_maxpos-m_pos>19&&m_pos[0]==33&&m_pos[1]==255&&m_pos[2]==11&&m_pos[3]=='N'&&m_pos[4]=='E'&&m_pos[5]=='T'&&m_pos[6]=='S'&&m_pos[7]=='C'&&m_pos[8]=='A'&&m_pos[9]=='P'&&m_pos[10]=='E'&&m_pos[11]=='2'&&m_pos[12]=='.'&&m_pos[13]=='0'&&m_pos[14]==3&&m_pos[18]==0)
	{
		//m_loopcount = *((unsigned short*)(m_pos+16));
		GET_WORD(m_loopcount,(m_pos+16));
		if (m_loopcount) // 为0，无限循环。为N，循环N+1次。
		{
			++m_loopcount;
		}
		m_pos+=19;
	}
	else
	{
		// rongkf edit 2010-07-22 <100722150134>{
		// 原因:	有挺多的gif没有按照"NETSCAPE2.0块必须紧跟GlobalDescriptor"的约定做，
		// 所以为了保证最大的兼容性，放弃约定。改为如果未定义，或NETSCAPE2.0没有紧跟GlobalDescriptor，则无限循环。
		m_loopcount = 0; // 未定义，或找不到，则无限循环。
		// 原来的：
		//m_loopcount = 1; // 未定义，只应循环一次
		// rongkf edit 2010-07-22 <100722150134>}
	}
	if(m_pos>m_maxpos)return false;
	return true;
}

int GifDecoder::nextframe( GifFrame& frame,GifExtInfo& ext,bool doLZWDecompress /*= true*/ )
{
	unsigned char flag;
	ASSERT(m_pos>m_minpos);
	while (m_pos>m_minpos&&m_pos<m_maxpos)
	{
		switch (*m_pos++)
		{
		case 0x21: // ExtensionBlock
			{
				// LocalDescriptorExtension (连续两个字节都可读，funcode==249并且size==4)
				if (m_pos<m_maxpos && 249 == *m_pos++ && m_pos<m_maxpos && 4==*m_pos) 
				{
					++m_pos;
					if(m_maxpos-m_pos<4)return 0;
					flag = *m_pos++;
					ext.disposal = (flag>>2)&0x7; // pre draw operation
					if (ext.disposal==4) // 有人用4表示restore previous，也有人用3。这里统一用3。
					{
						ext.disposal=3;
					}
					if (ext.disposal==0||ext.disposal>4) // 0和1一个样，都是leave for overwrite。大于4的情况都没定义，默认设成1。
					{
						ext.disposal=1;
					}
					// 到这里，disposal取值为:
					// 1 - leave for overwrite
					// 2 - restore background
					// 3 - restore previous
					// ext.duration = *((unsigned short*)m_pos);
					GET_WORD(ext.duration,m_pos);
					m_pos+=2;
					if (flag&1) // has transparent color?
					{
						//ext.transcolor = *m_pos++;
						//ext.transcolor&=0xff;
						GET_BYTE(ext.transcolor,m_pos);
						++m_pos;
					}
					else
					{
						++m_pos;
					}
				}
				while(m_pos<m_maxpos && *m_pos++) // skip all others
				{
					m_pos+=*(m_pos-1);
				}
			}
			break;
		case 0x2c: // LocalDescriptor
			{
				if(m_maxpos-m_pos<9)return 0; // LocalDescriptor
				//frame.rect = (GifFrameRect*)m_pos;
				//m_pos+=8;
				GET_WORD(frame.rect.x,m_pos);
				m_pos+=2;
				GET_WORD(frame.rect.y,m_pos);
				m_pos+=2;
				GET_WORD(frame.rect.width,m_pos);
				m_pos+=2;
				GET_WORD(frame.rect.height,m_pos);
				m_pos+=2;
				flag = *m_pos++;
				if (flag&0x80) // has local colormap?
				{
					frame.colormap = m_pos;
					frame.colordepth = (flag&0x7)+1;
					m_pos += (1<<frame.colordepth)*3;
					if(m_pos>=m_maxpos)return 0;
				}
				// raster data block
				if(m_pos>=m_maxpos)return 0;
				if (!doLZWDecompress || !lzwDecompress(frame,0!=(flag&0x40),ext.transcolor<0?0:ext.transcolor))
				{
					++m_pos; // init code size
					while(m_pos<m_maxpos && *m_pos++)
					{
						m_pos+=*(m_pos-1);
					}
				}
				return (m_maxpos-m_pos<9||*m_pos==0x3b)?2:1; // is it last frame?
			}
		default:
			{
				//ASSERT(FALSE);
//				TRACE(_T("[GifDecoder::nextframe]unknow header:%x\n"),*(m_pos-1));
			}
		}
	}
	return 0;
}

void GifDecoder::rewind()
{
	m_pos=m_minpos+13;
	if (m_globalcolormap && m_colordepth>0)
	{
		m_pos+=(1<<m_colordepth)*3;
	}
}

int GifDecoder::lzwDecompress(GifFrame& frame,bool isInterlaced,unsigned char padbyte)
{
	unsigned char initCodeSize = *m_pos++;
	ASSERT(initCodeSize<=12);
	LZWReader lzw;
	if(!lzw.init())return 0;
	if(!lzw.open(m_pos,m_maxpos-m_pos,initCodeSize))
	{
		return 0;
	}
	int width = frame.rect.width;
	int height = frame.rect.height;
	frame.pixelsize = width*height;
	SAFE_DELETE_ARRAY(frame.pixels);
	ASSERT(frame.pixelsize>0);
	frame.pixels = new unsigned char[frame.pixelsize];
	if (frame.pixels)
	{
		const unsigned char* maxpos = frame.pixels+frame.pixelsize; // --rongkf 2010-08-24 edited
		unsigned char* ptr1 = frame.pixels;
		unsigned char* ptr = ptr1;
		int linesize = width;
		int pass = 0;
		int y1 = 0;
		for (int i = 0;i<height;++i)
		{

			// rongkf edit 2010-08-24 <100824165113>{
			// 原因: 高小于4个像素的帧，使用interlace的方式时，会内存越界。顶。
			if (ptr+width>maxpos)
			{
				break;
			}
			// rongkf edit 2010-08-24 <100824165113>}
			int outwidth = lzw.read(ptr,width);
			while(outwidth!=width)
			{
				*(ptr+outwidth) = padbyte;
				++outwidth;
			}
			if (isInterlaced) {
				switch(pass) {
					default:
					case 0:
					case 1:
						y1 += 8;
						ptr += linesize * 8;
						if (y1 >= height) {
							y1 = pass ? 2 : 4;
							ptr = ptr1 + linesize * y1;
							pass++;
						}
						break;
					case 2:
						y1 += 4;
						ptr += linesize * 4;
						if (y1 >= height) {
							y1 = 1;
							ptr = ptr1 + linesize;
							pass++;
						}
						break;
					case 3:
						y1 += 2;
						ptr += linesize * 2;
						break;
				}
			} else {
				ptr += linesize;
			}
		}
	}
	m_pos = lzw.seekToEnd();
	lzw.release();
	return 1;
}

