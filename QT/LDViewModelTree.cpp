#include "qt4wrapper.h"
#include "Preferences.h"

#include "LDViewModelTree.h"

#include <TCFoundation/TCStringArray.h>

#include <qstring.h>
#include <qstatusbar.h>
#include <qcheckbox.h>
#include <qlabel.h>
#include <qgroupbox.h>
#include <qpushbutton.h>
#include <qcolor.h>
#include <qcolordialog.h>
#include <qtextedit.h>
#include "misc.h"
#include "ModelViewerWidget.h"
#include <TCFoundation/TCAlert.h>
#include <TCFoundation/TCAlertManager.h>
#include <LDLib/LDUserDefaultsKeys.h>

LDViewModelTree::LDViewModelTree(Preferences *pref, ModelViewerWidget *modelViewer)
	:ModelTreePanel(),
	modeltree(NULL),
	m_modelWindow(modelViewer),
    mainmodel(NULL),
	preferences(preferences),
	optionsShown(true)
{
	long color = TCUserDefaults::longForKey(MODEL_TREE_HIGHLIGHT_COLOR_KEY,
			(0xa0e0ff), false);
	highlightColorEdit->setPaletteBackgroundColor(QColor(color >>16, (color >>8) & 0xff, color & 0xff));
	preferences = pref;
	modelTreeView->setColumnWidthMode(0, QListView::Maximum);
	modelTreeView->header()->hide();
	modelTreeView->setSorting(-1);
	if (!TCUserDefaults::boolForKey(MODEL_TREE_OPTIONS_SHOWN_KEY, true, false))
    {
        hideOptions();
    }
	highlightSelectedLineBox->setChecked(TCUserDefaults::boolForKey(
			MODEL_TREE_HIGHLIGHT_KEY, false, false));
	statusbar = statusBar();
	statusText = new QLabel(statusbar);
	statusbar->addWidget(statusText, 1);
	statusbar->show();
}

LDViewModelTree::~LDViewModelTree() { }

QListViewItem *LDViewModelTree::getChild(QListViewItem *parent, int index)
{
	QListViewItem *child = (parent ? parent->firstChild() : modelTreeView->firstChild());
	for (int i = 1; (i <= index) && child; i++)
	{
		child = child->nextSibling();
	}
	return child;
}

void LDViewModelTree::selectFromHighlightPath(std::string path)
{
	QListViewItem *item = NULL;
	//printf("%s\n",path.c_str());
	while (path.size() > 0)
	{
		int lineNumber = atoi(&path[1]) - 1;
		item = getChild(item, lineNumber);
		if (item)
		{
			size_t index = path.find('/', 1);
			if (index < path.size())
			{
				itemexpanded(item);
				modelTreeView->setOpen(item, true);
				path = path.substr(index);
			}
			else
			{
				modelTreeView->setSelected(item, true);
				path = "";
			}
		}
		else
		{
			return;
		}
	}
}

void LDViewModelTree::show(void)
{
	raise();
	setActiveWindow();
	fillTreeView();
	ModelTreePanel::show();
}

void LDViewModelTree::fillTreeView(void)
{
	if(!modeltree)
	{
		if(mainmodel)
		{
			modeltree = new LDModelTree(mainmodel);
		}
		updateLineChecks();
		refreshTreeView();
		StringList paths = m_modelWindow->getModelViewer()->getHighlightPaths();
		for (StringList::const_iterator it = paths.begin(); it != paths.end(); it++)
		{
			selectFromHighlightPath(*it);
		}
	}
}

void LDViewModelTree::refreshTreeView()
{
	modelTreeView->clear();
	addChildren(NULL, modeltree);
}

void LDViewModelTree::addChildren(QListViewItem *parent, const LDModelTree *tree)
{
	if (tree != NULL && tree->hasChildren(true))
	{
		const LDModelTreeArray *children = tree->getChildren(true);
		int count = children->getCount();

		for (int i = 0; i < count; i++)
		{
			const LDModelTree *child = (*children)[i];
			addLine(parent, child);
		}
	}
}

void LDViewModelTree::addLine(QListViewItem *parent, const LDModelTree *tree)
{
	QString line = QString(tree->getText().c_str());
    QListViewItem *item;

    if (parent)
    {
        if (parent->childCount() > 0)
        {
            QListViewItem *lastChild = parent->firstChild();

            while (lastChild->nextSibling() != NULL)
            {
                lastChild = lastChild->nextSibling();
            }
            item = new QListViewItem(parent, lastChild, line);
        }
        else
        {
            item = new QListViewItem(parent, line);
		}
	}
	else
	{
		item = new QListViewItem(modelTreeView, 
								 modelTreeView->lastItem(), line);
	}
	item->setExpandable(tree->getNumChildren(true)>0);
}

