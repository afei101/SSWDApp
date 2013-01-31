#include "Crypt.h"
//#include "QSysUtil.h"
#include "stdio.h"
#include "string.h"
#include "stdlib.h"
#include <time.h>

#ifndef L_ENDIAN
#define L_ENDIAN
#endif


#ifndef ULONG
typedef unsigned long ULONG;
#endif



#define QWORD_MAX	65534

/////////////////////////////////////////////////////
// set short to point
/////////////////////////////////////////////////////
void SetShort( unsigned char* to, short from )
{
	to[0] = (unsigned char)(from>>8);
	to[1] = (unsigned char)(from);
}

/////////////////////////////////////////////////////
// set long to point
/////////////////////////////////////////////////////
void SetLong( unsigned char* to, long from )
{
	to[0] = (unsigned char)(from>>24);
	to[1] = (unsigned char)(from>>16);
	to[2] = (unsigned char)(from>>8);
	to[3] = (unsigned char)(from);
}

void SetLongLong( unsigned char* to, long long from )
{
	to[0] = (unsigned char)(from>>56);
	to[1] = (unsigned char)(from>>48);
	to[2] = (unsigned char)(from>>40);
	to[3] = (unsigned char)(from>>32);
	to[4] = (unsigned char)(from>>24);
	to[5] = (unsigned char)(from>>16);
	to[6] = (unsigned char)(from>>8);
	to[7] = (unsigned char)(from);
}

short htos_net(short mform)
{
	short nTmp = 0;
	SetShort((unsigned char*)&nTmp, mform);
	return nTmp;
}

long htol_net(long mform)
{
	long nTmp = 0;
	SetLong((unsigned char*)&nTmp, mform);
	return nTmp;
}

long long htol_net(long long mform)
{
	long long nTmp = 0;
	SetLongLong((unsigned char*)&nTmp, mform);
	return nTmp;
}

/////////////////////////////////////////////////////
// get short from point
/////////////////////////////////////////////////////
void GetShort(short &to, unsigned char * from)
{
	*(unsigned char *)(&to) = *(from + 1);
	*((unsigned char *)(&to)+1) = *from;
}
/////////////////////////////////////////////////////
// set long from point
/////////////////////////////////////////////////////
void GetLong(long &to, unsigned char * from)
{
	*(unsigned char *)(&to) = *(from + 3);
	*((unsigned char *)(&to)+1) = *(from+2);
	*((unsigned char *)(&to)+2) = *(from + 1);
	*((unsigned char *)(&to)+3) = *from;
}

/*
***********************************************************************************************
	MD5 ˝æ›Ω·ππ
***********************************************************************************************
*/


/*
	MD5≥ı ºªØ
*/

#define INIT_DATA_A (unsigned long)0x67452301L
#define INIT_DATA_B (unsigned long)0xefcdab89L
#define INIT_DATA_C (unsigned long)0x98badcfeL
#define INIT_DATA_D (unsigned long)0x10325476L


void CCrypt::MD5_Init(MD5_CTX2 *c)
{
	memset(c,0,sizeof(MD5_CTX2));
	c->A=INIT_DATA_A;
	c->B=INIT_DATA_B;
	c->C=INIT_DATA_C;
	c->D=INIT_DATA_D;
	c->Nl=0;
	c->Nh=0;
	c->num=0;
}



/*
	MD5∏¸–¬
*/
#define MD5_CBLOCK	64

#define c2l(c,l)	(l = ((unsigned long)(*((c)++))), l|=(((unsigned long)(*((c)++)))<< 8), l|=(((unsigned long)(*((c)++)))<<16), l|=(((unsigned long)(*((c)++)))<<24))

#define p_c2l(c,l,n)	{ switch (n) { case 0: l =((unsigned long)(*((c)++))); case 1: l|=((unsigned long)(*((c)++)))<< 8; case 2: l|=((unsigned long)(*((c)++)))<<16; case 3: l|=((unsigned long)(*((c)++)))<<24; } }

#define p_c2l_p(c,l,sc,len) { switch (sc) { case 0: l =((unsigned long)(*((c)++))); if (--len == 0) break; case 1: l|=((unsigned long)(*((c)++)))<< 8; if (--len == 0) break; case 2: l|=((unsigned long)(*((c)++)))<<16; } }

#define c2l_p(c,l,n)	{ l=0; (c)+=n; switch (n) { case 3: l =((unsigned long)(*(--(c))))<<16; case 2: l|=((unsigned long)(*(--(c))))<< 8; case 1: l|=((unsigned long)(*(--(c))))    ; } }


