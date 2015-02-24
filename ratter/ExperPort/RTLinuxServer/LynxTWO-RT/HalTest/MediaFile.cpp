// MediaFile.cpp: implementation of the CMediaFile class.
//
//////////////////////////////////////////////////////////////////////

#include "StdAfx.h"
#include "HalTest.h"
#include "MediaFile.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
CMediaFile::CMediaFile()
/////////////////////////////////////////////////////////////////////////////
{
	m_hmmio = NULL;
}

/////////////////////////////////////////////////////////////////////////////
CMediaFile::~CMediaFile()
/////////////////////////////////////////////////////////////////////////////
{
	Close();
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN	CMediaFile::Open( LPSTR szFilename, DWORD dwFlags )
/////////////////////////////////////////////////////////////////////////////
{
	// Open the given file using buffered I/O.
	m_hmmio = mmioOpen( szFilename, NULL, dwFlags );
	if( !m_hmmio )
	{
		MessageBox( NULL, "Failed to open file.", NULL, MB_OK | MB_ICONEXCLAMATION );
		return( FALSE );
	}

	return( TRUE );
}

/////////////////////////////////////////////////////////////////////////////
MMRESULT CMediaFile::Close( void )
/////////////////////////////////////////////////////////////////////////////
{
	MMRESULT Result = 0;
	
	if( m_hmmio )
		Result = mmioClose( m_hmmio, 0 );

	m_hmmio = NULL;
	return( Result );
}

/////////////////////////////////////////////////////////////////////////////
MMRESULT CMediaFile::Ascend( PMMCKINFO lpck )
/////////////////////////////////////////////////////////////////////////////
{
	//DPF(("Ascend: %08lx %08lx %ld\n", lpck->fccType, lpck->ckid, lpck->cksize ));
	return( mmioAscend( m_hmmio, lpck, 0 ) );
}

/////////////////////////////////////////////////////////////////////////////
MMRESULT CMediaFile::Descend( PMMCKINFO lpck, PMMCKINFO lpckParent, UINT wFlags )
/////////////////////////////////////////////////////////////////////////////
{
	//DPF(("Descend: %08lx %08lx ", lpck->fccType, lpck->ckid ));
	//if( lpckParent )
	//	DPF(("[%08lx]", lpckParent->fccType ));
	//DPF(("\n"));

	return( mmioDescend( m_hmmio, lpck, lpckParent, wFlags ) );
}

/////////////////////////////////////////////////////////////////////////////
MMRESULT CMediaFile::CreateChunk( PMMCKINFO lpck, UINT wFlags )
/////////////////////////////////////////////////////////////////////////////
{
	return( mmioCreateChunk( m_hmmio, lpck, wFlags ) );
}

/////////////////////////////////////////////////////////////////////////////
LONG CMediaFile::Read( HPSTR pch, LONG cch )
/////////////////////////////////////////////////////////////////////////////
{
	return( mmioRead( m_hmmio, pch, cch ) );
}

/////////////////////////////////////////////////////////////////////////////
LONG CMediaFile::Write( HPSTR pch, LONG cch )
/////////////////////////////////////////////////////////////////////////////
{
	return( mmioWrite( m_hmmio, pch, cch ) );
}

/////////////////////////////////////////////////////////////////////////////
MMRESULT CMediaFile::Flush( UINT uiFlags )
/////////////////////////////////////////////////////////////////////////////
{
	return( mmioFlush( m_hmmio, uiFlags ) );
}

/////////////////////////////////////////////////////////////////////////////
LONG CMediaFile::Seek( LONG lOffset )
/////////////////////////////////////////////////////////////////////////////
{
	return( mmioSeek( m_hmmio, lOffset, SEEK_CUR ) );
}

/////////////////////////////////////////////////////////////////////////////
LONG CMediaFile::SeekBegin( LONG lOffset )
/////////////////////////////////////////////////////////////////////////////
{
	return( mmioSeek( m_hmmio, lOffset, SEEK_SET ) );
}

/////////////////////////////////////////////////////////////////////////////
LONG CMediaFile::SeekEnd( LONG lOffset )
/////////////////////////////////////////////////////////////////////////////
{
	return( mmioSeek( m_hmmio, lOffset, SEEK_END ) );
}