void LDViewModelTree::updateLineChecks(void)
{
	if (!modeltree) return;
	preferences->setButtonState(unknownButton,
								modeltree->getShowLineType(LDLLineTypeUnknown));
	preferences->setButtonState(commentButton,
								modeltree->getShowLineType(LDLLineTypeComment));
	preferences->setButtonState(modelButton,
								modeltree->getShowLineType(LDLLineTypeModel));
	preferences->setButtonState(lineButton,
								modeltree->getShowLineType(LDLLineTypeLine));
	preferences->setButtonState(quadButton,
								modeltree->getShowLineType(LDLLineTypeQuad));
	preferences->setButtonState(triangleButton,
								modeltree->getShowLineType(LDLLineTypeTriangle));
	preferences->setButtonState(conditionalLineButton,
								modeltree->getShowLineType(LDLLineTypeConditionalLine));
}

void LDViewModelTree::itemexpanded(QListViewItem *item)
{
	LDModelTree *tree = findTree(item);
	if (tree && !tree->getViewPopulated())
	{
		addChildren(item, tree);
		tree->setViewPopulated(true);
	}
}

void LDViewModelTree::selectionChanged(QListViewItem *item)
{
	if (item)
	{
		LDModelTree *tree = findTree(item);
		QString qs;
		if (highlightSelectedLineBox->isChecked())
		{
			m_modelWindow->getModelViewer()->setHighlightPaths(
						tree->getTreePath());
		}
		ucstringtoqstring(qs,tree->getStatusText());
		statusText->setText(qs);
	}
}

LDModelTree *LDViewModelTree::findTree(QListViewItem *item)
{
	LDModelTree *tparent = NULL;
	QListViewItem *list;
	if (item->parent())
	{
		list = item->parent()->firstChild();
		tparent = findTree(item->parent());
	}
	else
	{
		tparent = modeltree;
		list = modelTreeView->firstChild();
	}
	const LDModelTreeArray *children = tparent->getChildren(true);
	int i=0;
    while (list->nextSibling() != NULL && list != item)
    {
        list = list->nextSibling();
		i++;
    }
	if (list == item)
		return (LDModelTree *)(*children)[i];
	else
		return NULL;
}

void LDViewModelTree::doLineCheck(QCheckBox *button, LDLLineType lineType)
{
	if (modeltree) 
	{
		modeltree->setShowLineType(lineType,button->state());
		refreshTreeView();
	}
}

void LDViewModelTree::setModel(LDLMainModel *model)
{
    if (mainmodel != model)
    {
        modeltree = NULL;
        mainmodel = model;
    }
}

void LDViewModelTree::modelAlertCallback(TCAlert *alert)
{
    if (alert->getSender() == (TCAlertSender*)m_modelWindow->getModelViewer())
    {
        if (ucstrcmp(alert->getMessageUC(), _UC("ModelLoaded")) == 0)
        {
            setModel(m_modelWindow->getModelViewer()->getMainModel());
            fillTreeView();
        }
        else if (ucstrcmp(alert->getMessageUC(), _UC("ModelLoadCanceled")) == 0)
        {
            setModel(NULL);
            fillTreeView();
        }
    }
}

void LDViewModelTree::setModelWindow(ModelViewerWidget *modelWindow)
{
    if (modelWindow != m_modelWindow)
    {
		m_modelWindow = modelWindow;
    }
    setModel(m_modelWindow->getModelViewer()->getMainModel());
}

void LDViewModelTree::hideOptions()
{
//	resize(size()-QSize(showLinesBox->size().width(),0));
	optionsShown = false;
	showLinesBox->hide();
	optionsButton->setText(optionsButton->text().replace(QChar('<'),
														 QChar('>')));

}

void LDViewModelTree::showOptions()
{
    optionsShown = true;
    showLinesBox->show();
//	resize(size()+QSize(showLinesBox->size().width(),0));
    optionsButton->setText(optionsButton->text().replace(QChar('>'),
													  	 QChar('<')));
}

void LDViewModelTree::toggleOptions()
{
	if (optionsShown)
		hideOptions();
	else
		showOptions();
	TCUserDefaults::setBoolForKey(optionsShown, MODEL_TREE_OPTIONS_SHOWN_KEY,
								  false);
}

void LDViewModelTree::highlightSelectedLine()
{
	bool checked = highlightSelectedLineBox->isChecked();
	if (!checked)
		m_modelWindow->getModelViewer()->setHighlightPaths("");
	else
		selectionChanged(modelTreeView->selectedItem());
	TCUserDefaults::setBoolForKey(checked, MODEL_TREE_HIGHLIGHT_KEY, false);
}

void LDViewModelTree::highlightColor()
{
	long r,g,b;
	QColor color = QColorDialog::getColor(highlightColorEdit->paletteBackgroundColor());
	if(color.isValid())
	{
		highlightColorEdit->setPaletteBackgroundColor(color);
		m_modelWindow->getModelViewer()->setHighlightColor(
				r = color.red(), g = color.green(), b = color.blue());
		TCUserDefaults::setLongForKey(
			(r<<16 | g<<8 | b),
			MODEL_TREE_HIGHLIGHT_COLOR_KEY, false);
	}
}