#define	F(b,c,d)	((((c) ^ (d)) & (b)) ^ (d))
#define	G(b,c,d)	((((b) ^ (c)) & (d)) ^ (c))
#define	H(b,c,d)	((b) ^ (c) ^ (d))
#define	I(b,c,d)	(((~(d)) | (b)) ^ (c))

/*
‘⁄Win32œ¬º”ÀŸ
#if defined(WIN32)
#define ROTATE(a,n)     _lrotl(a,n)
#else
#define ROTATE(a,n)     (((a)<<(n))|(((a)&0xffffffffL)>>(32-(n))))
#endif
*/


#if defined(WIN32)
#define ROTATE(a,n)     (((a)<<(n))|((a)>>(32-(n))))
#else
#define ROTATE(a,n)     (((a)<<(n))|(((a)&0xffffffffL)>>(32-(n))))
#endif


#define R0(a,b,c,d,k,s,t) { a+=((k)+(t)+F((b),(c),(d))); a=ROTATE(a,s); a+=b; };
#define R1(a,b,c,d,k,s,t) { a+=((k)+(t)+G((b),(c),(d))); a=ROTATE(a,s); a+=b; };

#define R2(a,b,c,d,k,s,t) { a+=((k)+(t)+H((b),(c),(d))); a=ROTATE(a,s); a+=b; };

#define R3(a,b,c,d,k,s,t) { a+=((k)+(t)+I((b),(c),(d))); a=ROTATE(a,s); a+=b; };

#ifndef MD5_ASM

static void md5_block(MD5_CTX2 *c, register ULONG *X, int num)
{
	register ULONG A,B,C,D;
	
	A=c->A;
	B=c->B;
	C=c->C;
	D=c->D;
	for (;;)
	{
		num-=64;
		if (num < 0) break;
		/* Round 0 */
		R0(A,B,C,D,X[ 0], 7,0xd76aa478L);
		R0(D,A,B,C,X[ 1],12,0xe8c7b756L);
		R0(C,D,A,B,X[ 2],17,0x242070dbL);
		R0(B,C,D,A,X[ 3],22,0xc1bdceeeL);
		R0(A,B,C,D,X[ 4], 7,0xf57c0fafL);
		R0(D,A,B,C,X[ 5],12,0x4787c62aL);
		R0(C,D,A,B,X[ 6],17,0xa8304613L);
		R0(B,C,D,A,X[ 7],22,0xfd469501L);
		R0(A,B,C,D,X[ 8], 7,0x698098d8L);
		R0(D,A,B,C,X[ 9],12,0x8b44f7afL);
		R0(C,D,A,B,X[10],17,0xffff5bb1L);
		R0(B,C,D,A,X[11],22,0x895cd7beL);
		R0(A,B,C,D,X[12], 7,0x6b901122L);
		R0(D,A,B,C,X[13],12,0xfd987193L);
		R0(C,D,A,B,X[14],17,0xa679438eL);
		R0(B,C,D,A,X[15],22,0x49b40821L);
		/* Round 1 */
		R1(A,B,C,D,X[ 1], 5,0xf61e2562L);
		R1(D,A,B,C,X[ 6], 9,0xc040b340L);
		R1(C,D,A,B,X[11],14,0x265e5a51L);
		R1(B,C,D,A,X[ 0],20,0xe9b6c7aaL);
		R1(A,B,C,D,X[ 5], 5,0xd62f105dL);
		R1(D,A,B,C,X[10], 9,0x02441453L);
		R1(C,D,A,B,X[15],14,0xd8a1e681L);
		R1(B,C,D,A,X[ 4],20,0xe7d3fbc8L);
		R1(A,B,C,D,X[ 9], 5,0x21e1cde6L);
		R1(D,A,B,C,X[14], 9,0xc33707d6L);
		R1(C,D,A,B,X[ 3],14,0xf4d50d87L);
		R1(B,C,D,A,X[ 8],20,0x455a14edL);
		R1(A,B,C,D,X[13], 5,0xa9e3e905L);
		R1(D,A,B,C,X[ 2], 9,0xfcefa3f8L);
		R1(C,D,A,B,X[ 7],14,0x676f02d9L);
		R1(B,C,D,A,X[12],20,0x8d2a4c8aL);
		/* Round 2 */
		R2(A,B,C,D,X[ 5], 4,0xfffa3942L);
		R2(D,A,B,C,X[ 8],11,0x8771f681L);
		R2(C,D,A,B,X[11],16,0x6d9d6122L);
		R2(B,C,D,A,X[14],23,0xfde5380cL);
		R2(A,B,C,D,X[ 1], 4,0xa4beea44L);
		R2(D,A,B,C,X[ 4],11,0x4bdecfa9L);
		R2(C,D,A,B,X[ 7],16,0xf6bb4b60L);
		R2(B,C,D,A,X[10],23,0xbebfbc70L);
		R2(A,B,C,D,X[13], 4,0x289b7ec6L);
		R2(D,A,B,C,X[ 0],11,0xeaa127faL);
		R2(C,D,A,B,X[ 3],16,0xd4ef3085L);
		R2(B,C,D,A,X[ 6],23,0x04881d05L);
		R2(A,B,C,D,X[ 9], 4,0xd9d4d039L);
		R2(D,A,B,C,X[12],11,0xe6db99e5L);
		R2(C,D,A,B,X[15],16,0x1fa27cf8L);
		R2(B,C,D,A,X[ 2],23,0xc4ac5665L);
		/* Round 3 */
		R3(A,B,C,D,X[ 0], 6,0xf4292244L);
		R3(D,A,B,C,X[ 7],10,0x432aff97L);
		R3(C,D,A,B,X[14],15,0xab9423a7L);
		R3(B,C,D,A,X[ 5],21,0xfc93a039L);
		R3(A,B,C,D,X[12], 6,0x655b59c3L);
		R3(D,A,B,C,X[ 3],10,0x8f0ccc92L);
		R3(C,D,A,B,X[10],15,0xffeff47dL);
		R3(B,C,D,A,X[ 1],21,0x85845dd1L);
		R3(A,B,C,D,X[ 8], 6,0x6fa87e4fL);
		R3(D,A,B,C,X[15],10,0xfe2ce6e0L);
		R3(C,D,A,B,X[ 6],15,0xa3014314L);
		R3(B,C,D,A,X[13],21,0x4e0811a1L);
		R3(A,B,C,D,X[ 4], 6,0xf7537e82L);
		R3(D,A,B,C,X[11],10,0xbd3af235L);
		R3(C,D,A,B,X[ 2],15,0x2ad7d2bbL);
		R3(B,C,D,A,X[ 9],21,0xeb86d391L);
		
		A+=c->A&0xffffffffL;
		B+=c->B&0xffffffffL;
		c->A=A;
		c->B=B;
		C+=c->C&0xffffffffL;
		D+=c->D&0xffffffffL;
		c->C=C;
		c->D=D;
		X+=16;
	}
}
#endif


