#include "LDLPrimitiveCheck.h"

#include <string.h>

#include <LDLoader/LDLMainModel.h>
#include <LDLoader/LDLShapeLine.h>
#include <LDLoader/LDLModelLine.h>
#include <LDLoader/LDLConditionalLineLine.h>
#include <LDLoader/LDLPalette.h>
#include <TCFoundation/mystring.h>
#include <TCFoundation/TCMacros.h>
#include <TCFoundation/TCVector.h>
#include <TCFoundation/TCProgressAlert.h>
#include <TCFoundation/TCLocalStrings.h>
#include <ctype.h>

static const int LO_NUM_SEGMENTS = 8;
static const int HI_NUM_SEGMENTS = 16;

LDLPrimitiveCheck::LDLPrimitiveCheck(void):
	m_curveQuality(2)
{
	m_flags.primitiveSubstitution = true;
	m_flags.noLightGeom = false;
}

LDLPrimitiveCheck::~LDLPrimitiveCheck(void)
{
}

void LDLPrimitiveCheck::dealloc(void)
{
	TCObject::dealloc();
}

TCFloat LDLPrimitiveCheck::startingFraction(const char *filename)
{
	int top;
	int bottom;

	if (stringHasCaseInsensitivePrefix(filename, "48/") ||
		stringHasCaseInsensitivePrefix(filename, "48\\"))
	{
		filename += 3;
	}
	sscanf(filename, "%d", &top);
	sscanf(filename + 2, "%d", &bottom);
	return (TCFloat)top / (TCFloat)bottom;
}

bool LDLPrimitiveCheck::startsWithFraction(const char *filename)
{
	return isdigit(filename[0]) && filename[1] == '-' && isdigit(filename[2]) &&
		!isdigit(filename[3]);
}

bool LDLPrimitiveCheck::startsWithFraction2(const char *filename)
{
	return isdigit(filename[0]) && filename[1] == '-' && isdigit(filename[2]) &&
		isdigit(filename[3]) && !isdigit(filename[4]);
}

bool LDLPrimitiveCheck::isPrimitive(const char *filename, const char *suffix,
								bool *is48)
{
	int fileLen = strlen(filename);
	int suffixLen = strlen(suffix);

	if (is48 != NULL)
	{
		*is48 = false;
	}
	if (((fileLen == suffixLen + 3 && startsWithFraction(filename)) ||
		(suffixLen <= 8 && fileLen == suffixLen + 4 &&
		startsWithFraction2(filename))) &&
		stringHasCaseInsensitiveSuffix(filename, suffix))
	{
		return true;
	}
	else if (is48 != NULL && (stringHasCaseInsensitivePrefix(filename, "48/") ||
		stringHasCaseInsensitivePrefix(filename, "48\\")))
	{
		*is48 = true;
		return isPrimitive(filename + 3, suffix, NULL);
	}
	return false;
}

bool LDLPrimitiveCheck::isCyli(const char *filename, bool *is48)
{
	return isPrimitive(filename, "cyli.dat", is48);
}

bool LDLPrimitiveCheck::isCyls(const char *filename, bool *is48)
{
	return isPrimitive(filename, "cyls.dat", is48);
}

bool LDLPrimitiveCheck::isCyls2(const char *filename, bool *is48)
{
	return isPrimitive(filename, "cyls2.dat", is48);
}

bool LDLPrimitiveCheck::isChrd(const char *filename, bool *is48)
{
	return isPrimitive(filename, "chrd.dat", is48);
}

bool LDLPrimitiveCheck::isDisc(const char *filename, bool *is48)
{
	return isPrimitive(filename, "disc.dat", is48);
}

bool LDLPrimitiveCheck::isNdis(const char *filename, bool *is48)
{
	return isPrimitive(filename, "ndis.dat", is48);
}

bool LDLPrimitiveCheck::isEdge(const char *filename, bool *is48)
{
	return isPrimitive(filename, "edge.dat", is48);
}

