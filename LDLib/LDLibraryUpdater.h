#ifndef __LDLIBRARYUPDATER_H__
#define __LDLIBRARYUPDATER_H__

#include <TCFoundation/TCObject.h>
#include <TCFoundation/TCThread.h>

template <class Type> class TCTypedObjectArray;
class TCWebClient;
class LDLibraryUpdateInfo;
class TCStringArray;

typedef TCTypedObjectArray<TCWebClient> TCWebClientArray;
typedef TCTypedObjectArray<LDLibraryUpdateInfo> LDLibraryUpdateInfoArray;

#define LD_LIBRARY_UPDATER "LDLibraryUpdater"

class LDLibraryUpdater : public TCObject
{
public:
	LDLibraryUpdater(void);
	void setLibraryUpdateKey(const char *libraryUpdateKey);
	void setLdrawDir(const char *ldrawDir);
	void checkForUpdates(void);
protected:
	virtual ~LDLibraryUpdater(void);
	virtual void dealloc(void);
	virtual THREAD_RET_TYPE threadStart(TCThread*);
	virtual void threadFinish(TCThread*);
	void parseUpdateList(const char *updateList);
	bool determineLastUpdate(LDLibraryUpdateInfoArray *updateArray,
		char *updateName);
	int compareUpdates(LDLibraryUpdateInfoArray *updateArray, const char *left,
		const char *right);
	bool fileExists(const char *filename);
	TCStringArray *getUpdateQueue(void);
	void downloadUpdates(void);
	void updateDlFinish(TCWebClient *webClient);
	void processUpdateQueue(void);
	void sendDlProgress(bool *aborted);

	TCWebClientArray *m_webClients;
	TCThread *m_thread;
	char *m_libraryUpdateKey;
	char *m_ldrawDir;
	TCStringArray *m_updateQueue;
	int m_initialQueueSize;
};

#endif // __LDLIBRARYUPDATER_H__