void CCrypt::MD5_Update(MD5_CTX2 *c, const register unsigned char *data, unsigned long len)
{
	register ULONG *p;
	int sw,sc;
	ULONG l;
	
	if (len == 0) return;
	
	l=(c->Nl+(len<<3))&0xffffffffL;
	/* 95-05-24 eay Fixed a bug with the overflow handling, thanks to
	* Wei Dai <weidai@eskimo.com> for pointing it out. */
	if (l < c->Nl) /* overflow */
		c->Nh++;
	c->Nh+=(len>>29);
	c->Nl=l;
	
	if (c->num != 0)
	{
		p=c->data;
		sw=c->num>>2;
		sc=c->num&0x03;
		
		if ((c->num+len) >= MD5_CBLOCK)
		{
			l= p[sw];
			p_c2l(data,l,sc);
			p[sw++]=l;
			for (; sw<MD5_LBLOCK; sw++)
			{
				c2l(data,l);
				p[sw]=l;
			}
			len-=(MD5_CBLOCK-c->num);
			
			md5_block(c,p,64);
			c->num=0;
			/* drop through and do the rest */
		}
		else
		{
			int ew,ec;
			
			c->num+=(int)len;
			if ((sc+len) < 4) /* ugly, add char's to a word */
			{
				l= p[sw];
				p_c2l_p(data,l,sc,len);
				p[sw]=l;
			}
			else
			{
				ew=(c->num>>2);
				ec=(c->num&0x03);
				l= p[sw];
				p_c2l(data,l,sc);
				p[sw++]=l;
				for (; sw < ew; sw++)
				{ c2l(data,l); p[sw]=l; }
				if (ec)
				{
					c2l_p(data,l,ec);
					p[sw]=l;
				}
			}
			return;
		}
	}

	/* we now can process the input data in blocks of MD5_CBLOCK
	* chars and save the leftovers to c->data. */
#ifdef L_ENDIAN
	if ((((unsigned int)data)%sizeof(ULONG)) == 0)
	{
		sw=len/MD5_CBLOCK;
		if (sw > 0)
		{
			sw*=MD5_CBLOCK;
			md5_block(c,(ULONG *)data,sw);
			data+=sw;
			len-=sw;
		}
	}
#endif
	p=c->data;
	while (len >= MD5_CBLOCK)
	{
#if defined(L_ENDIAN) || defined(B_ENDIAN)
		if (p != (unsigned long *)data)
			memcpy(p,data,MD5_CBLOCK);
		data+=MD5_CBLOCK;
#ifdef B_ENDIAN
		for (sw=(MD5_LBLOCK/4); sw; sw--)
		{
			Endian_Reverse32(p[0]);
			Endian_Reverse32(p[1]);
			Endian_Reverse32(p[2]);
			Endian_Reverse32(p[3]);
			p+=4;
		}
#endif
#else
		for (sw=(MD5_LBLOCK/4); sw; sw--)
		{
			c2l(data,l); *(p++)=l;
			c2l(data,l); *(p++)=l;
			c2l(data,l); *(p++)=l;
			c2l(data,l); *(p++)=l; 
		} 
#endif
		p=c->data;
		md5_block(c,p,64);
		len-=MD5_CBLOCK;
	}
	sc=(int)len;
	c->num=sc;
	if (sc)
	{
		sw=sc>>2;	/* words to copy */
#ifdef L_ENDIAN
		p[sw]=0;
		memcpy(p,data,sc);
#else
		sc&=0x03;
		for ( ; sw; sw--)
		{ c2l(data,l); *(p++)=l; }
		c2l_p(data,l,sc);
		*p=l;
#endif
	}
}