bool LDLPrimitiveCheck::is1DigitCon(const char *filename, bool *is48)
{
	if (is48 != NULL)
	{
		*is48 = false;
	}
	if (strlen(filename) == 11 && startsWithFraction(filename) &&
		stringHasCaseInsensitivePrefix(filename + 3, "con") &&
		isdigit(filename[6]) &&
		stringHasCaseInsensitiveSuffix(filename, ".dat"))
	{
		return true;
	}
	else if (is48 != NULL && (stringHasCaseInsensitivePrefix(filename, "48/") ||
		stringHasCaseInsensitivePrefix(filename, "48\\")))
	{
		*is48 = true;
		return is1DigitCon(filename + 3, NULL);
	}
	return false;
}

bool LDLPrimitiveCheck::is2DigitCon(const char *filename, bool *is48)
{
	if (is48 != NULL)
	{
		*is48 = false;
	}
	if (strlen(filename) == 12 && startsWithFraction(filename) &&
		stringHasCaseInsensitivePrefix(filename + 3, "con") &&
		isdigit(filename[6]) && isdigit(filename[7]) &&
		stringHasCaseInsensitiveSuffix(filename, ".dat"))
	{
		return true;
	}
	else if (is48 != NULL && (stringHasCaseInsensitivePrefix(filename, "48/") ||
		stringHasCaseInsensitivePrefix(filename, "48\\")))
	{
		*is48 = true;
		return is1DigitCon(filename + 3, NULL);
	}
	return false;
}

bool LDLPrimitiveCheck::isCon(const char *filename, bool *is48)
{
	return is1DigitCon(filename, is48) || is2DigitCon(filename, is48);
}

bool LDLPrimitiveCheck::isOldRing(const char *filename, bool *is48)
{
	int len = strlen(filename);

	if (is48 != NULL)
	{
		*is48 = false;
	}
	if (len >= 9 && len <= 12 &&
		stringHasCaseInsensitivePrefix(filename, "ring") &&
		stringHasCaseInsensitiveSuffix(filename, ".dat"))
	{
		int i;

		for (i = 4; i < len - 5; i++)
		{
			if (!isdigit(filename[i]))
			{
				return false;
			}
		}
		return true;
	}
	else if (is48 != NULL && (stringHasCaseInsensitivePrefix(filename, "48/") ||
		stringHasCaseInsensitivePrefix(filename, "48\\")))
	{
		*is48 = true;
		return isOldRing(filename + 3, NULL);
	}
	else
	{
		return false;
	}
}

bool LDLPrimitiveCheck::isRing(const char *filename, bool *is48)
{
	if (is48 != NULL)
	{
		*is48 = false;
	}
	if (strlen(filename) == 12 && startsWithFraction(filename) &&
		stringHasCaseInsensitivePrefix(filename + 3, "ring") &&
		isdigit(filename[7]) &&
		stringHasCaseInsensitiveSuffix(filename, ".dat"))
	{
		return true;
	}
	else if (is48 != NULL && (stringHasCaseInsensitivePrefix(filename, "48/") ||
		stringHasCaseInsensitivePrefix(filename, "48\\")))
	{
		*is48 = true;
		return isRing(filename + 3, NULL);
	}
	else
	{
		return false;
	}
}

bool LDLPrimitiveCheck::isRin(const char *filename, bool *is48)
{
	if (is48 != NULL)
	{
		*is48 = false;
	}
	if (strlen(filename) == 12 && startsWithFraction(filename) &&
		stringHasCaseInsensitivePrefix(filename + 3, "rin") &&
		isdigit(filename[6]) && isdigit(filename[7]) &&
		stringHasCaseInsensitiveSuffix(filename, ".dat"))
	{
		return true;
	}
	else if (is48 != NULL && (stringHasCaseInsensitivePrefix(filename, "48/") ||
		stringHasCaseInsensitivePrefix(filename, "48\\")))
	{
		*is48 = true;
		return isRin(filename + 3, NULL);
	}
	else
	{
		return false;
	}
}

