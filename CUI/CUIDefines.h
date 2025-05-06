#ifndef __CUIDEFINES_H__
#define __CUIDEFINES_H__

#ifdef _BUILDING_CUI
#define CUIExport __declspec(dllexport)
#elif defined _BUILDING_CUI_LIB || defined _TC_STATIC
#define CUIExport
#else
#define CUIExport __declspec(dllimport)
#endif

// Enable GCC compiler double underscore for __attribute__
// where MSVC single underscore convention is used.
#if (defined(_MSC_VER) && _MSC_VER >= 1400)
#define CUIAPI _stdcall
#elif defined(__MINGW64__)
#define CUIAPI __stdcall
#endif
#endif // __CUIDEFINES_H__