/*
	MD5Ω· ¯
*/
#define MD5_LAST_BLOCK  56

#define l2c(l,c)	(*((c)++)=(unsigned char)(((l)     )&0xff), *((c)++)=(unsigned char)(((l)>> 8L)&0xff), *((c)++)=(unsigned char)(((l)>>16L)&0xff), *((c)++)=(unsigned char)(((l)>>24L)&0xff))


void CCrypt::MD5_Final(unsigned char *md, MD5_CTX2 *c)
{
	register int i,j;
	register ULONG l;
	register ULONG *p;
	unsigned char end[4]={0x80,0x00,0x00,0x00};
	unsigned char *cp=end;
	
	/* c->num should definitly have room for at least one more unsigned char. */
	p=c->data;
	j=c->num;
	i=j>>2;
	
	/* purify often complains about the following line as an
	* Uninitialized Memory Read.  While this can be true, the
	* following p_c2l macro will reset l when that case is true.
	* This is because j&0x03 contains the number of 'valid' unsigned chars
	* already in p[i].  If and only if j&0x03 == 0, the UMR will
	* occur but this is also the only time p_c2l will do
	* l= *(cp++) instead of l|= *(cp++)
	* Many thanks to Alex Tang <altitude@cic.net> for pickup this
	* 'potential bug' */
#ifdef PURIFY
	if ((j&0x03) == 0) p[i]=0;
#endif
	l=p[i];
	p_c2l(cp,l,j&0x03);
	p[i]=l;
	i++;
	/* i is the next 'undefined word' */
	if (c->num >= MD5_LAST_BLOCK)
	{
		for (; i<MD5_LBLOCK; i++)
			p[i]=0;
		md5_block(c,p,64);
		i=0;
	}
	for (; i<(MD5_LBLOCK-2); i++)
		p[i]=0;
	p[MD5_LBLOCK-2]=c->Nl;
	p[MD5_LBLOCK-1]=c->Nh;
	md5_block(c,p,64);
	cp=md;
	l=c->A; l2c(l,cp);
	l=c->B; l2c(l,cp);
	l=c->C; l2c(l,cp);
	l=c->D; l2c(l,cp);
	
	/* clear stuff, md5_block may be leaving some stuff on the stack
	* but I'm not worried :-) */
	c->num=0;
	/*	memset((char *)&c,0,sizeof(c));*/
}


#define SALT_LEN 2
#define ZERO_LEN 7

#define ROUNDS 16
#define LOG_ROUNDS 4
const unsigned long DELTA = 0x9e3779b9;

static void TeaEncryptECB(const unsigned char *pInBuf, const unsigned char *pKey, unsigned char *pOutBuf)
{
	unsigned long y, z;
	unsigned long sum;
	unsigned long k[4];
	int i;

	/*plain-text is TCP/IP-endian;*/

	/*GetBlockBigEndian(in, y, z);*/
	//y = ntohl(*((QDWORD*)pInBuf));
	GetLong((long &)y,(unsigned char *)pInBuf);
	//z = ntohl(*((QDWORD*)(pInBuf+4)));
	GetLong((long &)z,(unsigned char *)(pInBuf+4));
	/*TCP/IP network unsigned char order (which is big-endian).*/

	for ( i = 0; i<4; i++)
	{
		/*now key is TCP/IP-endian;*/
	//	k[i] = ntohl(*((QDWORD*)(pKey+i*4)));
		GetLong((long &)k[i],(unsigned char *)(pKey+i*4));
	}

	sum = 0;
	for (i=0; i<ROUNDS; i++)
	{   
		sum += DELTA;
		y += (z << 4) + k[0] ^ z + sum ^ (z >> 5) + k[1];
		z += (y << 4) + k[2] ^ y + sum ^ (y >> 5) + k[3];
	}



	//*((QDWORD*)pOutBuf) = htonl(y);
	SetLong(pOutBuf,y);

//	*((QDWORD*)(pOutBuf+4)) = htonl(z);
	SetLong(pOutBuf+4,z);	

	/*now encrypted buf is TCP/IP-endian;*/
}