bool LDLPrimitiveCheck::isTorus(const char *filename, bool *is48)
{
	if (is48 != NULL)
	{
		*is48 = false;
	}
	if (strlen(filename) == 12 && toupper(filename[0]) == 'T' &&
		isdigit(filename[1]) && isdigit(filename[2]) &&
		isdigit(filename[4]) && isdigit(filename[7]) && isdigit(filename[6]) &&
		isdigit(filename[7]) &&
		stringHasCaseInsensitiveSuffix(filename, ".dat"))
	{
		return true;
	}
	else if (is48 != NULL && (stringHasCaseInsensitivePrefix(filename, "48/") ||
		stringHasCaseInsensitivePrefix(filename, "48\\")))
	{
		*is48 = true;
		return isTorus(filename + 3, NULL);
	}
	else
	{
		return false;
	}
}

bool LDLPrimitiveCheck::isTorusO(const char *filename, bool *is48)
{
	if (isTorus(filename, is48))
	{
		if (is48 != NULL && *is48)
		{
			return toupper(filename[6]) == 'O';
		}
		else
		{
			return toupper(filename[3]) == 'O';
		}
	}
	else
	{
		return false;
	}
}

bool LDLPrimitiveCheck::isTorusI(const char *filename, bool *is48)
{
	if (isTorus(filename, is48))
	{
		if (is48 != NULL && *is48)
		{
			return toupper(filename[6]) == 'I';
		}
		else
		{
			return toupper(filename[3]) == 'I';
		}
	}
	else
	{
		return false;
	}
}

bool LDLPrimitiveCheck::isTorusQ(const char *filename, bool *is48)
{
	if (isTorus(filename, is48))
	{
		if (is48 != NULL && *is48)
		{
			return toupper(filename[6]) == 'Q';
		}
		else
		{
			return toupper(filename[3]) == 'Q';
		}
	}
	else
	{
		return false;
	}
}

TCFloat LDLPrimitiveCheck::getTorusFraction(int size)
{
	int i;

	for (i = 0; i < 10; i++)
	{
		if (size == i + i * 10 + i * 100 + i * 1000)
		{
			return (TCFloat)i / 9.0f;
		}
	}
	return (TCFloat)size / 10000.0f;
}

int LDLPrimitiveCheck::getUsedCircleSegments(int numSegments, TCFloat fraction)
{
	return (int)(numSegments * fraction + 0.000001);
}

int LDLPrimitiveCheck::getNumCircleSegments(TCFloat fraction, bool is48)
{
	int retValue = m_curveQuality * LO_NUM_SEGMENTS;

	if (is48 && retValue < 48)
	{
		retValue = 48;
	}
	if (fraction != 0.0f)
	{
		int i;
		
		for (i = m_curveQuality; !fEq(fraction * retValue,
			(TCFloat)getUsedCircleSegments(retValue, fraction)) && i < 12; i++)
		{
			int newValue = (i + 1) * LO_NUM_SEGMENTS;

			if (newValue > retValue)
			{
				retValue = newValue;
			}
		}
	}
	return retValue;
}

