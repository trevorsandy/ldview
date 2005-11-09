#include "TCBmpImageFormat.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef unsigned short WORD;
typedef unsigned long DWORD;

#define BMP_FILE_HEADER_SIZE 14
#define BMP_INFO_HEADER_SIZE 40

TCBmpImageFormat::TCBmpImageFormat(void)
{
	name = "BMP";
#ifdef _LEAK_DEBUG
	strcpy(className, "TCBmpImageFormat");
#endif
}

TCBmpImageFormat::~TCBmpImageFormat(void)
{
}

void TCBmpImageFormat::dealloc(void)
{
	TCImageFormat::dealloc();
}

bool TCBmpImageFormat::checkSignature(const TCByte *data, long length)
{
	if (length >= 2)
	{
		return data[0] == 'B' && data[1] == 'M';
	}
	else
	{
		return false;
	}
}

bool TCBmpImageFormat::checkSignature(FILE *file)
{
	bool retValue = false;
	TCByte header[2];
	long filePos = ftell(file);

	if (fread(header, 1, 2, file) == 2)
	{
		retValue = header[0] == 'B' && header[1] == 'M';
	}
	fseek(file, filePos, SEEK_SET);
	return retValue;
}

bool TCBmpImageFormat::loadFile(TCImage * /*image*/, FILE * /*file*/)
{
	return false;
}

bool TCBmpImageFormat::loadData(TCImage * /*image*/, TCByte * /*data*/,
								long /*length*/)
{
	return false;
}

bool TCBmpImageFormat::writeValue(FILE *file, unsigned short value)
{
	TCByte buf[2];

	// Write the value in little endian format
	buf[0] = (TCByte)value;
	buf[1] = (TCByte)(value >> 8);
	return fwrite(buf, 1, 2, file) == 2;
}

bool TCBmpImageFormat::writeValue(FILE *file, unsigned long value)
{
	TCByte buf[4];

	// Write the value in little endian format
	buf[0] = (TCByte)value;
	buf[1] = (TCByte)(value >> 8);
	buf[2] = (TCByte)(value >> 16);
	buf[3] = (TCByte)(value >> 24);
	return fwrite(buf, 1, 4, file) == 4;
}

bool TCBmpImageFormat::writeValue(FILE *file, long value)
{
	return writeValue(file, (unsigned long)value);
}

bool TCBmpImageFormat::writeFileHeader(TCImage *image, FILE *file)
{
	int rowSize = image->roundUp(image->getWidth() * 3, 4);
	DWORD imageSize = rowSize * image->getHeight();

	if (!writeValue(file, (WORD)0x4D42)) // 'BM'
	{
		return false;
	}
	if (!writeValue(file, (DWORD)BMP_FILE_HEADER_SIZE + BMP_INFO_HEADER_SIZE +
		imageSize))
	{
		return false;
	}
	if (!writeValue(file, (DWORD)0)) // Reserved
	{
		return false;
	}
	if (!writeValue(file, (DWORD)BMP_FILE_HEADER_SIZE + BMP_INFO_HEADER_SIZE))
	{
		return false;
	}
	return true;
}

bool TCBmpImageFormat::writeInfoHeader(TCImage *image, FILE *file)
{
	int rowSize = image->roundUp(image->getWidth() * 3, 4);
	DWORD imageSize = rowSize * image->getHeight();

	if (!writeValue(file, (DWORD)BMP_INFO_HEADER_SIZE))
	{
		return false;
	}
	if (!writeValue(file, (long)image->getWidth()))
	{
		return false;
	}
	if (!writeValue(file, (long)image->getHeight()))
	{
		return false;
	}
	if (!writeValue(file, (WORD)1)) // # of planes
	{
		return false;
	}
	if (!writeValue(file, (WORD)24)) // BPP
	{
		return false;
	}
	if (!writeValue(file, (DWORD)0)) // Compression
	{
		return false;
	}
	if (!writeValue(file, (DWORD)imageSize))
	{
		return false;
	}
	if (!writeValue(file, (long)2835)) // X Pixels per meter: 72 DPI
	{
		return false;
	}
	if (!writeValue(file, (long)2835)) // Y Pixels per meter: 72 DPI
	{
		return false;
	}
	if (!writeValue(file, (DWORD)0)) // # of colors used
	{
		return false;
	}
	if (!writeValue(file, (DWORD)0)) // # of important colors: 0 == all
	{
		return false;
	}
	return true;
}

bool TCBmpImageFormat::writeImageData(TCImage *image, FILE *file,
									  TCImageProgressCallback progressCallback,
									  void *progressUserData)
{
	int rowSize = image->roundUp(image->getWidth() * 3, 4);
	bool failed = false;
	int i, j;
	bool rgba = image->getDataFormat() == TCRgba8;
	int imageRowSize = image->getRowSize();
	TCByte *rowData = new TCByte[rowSize];

	callProgressCallback(progressCallback, "Saving BMP.", 0.0f,
		progressUserData);
	memset(rowData, 0, rowSize);
	for (i = 0; i < image->getHeight() && !failed; i++)
	{

		if (rgba)
		{
			int lineOffset;

			if (image->getFlipped())
			{
				lineOffset = i * imageRowSize;
			}
			else
			{
				lineOffset = (image->getHeight() - i - 1) * imageRowSize;
			}
			for (j = 0; j < image->getWidth(); j++)
			{
				rowData[j * 3 + 2] = image->getImageData()[lineOffset +
					j * 4 + 0];
				rowData[j * 3 + 1] = image->getImageData()[lineOffset +
					j * 4 + 1];
				rowData[j * 3 + 0] = image->getImageData()[lineOffset +
					j * 4 + 2];
			}
		}
		else
		{
			int lineOffset;

			if (image->getFlipped())
			{
				lineOffset = i * imageRowSize;
			}
			else
			{
				lineOffset = (image->getHeight() - i - 1) * imageRowSize;
			}
			for (j = 0; j < image->getWidth(); j++)
			{
				rowData[j * 3 + 2] = image->getImageData()[lineOffset +
					j * 3 + 0];
				rowData[j * 3 + 1] = image->getImageData()[lineOffset +
					j * 3 + 1];
				rowData[j * 3 + 0] = image->getImageData()[lineOffset +
					j * 3 + 2];
			}
		}
		if (fwrite(rowData, 1, rowSize, file) != (unsigned)rowSize)
		{
			failed = true;
		}
		if (!callProgressCallback(progressCallback, NULL,
			(float)(i + 1) / (float)image->getHeight(), progressUserData))
		{
			failed = true;
		}
	}
	delete rowData;
	callProgressCallback(progressCallback, NULL, 2.0f, progressUserData);
	return !failed;
}

bool TCBmpImageFormat::saveFile(TCImage *image, FILE *file,
								TCImageProgressCallback progressCallback,
								void *progressUserData)
{
	if (!writeFileHeader(image, file))
	{
		return false;
	}
	if (!writeInfoHeader(image, file))
	{
		return false;
	}
	return writeImageData(image, file, progressCallback, progressUserData);
}