static void TeaDecryptECB(const unsigned char *pInBuf, const unsigned char *pKey, unsigned char *pOutBuf)
{
	unsigned long y, z, sum;
	unsigned long k[4];
	int i;

	/*now encrypted buf is TCP/IP-endian;*/
	/*TCP/IP network unsigned char order (which is big-endian).*/
//	y = ntohl(*((QDWORD*)pInBuf));
	GetLong((long &)y,(unsigned char *)pInBuf);

//	z = ntohl(*((QDWORD*)(pInBuf+4)));

	GetLong((long &)z,(unsigned char *)(pInBuf+4));

	for ( i=0; i<4; i++)
	{
		/*key is TCP/IP-endian;*/
//		k[i] = ntohl(*((QDWORD*)(pKey+i*4)));
		GetLong((long &)k[i],(unsigned char *)(pKey+i*4));
	}

	sum = DELTA << LOG_ROUNDS;
	for (i=0; i<ROUNDS; i++)
	{
		z -= (y << 4) + k[2] ^ y + sum ^ (y >> 5) + k[3]; 
		y -= (z << 4) + k[0] ^ z + sum ^ (z >> 5) + k[1];
		sum -= DELTA;
	}

	//*((QDWORD*)pOutBuf) = htonl(y);
	SetLong(pOutBuf,y);
	
	//*((QDWORD*)(pOutBuf+4)) = htonl(z);
	SetLong(pOutBuf+4,z);
	/*now plain-text is TCP/IP-endian;*/
}


CCrypt::CCrypt()
{
	m_nEncryptArith = CRYPT_3;
	m_nDecryptArith = CRYPT_2;
}

CCrypt::~CCrypt()
{

}

CCrypt::CCrypt(unsigned char *pKey,unsigned char nEncryptArith,unsigned char nDecryptArith)
{
	m_nEncryptArith = nEncryptArith;
	m_nDecryptArith = nDecryptArith;
	memcpy(m_arKey,pKey,SESSION_KEY_SIZE);
//	CQSysUtil::InitRand();
}