bool LDLPrimitiveCheck::performPrimitiveSubstitution(
	LDLModel *ldlModel,
	bool bfc)
{
	const char *modelName = ldlModel->getName();

	if (getPrimitiveSubstitutionFlag())
	{
		bool is48;

		if (!modelName)
		{
			return false;
		}
		if (strcasecmp(modelName, "LDL-LOWRES:stu2.dat") == 0)
		{
			return substituteStu2();
		}
		else if (strcasecmp(modelName, "LDL-LOWRES:stu22.dat") == 0)
		{
			return substituteStu22(false, bfc);
		}
		else if (strcasecmp(modelName, "LDL-LOWRES:stu22a.dat") == 0)
		{
			return substituteStu22(true, bfc);
		}
		else if (strcasecmp(modelName, "LDL-LOWRES:stu23.dat") == 0)
		{
			return substituteStu23(false, bfc);
		}
		else if (strcasecmp(modelName, "LDL-LOWRES:stu23a.dat") == 0)
		{
			return substituteStu23(true, bfc);
		}
		else if (strcasecmp(modelName, "LDL-LOWRES:stu24.dat") == 0)
		{
			return substituteStu24(false, bfc);
		}
		else if (strcasecmp(modelName, "LDL-LOWRES:stu24a.dat") == 0)
		{
			return substituteStu24(true, bfc);
		}
		else if (strcasecmp(modelName, "stud.dat") == 0)
		{
			return substituteStud();
		}
		else if (strcasecmp(modelName, "1-8sphe.dat") == 0)
		{
			return substituteEighthSphere(bfc);
		}
		else if (strcasecmp(modelName, "48/1-8sphe.dat") == 0 ||
			strcasecmp(modelName, "48\\1-8sphe.dat") == 0)
		{
			return substituteEighthSphere(bfc, true);
		}
		else if (isCyli(modelName, &is48))
		{
			return substituteCylinder(startingFraction(modelName),
				bfc, is48);
		}
		else if (isCyls(modelName, &is48))
		{
			return substituteSlopedCylinder(startingFraction(modelName), bfc,
				is48);
		}
		else if (isCyls2(modelName, &is48))
		{
			return substituteSlopedCylinder2(startingFraction(modelName), bfc,
				is48);
		}
		else if (isChrd(modelName, &is48))
		{
			return substituteChrd(startingFraction(modelName), bfc,
				is48);
		}
		else if (isDisc(modelName, &is48))
		{
			return substituteDisc(startingFraction(modelName), bfc,
				is48);
		}
		else if (isNdis(modelName, &is48))
		{
			return substituteNotDisc(startingFraction(modelName),
				bfc, is48);
		}
		else if (isEdge(modelName, &is48))
		{
			return substituteCircularEdge(startingFraction(modelName), is48);
		}
		else if (isCon(modelName, &is48))
		{
			int size;
			int offset = 0;

			if (is48)
			{
				offset = 3;
			}
			sscanf(modelName + 6 + offset, "%d", &size);
			return substituteCone(startingFraction(modelName), size,
				bfc, is48);
		}
		else if (isOldRing(modelName, &is48))
		{
			int size;
			int offset = 0;

			if (is48)
			{
				offset = 3;
			}
			sscanf(modelName + 4 + offset, "%d", &size);
			return substituteRing(1.0f, size, bfc, is48);
		}
		else if (isRing(modelName, &is48))
		{
			int size;
			int offset = 0;

			if (is48)
			{
				offset = 3;
			}
			sscanf(modelName + 7 + offset, "%d", &size);
			return substituteRing(startingFraction(modelName), size,
				bfc, is48);
		}
		else if (isRin(modelName, &is48))
		{
			int size;
			int offset = 0;

			if (is48)
			{
				offset = 3;
			}
			sscanf(modelName + 6 + offset, "%d", &size);
			return substituteRing(startingFraction(modelName), size,
				bfc, is48);
		}
		else if (isTorusO(modelName, &is48))
		{
			return substituteTorusIO(false, bfc, is48);
		}
		else if (isTorusI(modelName, &is48))
		{
			return substituteTorusIO(true, bfc, is48);
		}
		else if (isTorusQ(modelName, &is48))
		{
			return substituteTorusQ(bfc, is48);
		}
	}
	if (getNoLightGeomFlag())
	{
		if (modelName && strcasecmp(modelName, "light.dat") == 0)
		{
			// Don't draw any geometry for light.dat.
			return true;
		}
	}
	return false;
}

