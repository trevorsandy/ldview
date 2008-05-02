#ifndef __TREVERTEXSTORE_H__
#define __TREVERTEXSTORE_H__

#include <TCFoundation/TCObject.h>
#include <TCFoundation/TCTypedValueArray.h>
#include <TCFoundation/TCStlIncludes.h>
#include <TRE/TREGL.h>

struct TREVertex;
class TREVertexArray;
class TCVector;

typedef TCTypedValueArray<GLboolean> GLbooleanArray;
typedef std::vector<int> IntVector;

class TREVertexStore : public TCObject
{
public:
	TREVertexStore(void);
	TREVertexStore(const TREVertexStore &other);
	virtual TCObject *copy(void) const;
	virtual bool activate(bool displayLists);
	virtual void deactivate(void);
	virtual int addVertices(const TCVector *points, int count, int step,
		GLboolean edgeFlag = GL_TRUE);
	virtual int addVertices(const TCVector *points, const TCVector *normals,
		int count, int step);
	virtual int addVertices(const TCVector *points, const TCVector *normals,
		const TCVector *textureCoords, int count, int step);
	virtual int addVertices(TCULong color, const TCVector *points, int count,
		int step);
	virtual int addVertices(TCULong color, const TCVector *points,
		const TCVector *normals, int count, int step);
	virtual int addVertices(TCULong color, const TCVector *points,
		const TCVector *normals, const TCVector *textureCoords, int count,
		int step);
	virtual void setup(void);
	virtual void setupColored(void);
	virtual void setupTextured(void);
	TREVertexArray *getVertices(void) { return m_vertices; }
	TREVertexArray *getNormals(void) { return m_normals; }
	TREVertexArray *getTextureCoords(void) { return m_textureCoords; }
	TCULongArray *getColors(void) { return m_colors; }
	GLbooleanArray *getEdgeFlags(void) { return m_edgeFlags; }
	void setLightingFlag(bool value);
	bool getLightingFlag(void) { return m_flags.lighting != false; }
	void setTwoSidedLightingFlag(bool value)
	{
		m_flags.twoSidedLighting = value;
	}
	bool getTwoSidedLightingFlag(void)
	{
		return m_flags.twoSidedLighting != false;
	}
	void setShowAllConditionalFlag(bool value)
	{
		m_flags.showAllConditional = value;
	}
	bool getShowAllConditionalFlag(void)
	{
		return m_flags.showAllConditional != false;
	}
	void setConditionalControlPointsFlag(bool value)
	{
		m_flags.conditionalControlPoints = value;
	}
	bool getConditionalControlPointsFlag(void)
	{
		return m_flags.conditionalControlPoints != false;
	}
	void setConditionalsFlag(bool value) { m_flags.conditionals = value; }
	bool getConditionalsFlag(void) { return m_flags.conditionals != false; }
	virtual void openGlWillEnd(void);

	static void initVertex(TREVertex &vertex, const TCVector &point);
	static TCVector calcNormal(const TCVector *points, bool normalize = true);
	static void setWglAllocateMemoryNV(PFNWGLALLOCATEMEMORYNVPROC value)
	{
		wglAllocateMemoryNV = value;
	}
	static void setWglFreeMemoryNV(PFNWGLFREEMEMORYNVPROC value)
	{
		wglFreeMemoryNV = value;
	}
	static void setGlVertexArrayRangeNV(PFNGLVERTEXARRAYRANGENVPROC value)
	{
		glVertexArrayRangeNV = value;
	}
	static void setGlBindBufferARB(PFNGLBINDBUFFERARBPROC value)
	{
		glBindBufferARB = value;
	}
	static void setGlDeleteBuffersARB(PFNGLDELETEBUFFERSARBPROC value)
	{
		glDeleteBuffersARB = value;
	}
	static void setGlGenBuffersARB(PFNGLGENBUFFERSARBPROC value)
	{
		glGenBuffersARB = value;
	}
	static void setGlBufferDataARB(PFNGLBUFFERDATAARBPROC value)
	{
		glBufferDataARB = value;
	}
protected:
	virtual ~TREVertexStore(void);
	virtual void dealloc(void);
	virtual int addVertices(TREVertexArray *vertices, const TCVector *points,
		int count, int step);
	virtual void setupVAR(void);
	virtual void setupVBO(void);

	TREVertexArray *m_vertices;
	TREVertexArray *m_normals;
	TREVertexArray *m_textureCoords;
	IntVector m_stepCounts;
	TCULongArray *m_colors;
	GLbooleanArray *m_edgeFlags;
	TCULong m_verticesOffset;
	TCULong m_normalsOffset;
	TCULong m_textureCoordsOffset;
	TCULong m_colorsOffset;
	TCULong m_edgeFlagsOffset;
	GLuint m_vbo;
	struct
	{
		bool varTried:1;
		bool varFailed:1;
		bool vboTried:1;
		bool vboFailed:1;
		bool lighting:1;
		bool twoSidedLighting:1;
		bool showAllConditional:1;
		bool conditionalControlPoints:1;
		bool conditionals:1;
	} m_flags;

	static TREVertexStore *sm_activeVertexStore;

	static PFNWGLALLOCATEMEMORYNVPROC wglAllocateMemoryNV;
	static PFNWGLFREEMEMORYNVPROC wglFreeMemoryNV;
	static PFNGLVERTEXARRAYRANGENVPROC glVertexArrayRangeNV;

	static PFNGLBINDBUFFERARBPROC glBindBufferARB;
	static PFNGLDELETEBUFFERSARBPROC glDeleteBuffersARB;
	static PFNGLGENBUFFERSARBPROC glGenBuffersARB;
	static PFNGLBUFFERDATAARBPROC glBufferDataARB;

	static TCByte *sm_varBuffer;
	static int sm_varSize;
};

#endif // __TREVERTEXSTORE_H__