void CCrypt::Encrypt(const unsigned char* pInBuf, int nInBufLen, unsigned char* pOutBuf, int& nOutBufLen)
{
	if(m_nEncryptArith ==CRYPT_2)	
	{
		int nPadSaltBodyZeroLen/*PadLen(1unsigned char)+Salt+Body+Zeroµƒ≥§∂»*/;
		int nPadlen;
		unsigned char src_buf[8], iv_plain[8], *iv_crypt;
		int src_i, i, j;

		/*∏˘æ›Body≥§∂»º∆À„PadLen,◊Ó–°±ÿ–Ë≥§∂»±ÿ–ËŒ™8unsigned charµƒ’˚ ˝±∂*/
		nPadSaltBodyZeroLen = nInBufLen/*Body≥§∂»*/+1+SALT_LEN+ZERO_LEN/*PadLen(1unsigned char)+Salt(2unsigned char)+Zero(7unsigned char)*/;
		if(nPadlen=nPadSaltBodyZeroLen%8) /*len=nSaltBodyZeroLen%8*/
		{
			/*ƒ£8”‡0–Ë≤π0,”‡1≤π7,”‡2≤π6,...,”‡7≤π1*/
			nPadlen=8-nPadlen;
		}
		srand( (unsigned)time( NULL ) ); 
		/*srand( (unsigned)time( NULL ) ); ≥ı ºªØÀÊª˙ ˝*/
		/*º”√‹µ⁄“ªøÈ ˝æ›(8unsigned char),»°«∞√Ê10unsigned char*/
		src_buf[0] = ((unsigned char)(rand()%QWORD_MAX)) & 0x0f8/*◊ÓµÕ»˝Œª¥ÊPadLen,«Â¡„*/ | (unsigned char)nPadlen;
		src_i = 1; /*src_i÷∏œÚsrc_bufœ¬“ª∏ˆŒª÷√*/

		while(nPadlen--)
			src_buf[src_i++]=(unsigned char)(rand()%QWORD_MAX); /*Padding*/

		/*come here, src_i must <= 8*/

		for ( i=0; i<8; i++)
			iv_plain[i] = 0;
		iv_crypt = iv_plain; /*make zero iv*/

		nOutBufLen = 0; /*init OutBufLen*/

		for (i=1;i<=SALT_LEN;) /*Salt(2unsigned char)*/
		{
			if (src_i<8)
			{
				src_buf[src_i++]=(unsigned char)(rand()%QWORD_MAX);
				i++; /*i inc in here*/
			}

			if (src_i==8)
			{
				/*src_i==8*/

				for (j=0;j<8;j++) /*º”√‹«∞“ÏªÚ«∞8∏ˆunsigned charµƒ√‹Œƒ(iv_crypt÷∏œÚµƒ)*/
					src_buf[j]^=iv_crypt[j];

				/*pOutBuffer°¢pInBufferæ˘Œ™8unsigned char, &m_arKeyŒ™16unsigned char*/
				/*º”√‹*/
				TeaEncryptECB(src_buf, m_arKey, pOutBuf);

				for (j=0;j<8;j++) /*º”√‹∫Û“ÏªÚ«∞8∏ˆunsigned charµƒ√˜Œƒ(iv_plain÷∏œÚµƒ)*/
					pOutBuf[j]^=iv_plain[j];

				/*±£¥Êµ±«∞µƒiv_plain*/
				for (j=0;j<8;j++)
					iv_plain[j]=src_buf[j];

				/*∏¸–¬iv_crypt*/
				src_i=0;
				iv_crypt=pOutBuf;
				nOutBufLen+=8;
				pOutBuf+=8;
			}
		}

		/*src_i÷∏œÚsrc_bufœ¬“ª∏ˆŒª÷√*/

		while(nInBufLen)
		{
			if (src_i<8)
			{
				src_buf[src_i++]=*(pInBuf++);
				nInBufLen--;
			}

			if (src_i==8)
			{
				/*src_i==8*/
				
				for (j=0;j<8;j++) /*º”√‹«∞“ÏªÚ«∞8∏ˆunsigned charµƒ√‹Œƒ(iv_crypt÷∏œÚµƒ)*/
					src_buf[j]^=iv_crypt[j];
				/*pOutBuffer°¢pInBufferæ˘Œ™8unsigned char, &m_arKeyŒ™16unsigned char*/
				TeaEncryptECB(src_buf, m_arKey, pOutBuf);

				for (j=0;j<8;j++) /*º”√‹∫Û“ÏªÚ«∞8∏ˆunsigned charµƒ√˜Œƒ(iv_plain÷∏œÚµƒ)*/
					pOutBuf[j]^=iv_plain[j];

				/*±£¥Êµ±«∞µƒiv_plain*/
				for (j=0;j<8;j++)
					iv_plain[j]=src_buf[j];

				src_i=0;
				iv_crypt=pOutBuf;
				nOutBufLen+=8;
				pOutBuf+=8;
			}
		}

		/*src_i÷∏œÚsrc_bufœ¬“ª∏ˆŒª÷√*/

		for (i=1;i<=ZERO_LEN;)
		{
			if (src_i<8)
			{
				src_buf[src_i++]=0;
				i++; /*i inc in here*/
			}

			if (src_i==8)
			{
				/*src_i==8*/
				
				for (j=0;j<8;j++) /*º”√‹«∞“ÏªÚ«∞8∏ˆunsigned charµƒ√‹Œƒ(iv_crypt÷∏œÚµƒ)*/
					src_buf[j]^=iv_crypt[j];
				/*pOutBuffer°¢pInBufferæ˘Œ™8unsigned char, &m_arKeyŒ™16unsigned char*/
				TeaEncryptECB(src_buf, m_arKey, pOutBuf);

				for (j=0;j<8;j++) /*º”√‹∫Û“ÏªÚ«∞8∏ˆunsigned charµƒ√˜Œƒ(iv_plain÷∏œÚµƒ)*/
					pOutBuf[j]^=iv_plain[j];

				/*±£¥Êµ±«∞µƒiv_plain*/
				for (j=0;j<8;j++)
					iv_plain[j]=src_buf[j];

				src_i=0;
				iv_crypt=pOutBuf;
				nOutBufLen+=8;
				pOutBuf+=8;
			}
		}
	}
	else if(m_nEncryptArith ==CRYPT_3)	
	{
	/*	qq_symmetry_encrypt3(pInBuf,nInBufLen,
			CProtocolObj::GetVersionM(),CProtocolObj::GetVersionS(),g_dwUIN,m_arKey,pOutBuf,&nOutBufLen);
	*/
	}
	else
	{
	//	QASSERT(0);
	}
	return ;
}


