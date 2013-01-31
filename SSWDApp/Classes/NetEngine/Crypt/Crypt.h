 #if !defined(AFX_CRYPT_H__A05365F3_110F_4771_A093_37F147F3CB94__INCLUDED_)
#define AFX_CRYPT_H__A05365F3_110F_4771_A093_37F147F3CB94__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

const int SESSION_KEY_SIZE=16;

//#include "OSDefine.h"

#define CRYPT_2	0
#define CRYPT_3	1

#define MD5_LBLOCK	16

typedef struct tagMD5State
{
	unsigned long A,B,C,D;
	unsigned long Nl,Nh;
	unsigned long data[MD5_LBLOCK];
	int num;
} MD5_CTX2;


short htos_net(short mform);
long htol_net(long mform);
long long htol_net(long long mform);
//static void MD5_Init(MD5_CTX2 *c);
//extern QDWORD g_dwUIN;

class CCrypt  
{
public:
	void SetArith(unsigned char nEncrypt = CRYPT_3,unsigned char nDecrypt = CRYPT_2);
	void SetKey(unsigned char* pKey,int nLen=16);
	static void Md5Hash( unsigned char *outBuffer, const unsigned char *inBuffer, int length);

	static void MD5_Init(MD5_CTX2 *c);
	static void MD5_Update(MD5_CTX2 *c, const register unsigned char *data, unsigned long len);
	static void MD5_Final(unsigned char *md, MD5_CTX2 *c);
	
	int FindEncryptSize(int nLen);
	void Encrypt(const unsigned char* pInBuf, int nInBufLen, unsigned char* pOutBuf, int& pOutBufLen);
	unsigned char Decrypt(const unsigned char* pInBuf, int nInBufLen, unsigned char* pOutBuf, int& nOutBufLen);
	CCrypt(unsigned char* pKey,unsigned char nEncryptArith,unsigned char nDecryptArith);

	#define QUOTIENT  0x04c11db7
	static unsigned int CRC32Hash(unsigned char *data, int len)
	{
		unsigned int        result;
		int                 i,j;
		unsigned char       octet;
    
		result = -1;
    
		for (i=0; i<len; i++)
		{
			octet = *(data++);
			for (j=0; j<8; j++)
			{
				if ((octet >> 7) ^ (result >> 31))
				{
					result = (result << 1) ^ QUOTIENT;
				}
				else
				{
					result = (result << 1);
				}
				octet <<= 1;
			}
		}
    
		return ~result;             /* The complement of the remainder */
	}

		static void _4bytesDecryptAFrame(short *v, short *k)
	{
		short m_n4BytesScheduleDelta=0x325f;
		///unsigned long m_nScheduleDelta=0x19099830;

		short y=v[0],z=v[1], sum=0,   /* set up */
			n=32;             
		while (n-->0)
		{                       /* basic cycle start */
			sum += m_n4BytesScheduleDelta;/* a key schedule constant */
			y += (z<<4)+k[0] ^ z+sum ^ (z>>5)+k[1] ;
			z += (y<<4)+k[2] ^ y+sum ^ (y>>5)+k[3] ;   /* end cycle */		
		} 
		v[0]=y ; v[1]=z ; 
	}

//Ω‚√‹
//short* v:data 4 unsigned chars
//short* k:key 8 unsigned chars
	static void _4bytesEncryptAFrame(short *v, short *k)
	{
		short m_n4BytesScheduleDelta=0x325f;

		short n=32, sum, y=v[0], z=v[1];
		sum=m_n4BytesScheduleDelta<<5 ;
		/* start cycle */
		while (n-->0) {
			z-= (y<<4)+k[2] ^ y+sum ^ (y>>5)+k[3] ; 
			y-= (z<<4)+k[0] ^ z+sum ^ (z>>5)+k[1] ;
			sum-=m_n4BytesScheduleDelta ;  
		}
		/* end cycle */
		v[0]=y ;
		v[1]=z ;  
	}


	CCrypt();
	virtual ~CCrypt();
protected:
	unsigned char	m_arKey[SESSION_KEY_SIZE];
	unsigned char	m_nEncryptArith;
	unsigned char	m_nDecryptArith;
};

#endif 