unsigned char CCrypt::Decrypt(const unsigned char* pInBuf, int nInBufLen,unsigned char* pOutBuf, int& nOutBufLen)
{
	if(m_nDecryptArith == CRYPT_2)
	{
		int nPadLen, nPlainLen;
		unsigned char dest_buf[8], zero_buf[8];
		const unsigned char *iv_pre_crypt, *iv_cur_crypt;
		int dest_i, i, j;
		//const unsigned char *pInBufBoundary;
		int nBufPos;
		nBufPos = 0;
		
		if ((nInBufLen%8) || (nInBufLen<16)) 
			return false;
		

		TeaDecryptECB(pInBuf, m_arKey, dest_buf);

		nPadLen = dest_buf[0] & 0x7/*÷ª“™◊ÓµÕ»˝Œª*/;

		/*√‹Œƒ∏Ò Ω:PadLen(1unsigned char)+Padding(var,0-7unsigned char)+Salt(2unsigned char)+Body(var unsigned char)+Zero(7unsigned char)*/
		i = nInBufLen-1/*PadLen(1unsigned char)*/-nPadLen-SALT_LEN-ZERO_LEN; /*√˜Œƒ≥§∂»*/
		if ((nOutBufLen<i) || (i<0)) 
			return false;
		nOutBufLen = i;
		
		//pInBufBoundary = pInBuf + nInBufLen; /* ‰»Îª∫≥Â«¯µƒ±ﬂΩÁ£¨œ¬√Ê≤ªƒ‹pInBuf>=pInBufBoundary*/

		
		for ( i=0; i<8; i++)
			zero_buf[i] = 0;

		iv_pre_crypt = zero_buf;
		iv_cur_crypt = pInBuf; /*init iv*/

		pInBuf += 8;
		nBufPos += 8;

		dest_i=1; /*dest_i÷∏œÚdest_bufœ¬“ª∏ˆŒª÷√*/


		/*∞—Padding¬ÀµÙ*/
		dest_i+=nPadLen;

		/*dest_i must <=8*/

		/*∞—Salt¬ÀµÙ*/
		for (i=1; i<=SALT_LEN;)
		{
			if (dest_i<8)
			{
				dest_i++;
				i++;
			}
			else if (dest_i==8)
			{
				/*Ω‚ø™“ª∏ˆ–¬µƒº”√‹øÈ*/

				/*∏ƒ±‰«∞“ª∏ˆº”√‹øÈµƒ÷∏’Î*/
				iv_pre_crypt = iv_cur_crypt;
				iv_cur_crypt = pInBuf; 

				/*“ÏªÚ«∞“ªøÈ√˜Œƒ(‘⁄dest_buf[]÷–)*/
				for (j=0; j<8; j++)
				{
					if( (nBufPos + j) >= nInBufLen)
						return false;
					dest_buf[j]^=pInBuf[j];
				}

				/*dest_i==8*/
				TeaDecryptECB(dest_buf, m_arKey, dest_buf);

				/*‘⁄»°≥ˆµƒ ±∫Ú≤≈“ÏªÚ«∞“ªøÈ√‹Œƒ(iv_pre_crypt)*/

				
				pInBuf += 8;
				nBufPos += 8;
		
				dest_i=0; /*dest_i÷∏œÚdest_bufœ¬“ª∏ˆŒª÷√*/
			}
		}

		/*ªπ‘≠√˜Œƒ*/

		nPlainLen=nOutBufLen;
		while (nPlainLen)
		{
			if (dest_i<8)
			{
				*(pOutBuf++)=dest_buf[dest_i]^iv_pre_crypt[dest_i];
				dest_i++;
				nPlainLen--;
			}
			else if (dest_i==8)
			{
				/*dest_i==8*/

				/*∏ƒ±‰«∞“ª∏ˆº”√‹øÈµƒ÷∏’Î*/
				iv_pre_crypt = iv_cur_crypt;
				iv_cur_crypt = pInBuf; 

				/*Ω‚ø™“ª∏ˆ–¬µƒº”√‹øÈ*/

				/*“ÏªÚ«∞“ªøÈ√˜Œƒ(‘⁄dest_buf[]÷–)*/
				for (j=0; j<8; j++)
				{
					if( (nBufPos + j) >= nInBufLen)
						return false;
					dest_buf[j]^=pInBuf[j];
				}

				TeaDecryptECB(dest_buf, m_arKey, dest_buf);

				/*‘⁄»°≥ˆµƒ ±∫Ú≤≈“ÏªÚ«∞“ªøÈ√‹Œƒ(iv_pre_crypt)*/
			
				
				pInBuf += 8;
				nBufPos += 8;
		
				dest_i=0; /*dest_i÷∏œÚdest_bufœ¬“ª∏ˆŒª÷√*/
			}
		}

		/*–£—ÈZero*/
		for (i=1;i<=ZERO_LEN;)
		{
			if (dest_i<8)
			{
				if(dest_buf[dest_i]^iv_pre_crypt[dest_i]) return false;
				dest_i++;
				i++;
			}
			else if (dest_i==8)
			{
				/*∏ƒ±‰«∞“ª∏ˆº”√‹øÈµƒ÷∏’Î*/
				iv_pre_crypt = iv_cur_crypt;
				iv_cur_crypt = pInBuf; 

				/*Ω‚ø™“ª∏ˆ–¬µƒº”√‹øÈ*/

				/*“ÏªÚ«∞“ªøÈ√˜Œƒ(‘⁄dest_buf[]÷–)*/
				for (j=0; j<8; j++)
				{
					if( (nBufPos + j) >= nInBufLen)
						return false;
					dest_buf[j]^=pInBuf[j];
				}

				TeaDecryptECB(dest_buf, m_arKey, dest_buf);

				/*‘⁄»°≥ˆµƒ ±∫Ú≤≈“ÏªÚ«∞“ªøÈ√‹Œƒ(iv_pre_crypt)*/

				
				pInBuf += 8;
				nBufPos += 8;
				dest_i=0; /*dest_i÷∏œÚdest_bufœ¬“ª∏ˆŒª÷√*/
			}
		
		}

		return true;
	}
	else if(m_nDecryptArith ==CRYPT_3)
	{/*
		return qq_symmetry_decrypt3(pInBuf,nInBufLen,
			CProtocolObj::GetVersionM(),CProtocolObj::GetVersionS(),g_dwUIN,m_arKey,pOutBuf,&nOutBufLen);
		*/
	}
	return false;
}

int CCrypt::FindEncryptSize(int nLen)
{
	int nPadSaltBodyZeroLen/*PadLen(1unsigned char)+Salt+Body+Zeroµƒ≥§∂»*/;
	int nPadlen;

	if(m_nEncryptArith ==CRYPT_2)	
	{
	
		/*∏˘æ›Body≥§∂»º∆À„PadLen,◊Ó–°±ÿ–Ë≥§∂»±ÿ–ËŒ™8unsigned charµƒ’˚ ˝±∂*/
		nPadSaltBodyZeroLen = nLen/*Body≥§∂»*/+1+SALT_LEN+ZERO_LEN/*PadLen(1unsigned char)+Salt(2unsigned char)+Zero(7unsigned char)*/;
		if(nPadlen=nPadSaltBodyZeroLen%8) /*len=nSaltBodyZeroLen%8*/
		{
			/*ƒ£8”‡0–Ë≤π0,”‡1≤π7,”‡2≤π6,...,”‡7≤π1*/
			nPadlen=8-nPadlen;
		}

		
	}
	else if(m_nEncryptArith ==CRYPT_3)
	{

		/*∏˘æ›Body≥§∂»º∆À„PadLen,◊Ó–°±ÿ–Ë≥§∂»±ÿ–ËŒ™8unsigned charµƒ’˚ ˝±∂*/
		nPadSaltBodyZeroLen = nLen/*Body≥§∂»*/+1+SALT_LEN+ZERO_LEN/*PadLen(1unsigned char)+Salt(2unsigned char)+Zero(7unsigned char)*/;
		if(nPadlen=nPadSaltBodyZeroLen%8) /*len=nSaltBodyZeroLen%8*/
		{
			/*ƒ£8”‡0–Ë≤π0,”‡1≤π7,”‡2≤π6,...,”‡7≤π1*/
			nPadlen=8-nPadlen;
		}

		

	}
	else
	{
//		QASSERT(0);
		return 0;
	}
	return nPadSaltBodyZeroLen+nPadlen;

}



void CCrypt::Md5Hash(unsigned char *outBuffer, const unsigned char *inBuffer, int length)
{
	
	MD5_CTX2 *md5Info, md5InfoBuffer;
	md5Info = &md5InfoBuffer;
	
	MD5_Init( md5Info );
	MD5_Update( md5Info, inBuffer, length );
	MD5_Final( outBuffer, md5Info );

}

void CCrypt::SetKey(unsigned char* pKey,int nLen)
{

	//QASSERT(nLen ==16);
	if (nLen!=16)
		return;
	if(nLen==SESSION_KEY_SIZE)
		memcpy(m_arKey,pKey,SESSION_KEY_SIZE);
}

void CCrypt::SetArith(unsigned char nEncrypt, unsigned char nDecrypt)
{
	m_nEncryptArith = nEncrypt;
	m_nDecryptArith = nDecrypt;
}
