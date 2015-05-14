//  Xcode.h
#import <Cocoa/Cocoa.h>

@interface IDESourceControlManager : NSObject
+ (IDESourceControlManager *)sharedSourceControlManager;
@property(readonly) NSArray *workingTrees; // @synthesize workingTrees=_workingTrees; // zzz
- (id)arrayOfWorkingCopyConfigurationDictionaries;
- (id)workingCopyConfigurations; // zzz
- (id)arrayOfProjectDictionaries; // zzz
@property(readonly) NSArray *repositories; // @synthesize repositories=_repositories; // zzz

@property(readonly) NSArray *projects; // @synthesize projects=_projects; // zzz
- (void)performRequest:(id)arg1 waitUntilFinished:(BOOL)arg2 withCompletionBlock:(id)arg3;
@end

@interface IDEPathControl : NSPathControl
+ (Class)cellClass;
- (void)setDelegate:(id)arg1;
@end


@interface DVTDiffDataSource : NSObject <NSCopying>
{
    id _content;
    NSString *_label;
    unsigned long long _timestamp;
    //    struct _DVTDiffContextFlags _dcFlags;
}

+ (id)diffDataSourceWithContent:(id)arg1;
@property struct _DVTDiffContextFlags dcFlags; // @synthesize dcFlags=_dcFlags;
@property unsigned long long timestamp; // @synthesize timestamp=_timestamp;
- (id)tokenStringWithTokenRange:(struct _NSRange)arg1;
- (id)tokenStringWithPrefix:(id)arg1 tokenRange:(struct _NSRange)arg2;
- (void)appendTokenStringToString:(id)arg1 tokenRange:(struct _NSRange)arg2;
- (void)appendTokenStringToString:(id)arg1 prefix:(id)arg2 tokenRange:(struct _NSRange)arg3;
- (void)appendLabelToString:(id)arg1 prefix:(id)arg2;
- (unsigned long long)diffTokenHashWithRange:(struct _NSRange)arg1;
- (unsigned long long)diffTokenHashInDiffDescriptor:(id)arg1 range:(struct _NSRange)arg2;
- (long long)numberOfDiffTokens;
- (long long)numberOfDiffTokensInDiffDescriptor:(id)arg1;
- (struct _DVTDiffToken)diffTokenAtIndex:(long long)arg1;
- (void)getDiffTokens:(struct _DVTDiffToken *)arg1 inDiffDescriptor:(id)arg2 inRange:(struct _NSRange)arg3;
- (struct _DVTDiffToken)diffTokenInDiffDescriptor:(id)arg1 atIndex:(long long)arg2;
- (BOOL)isEqual:(id)arg1;
- (BOOL)isEqualToDiffDataSource:(id)arg1;
@property(retain) NSString *label; // @synthesize label=_label;
- (id)THREAD_arrangedContent;
- (id)arrangedContent;
@property(readonly) id THREAD_content;
@property(retain) id content; // @synthesize content=_content;
- (BOOL)_setContent:(id)arg1;
- (void)didChangeContent;
- (void)willChangeContent;
- (void)didChange;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (id)init;
- (id)initWithContent:(id)arg1;

@end


@interface DVTDiffSession : NSObject
@property(retain) NSData *mergeTextDigest; // @synthesize mergeTextDigest=_mergeTextDigest;
@property(readonly) DVTDiffDataSource *originalDataSource;
@property(readonly) DVTDiffDataSource *modifiedDataSource;
@property(readonly) DVTDiffDataSource *ancestorDataSource;
@property unsigned long long conflictCount; // @synthesize conflictCount=_conflictCount;
//@property(retain) DVTTextStorage *mergeTextStorage; // @synthesize mergeTextStorage=_mergeTextStorage;
@property(retain) NSUndoManager *undoManager; // @synthesize undoManager=_undoManager;
@property unsigned long long timestamp; // @synthesize timestamp=_timestamp;
@property(retain) NSString *diffString; // @synthesize diffString=_diffString;
@property unsigned long long selectedDiffDescriptorIndex; // @synthesize selectedDiffDescriptorIndex=_selectedDiffDescriptorIndex;
@property(retain) NSIndexSet *modifiedDescriptorIndexes; // @synthesize modifiedDescriptorIndexes=_modifiedDescriptorIndexes;
@property(retain) NSIndexSet *commonDescriptorIndexes; // @synthesize commonDescriptorIndexes=_commonDescriptorIndexes;
@property(retain) NSArray *diffDescriptors; // @synthesize diffDescriptors=_diffDescriptors;
//@property(retain) DVTDiffContext *diffContext; // @synthesize diffContext=_diffContext;
- (void)_incrementTimestamp;
@property(retain) NSArray *mergeDescriptors; // @synthesize mergeDescriptors=_mergeDescriptors;
//@property(readonly) DVTDiffDescriptor *selectedMergeDescriptor;
//- (void)_loadDataSourcesWithOriginalDataSource:(id)arg1 modifiedDataSource:(id)arg2 ancestorDataSource:(id)arg3 restoringState:(BOOL)arg4;
//- (id)initWithOriginalDataSource:(id)arg1 modifiedDataSource:(id)arg2 ancestorDataSource:(id)arg3 undoManager:(id)arg4 mergeTextStorage:(id)arg5 mergeState:(id)arg6;
//- (id)initWithOriginalDataSource:(id)arg1 modifiedDataSource:(id)arg2 ancestorDataSource:(id)arg3 mergeState:(id)arg4;
//- (id)initWithBinaryConflictResolutionMergeState:(id)arg1;
//- (id)initWithOriginalBinaryDataSource:(id)arg1 modifiedBinaryDataSource:(id)arg2 ancestorBinaryDataSource:(id)arg3;

// Remaining properties
//@property(retain) DVTStackBacktrace *creationBacktrace;
//@property(readonly) DVTStackBacktrace *invalidationBacktrace;
//@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

@protocol DVTSimpleSerialization
- (void)dvt_writeToSerializer:(id)arg1;
- (id)dvt_initFromDeserializer:(id)arg1;
@end

@interface DVTDocumentLocation : NSObject  <NSCoding, NSCopying, DVTSimpleSerialization>
- (DVTDocumentLocation *)initWithDocumentURL:(NSURL *)documentURL timestamp:(NSNumber *)timestamp;

@property(readonly) NSNumber *timestamp; // @synthesize timestamp=_timestamp;
@property(readonly) NSURL *documentURL; // @synthesize documentURL=_documentURL;

@end

@interface IDEEditorOpenSpecifier : NSObject
+ (IDEEditorOpenSpecifier *)structureEditorOpenSpecifierForDocumentLocation:(DVTDocumentLocation *)documentLocation inWorkspace:(id)workspace error:(NSError *)error;
@end

@interface DVTModelObject : NSObject
@end

@interface DVTFilePath : NSObject
+ (id)rootFilePath;
@property (readonly) NSURL *fileURL;
@property(readonly) NSURL *fileReferenceURL;
@property(readonly) NSArray *sortedDirectoryContents;
@property(readonly) NSArray *directoryContents;
@property(readonly) NSDate *modificationDate;

@property(readonly) NSString *fileName;
@property(readonly) NSArray *pathComponents;
@property(readonly) NSString *pathString;
@property(readonly) DVTFilePath *volumeFilePath;
@property(readonly) DVTFilePath *parentFilePath;
@end

@interface IDEContainerItem : DVTModelObject
@end

@interface IDEGroup : IDEContainerItem
- (NSArray *)subitems;
- (NSImage *)navigableItem_image;
@end

@interface IDEContainer : DVTModelObject
- (DVTFilePath *)filePath;
- (IDEGroup *)rootGroup;
- (void)debugPrintInnerStructure;
- (void)debugPrintStructure;
@end

@interface IDEWorkspace : IDEContainer
- (NSSet *)referencedContainers;
@property(readonly) DVTFilePath *representingFilePath;
@property(readonly) NSString *name;

@end

@interface IDEWorkspaceDocument : NSDocument
@property (readonly) IDEWorkspace *workspace;
@end

@interface IDEEditorDocument : NSDocument
@end

@interface IDESourceCodeDocument : IDEEditorDocument
- (DVTFilePath *)filePath;
- (NSArray *)knownFileReferences;
- (id)diffDataSource;
@end

@interface DVTViewController : NSViewController
@end

@interface IDEViewController : DVTViewController
@end

@interface IDEComparisonNavTimelineBar : IDEViewController

//@property(readonly) IDEComparisonEditorChangesStepperView *changesStepperControl;
@property(readonly) IDEPathControl *secondaryPathControl;
@property(readonly) IDEPathControl *primaryPathControl;
@property BOOL hideChangesStepperControl;
@property BOOL hideTimelineButton;
@property BOOL hideSecondaryPathControl;
- (void)layoutAttachedWindow;
- (void)toggleTimelineVisibility:(id)arg1;
- (void)hideTimeline;
- (void)showTimeline;

@end

@interface IDEEditor : IDEViewController
@property(retain) IDEEditorDocument *document;
@end

@interface IDEEditorEmpty : IDEEditor
@end

@protocol IDEComparisonEditorDataSource <NSObject>
- (id)documentForSecondaryDocumentLocation:(id)arg1 completionBlock:(id)arg2;
- (id)documentForPrimaryDocumentLocation:(id)arg1 completionBlock:(id)arg2;

@optional
- (id)contentStringForSecondaryEmptyEditorWithDocumentLocation:(id)arg1;
- (id)contentStringForPrimaryEmptyEditorWithDocumentLocation:(id)arg1;
- (BOOL)shouldShowEmptyEditorForSecondaryDocumentLocation:(id)arg1 submodeType:(int)arg2;
- (BOOL)shouldShowEmptyEditorForPrimaryDocumentLocation:(id)arg1 submodeType:(int)arg2;
- (id)documentForAncestorDocumentLocation:(id)arg1 completionBlock:(id)arg2;
- (id)navigableItemsForSecondaryDocumentLocation:(id)arg1 usingNavigableItemCoordinator:(id)arg2 completionBlock:(id)arg3;
- (id)navigableItemsForPrimaryDocumentLocation:(id)arg1 usingNavigableItemCoordinator:(id)arg2 completionBlock:(id)arg3;
- (id)navigableItemsForPrimaryDocumentLocation:(id)arg1 secondaryDocumentLocation:(id)arg2 usingNavigableItemCoordinator:(id)arg3 forceReload:(BOOL)arg4 completionBlock:(id)arg5;
- (BOOL)shouldSelectFirstDiff;
- (id)secondaryDocumentLocationForNavigableItem:(id)arg1;
- (id)primaryDocumentLocationForNavigableItem:(id)arg1;
@end

@interface IDESourceControlComparisonEditorDataSource : NSObject <IDEComparisonEditorDataSource>//, DVTInvalidation>

@property(retain) IDEEditorDocument *originalDocument; // @synthesize originalDocument=_originalDocument;
- (id)documentForAncestorDocumentLocation:(id)arg1 completionBlock:(id)arg2;
- (id)documentForSecondaryDocumentLocation:(id)arg1 completionBlock:(id)arg2;
- (id)documentForPrimaryDocumentLocation:(id)arg1 completionBlock:(id)arg2;
- (id)contentStringForSecondaryEmptyEditorWithDocumentLocation:(id)arg1;
- (id)contentStringForPrimaryEmptyEditorWithDocumentLocation:(id)arg1;
- (BOOL)shouldShowEmptyEditorForSecondaryDocumentLocation:(id)arg1 submodeType:(int)arg2;
- (BOOL)shouldShowEmptyEditorForPrimaryDocumentLocation:(id)arg1 submodeType:(int)arg2;
- (id)_calculateSelectedRevisionForWorkingTreeItem:(id)arg1 selectedBranch:(id)arg2 selectedRevisionIdenfier:(id)arg3 baseRevision:(id)arg4 headRevision:(id)arg5 allRevisions:(id)arg6 error:(id *)arg7;
- (id)_calculateRevisionsForWorkingTreeItem:(id)arg1 withSelectedRevision:(id *)arg2 selectedBranch:(id)arg3 selectedRevisionIdenfier:(id)arg4 currentRevision:(id)arg5 error:(id *)arg6;
- (id)_selectedRevisionForRevisionIdentifier:(id)arg1 currentRevision:(id)arg2 inRevisions:(id)arg3;
- (id)_navigableItemsForPrimaryDocumentLocation:(id)arg1 secondaryDocumentLocation:(id)arg2 usingNavigableItemCoordinator:(id)arg3 usingQueue:(id)arg4 forceReload:(BOOL)arg5 completionBlock:(id)arg6;
- (id)navigableItemsForPrimaryDocumentLocation:(id)arg1 secondaryDocumentLocation:(id)arg2 usingNavigableItemCoordinator:(id)arg3 forceReload:(BOOL)arg4 completionBlock:(id)arg5;
- (id)_documentLocationForNavigableItem:(id)arg1;
- (id)secondaryDocumentLocationForNavigableItem:(id)arg1;
- (id)primaryDocumentLocationForNavigableItem:(id)arg1;
- (id)_documentLocationForRevisionName:(id)arg1 inBranch:(id)arg2;
//- (void)primitiveInvalidate;
//- (id)init;
@end

@class IDEComparisonEditorSubmode;
@interface IDEComparisonEditor : IDEEditor
@property(retain) IDEComparisonNavTimelineBar *navTimelineBar;
@property(retain) IDEEditorDocument *secondaryDocument;
@property(retain) IDEEditorDocument *primaryDocument;
@property(retain) id <IDEComparisonEditorDataSource> dataSource;
- (BOOL)isCurrentPrimaryRevisionInMemoryOrLocal;
@property(readonly) IDEComparisonEditorSubmode *submode;
@end

@interface IDESourceCodeEditor : IDEEditor
@property (readonly) IDESourceCodeDocument *sourceCodeDocument;
@property (retain) NSTextView *textView;

- (long)_currentOneBasedLineNubmer;
- (id)_documentLocationForLineNumber:(long)a0;
- (void)selectDocumentLocations:(id)a0 highlightSelection:(BOOL)a1;
- (void)selectAndHighlightDocumentLocations:(id)a1;
- (void)selectDocumentLocations:(id)a1;
@end

@interface IDESourceCodeComparisonEditor : IDEComparisonEditor
@property (readonly) NSTextView *keyTextView;
@property(retain) IDEEditorDocument *primaryDocument;
@end

@interface IDENavigableItemCoordinator : NSObject
- (id)rootNavigableItemWithRepresentedObject:(id)arg1;
@end

@interface IDEEditorContext : NSObject
- (id)initWithNibName:(id)arg1 bundle:(id)arg2;
- (id)editor;
- (BOOL)openEditorOpenSpecifier:(id)openSpecifier;

@property(readonly) IDENavigableItemCoordinator *navigableItemCoordinator;
@end

@interface IDEEditorModeViewController : IDEViewController
@property(retain) IDEEditorContext *selectedAlternateEditorContext;
@property(retain, nonatomic) IDEEditorContext *primaryEditorContext;
@end

@interface IDEComparisonEditorSubmode : IDEViewController
@property(readonly) IDEEditor *secondaryEditor;
@property(readonly) IDEEditor *primaryEditor;
@property(readonly) IDEEditor *keyEditor;
@property(readonly) IDEComparisonEditor *comparisonEditor;
//@property(readonly) DVTDiffSession *diffSession;
@end

@interface IDESourceCodeVersionsTwoUpSubmode : IDEComparisonEditorSubmode
@property(retain) IDEEditor *secondaryEditor;
@property(retain) IDEEditor *primaryEditor;


- (id)currentSelectedDocumentLocations;
- (id)currentSelectedItems;
- (void)showEmptySecondaryEditor:(id)arg1;
- (void)showEmptyPrimaryEditor:(id)arg1;
- (void)hideSecondaryPlaceholder;
- (void)showSecondaryPlaceholder;
- (void)hidePrimaryPlaceholder;
- (void)showPrimaryPlaceholder;

@property(retain) DVTDiffSession *diffSession;
@end

@class IDEComparisonEditorSubmode;
@interface IDEEditorVersionsMode : IDEEditorModeViewController
@property BOOL showMiniIssueNavigator;// toggles the miniIssueNavigator situated in the top right corner
@property(readonly) IDEComparisonEditorSubmode *comparisonEditorSubmode;
@property(readonly) IDEComparisonEditor *comparisonEditor;
- (id)editorContexts;
@end

@interface IDEEditorArea : NSObject
- (id)lastActiveEditorContext;
- (void)_setShowDebuggerArea:(BOOL)arg1 animate:(BOOL)arg2;
@property(retain) IDEEditorModeViewController *editorModeViewController;
@end

@interface DVTTextDocumentLocation : NSObject
@property (readonly) NSRange characterRange;
@property (readonly) NSRange lineRange;
@end

@interface IDEWorkspaceTabController : IDEViewController
- (void)changeToGeniusEditor:(id)arg1; // invoked with nil shows the version editor with no selection
- (void)changeToVersionEditorComparisonView:(id)arg1;
@property(readonly) IDEEditorArea *editorArea;
@end

@interface IDEWorkspaceWindowController : NSWindowController
- (IDEEditorArea *)editorArea;
+ (id)workspaceWindowControllers;
- (IDEWorkspaceTabController *)newTabWithName:(NSString *)name cloneExisting:(BOOL)arg2;
@property(readonly) IDEWorkspaceTabController *activeWorkspaceTabController;
@end

@interface IDEToolbarDelegate : NSObject
- (id)toolbar:(id)arg1 itemForItemIdentifier:(id)arg2 willBeInsertedIntoToolbar:(BOOL)arg3;
@end

@interface DVTSplitView : NSSplitView
- (id)splitViewItems;
@end

@interface DVTSplitViewItem : NSObject
@property(nonatomic, getter=isVisible) BOOL visible;
@property(copy, nonatomic) NSString *identifier;
@property(retain) NSView *view;
@property DVTSplitView *splitView;
@end

@protocol IDEReviewFilesDataSource <NSObject>
- (id)reviewFilesNavigator:(id)arg1 documentLocationForNavigableItem:(id)arg2;
- (id)reviewFilesNavigator:(id)arg1 outlineView:(id)arg2 dataCellForNavigableItem:(id)arg3;
- (id)issueNavigableItems;
- (id)flatNavigableItems;
- (id)fileSystemNavigableItems;
- (id)workspaceNavigableItems;

@optional
- (double)reviewFilesNavigator:(id)arg1 outlineView:(id)arg2 rowHeightForNavigableItem:(id)arg3;
- (void)reviewFilesNavigator:(id)arg1 outlineView:(id)arg2 willDisplayCell:(id)arg3 forNavigableItem:(id)arg4;
- (id)reviewFilesNavigator:(id)arg1 importantFilePathsForNavigableItem:(id)arg2 excludingDisabledItems:(id)arg3;
@end

@class IDEReviewFilesNavigator;
@interface IDEReviewFilesViewController : IDEViewController// <IDEEditorContextDelegate, IDESourceControlMergeControllerContainer>
{
    //    DVTSplitView *_splitView;
    //    DVTBorderedView *_structureBorderedView;
    //    DVTBorderedView *_comparisonBorderedView;
    //    IDEReviewFilesNavigator *_navigator;
    //    IDEEditorVersionsMode *_versionsMode;
    //    DVTObservingToken *_navigatorSelectedViewIndexesObservingToken;
    //    DVTObservingToken *_navigatorSelectedObjectsObservingToken;
    //    id <IDEReviewFilesViewControllerDelegate> _delegate;
    //    IDESourceControlConflictResolutionController *_conflictResolutionController;
    //    IDESourceControlInteractiveCommitController *_interactiveCommitController;
}

+ (id)keyPathsForValuesAffectingVersionsEditor;
+ (id)keyPathsForValuesAffectingComparisonEditor;
+ (struct CGRect)minimumSheetFrame;
+ (struct CGSize)sheetSizeForHostWindow:(id)arg1;
+ (id)reviewFilesLogAspect;
//@property(retain) id <IDEReviewFilesViewControllerDelegate> delegate;
@property(readonly) IDEEditorVersionsMode *versionsMode; // @synthesize versionsMode=_versionsMode;
@property(readonly) IDEReviewFilesNavigator *navigator; // @synthesize navigator=_navigator;

- (BOOL)splitView:(id)arg1 shouldAdjustSizeOfSubview:(id)arg2;
- (double)splitView:(id)arg1 constrainMaxCoordinate:(double)arg2 ofSubviewAt:(long long)arg3;
- (double)splitView:(id)arg1 constrainMinCoordinate:(double)arg2 ofSubviewAt:(long long)arg3;
- (BOOL)splitView:(id)arg1 canCollapseSubview:(id)arg2;
- (id)workspaceForEditorContext:(id)arg1;
- (id)editorContext:(id)arg1 shouldEditNavigableItem:(id)arg2;
//@property(readonly) IDESourceControlInteractiveCommitController *interactiveCommitController; // @dynamic interactiveCommitController;
- (void)setupInteractiveCommitController;
//@property(readonly) IDESourceControlConflictResolutionController *conflictResolutionController; // @dynamic conflictResolutionController;
- (void)setupConflictResolutionController;
- (void)primitiveInvalidate;
@property(readonly) IDEEditorVersionsMode *versionsEditor;
@property(readonly) IDEComparisonEditor *comparisonEditor;
- (void)viewDidInstall;
- (void)loadView;
- (id)initWithNibName:(id)arg1 bundle:(id)arg2;

@end

@interface DVTModelTree : NSObject
@end

@interface IDESourceControlTree : DVTModelTree
- (id)copyRepository;
@property(copy) NSString *location;
+ (id)treeLoadingModelObjectGraph;
@end

@interface DVTModelTreeNode : NSObject
@end

@class IDESourceControlRevision;
@interface IDESourceControlTreeItem : DVTModelTreeNode

@property unsigned long long conflictStateForUpdateOrMerge; // @synthesize conflictStateForUpdateOrMerge=_conflictStateForUpdateOrMerge;
@property int sourceControlServerStatus; // @synthesize sourceControlServerStatus=_sourceControlServerStatus;
@property int sourceControlLocalStatus; // @synthesize sourceControlLocalStatus=_sourceControlLocalStatus;
@property unsigned long long state; // @synthesize state=_state;
@property(readonly) NSString *pathString; // @synthesize pathString=_pathString;
@property(copy) NSString *name; // @synthesize name=_name;
- (BOOL)isEqual:(id)arg1;
- (unsigned long long)hash;
- (id)exportToFileURL:(id)arg1 completionBlock:(id)arg2;
- (void)clearAllRevisions;
- (id)revisionsWithStartingRevision:(id)arg1 endingRevision:(id)arg2 limit:(unsigned long long)arg3 branch:(id)arg4 completionBlock:(id)arg5;
@property(readonly) NSArray *revisions;
- (id)revisionsDictionary;
- (void)addRevision:(id)arg1;
- (void)clearCurrentRevision;
- (id)currentRevisionWithCompletionBlock:(id)arg1;
- (void)setCurrentRevision:(id)arg1;
//@property(readonly) IDESourceControlRevision *currentRevision;
- (int)aggregateSourceControlServerStatus;
- (int)aggregateSourceControlLocalStatus;
- (id)baseRevisionWithCompletionBlock:(id)arg1;
- (id)headRevisionWithCompletionBlock:(id)arg1;
- (void)setBASERevision:(id)arg1;
- (void)setHEADRevision:(id)arg1;
- (id)description;
- (id)ideModelObjectTypeIdentifier;
- (void)repositoryURLStringAtBranch:(id)arg1 completionBlock:(id)arg2;
@property(readonly) NSString *repositoryURLString;
- (void)_setPathString:(id)arg1;
- (void)primitiveInvalidate;
- (id)initWithPathString:(id)arg1;
@end


@interface IDENavigableItem : NSObject
- (id)initWithRepresentedObject:(id)arg1;
@property(readonly) id representedObject;
@property(readonly) IDENavigableItemCoordinator *navigableItemCoordinator;
@end

@interface IDENavigator : IDEViewController
@property(retain, nonatomic) IDENavigableItem *rootNavigableItem;
@end

@interface IDEReviewFilesNavigator : IDENavigator
@property(copy) NSString *selectedChoiceWithoutWorkspaceKey;
@property(copy) NSString *selectedChoiceWithWorkspaceKey;
@property(retain) id <IDEReviewFilesDataSource> flatDataSource;
@property(retain) id <IDEReviewFilesDataSource> fileSystemDataSource;
@property BOOL showCheckboxes;

@end

@interface IDEKeyDrivenNavigableItem : IDENavigableItem
@end

//@interface IDEKeyDrivenNavigableItem_AnyIDESourceControlTreeItem : IDEKeyDrivenNavigableItem
//@end

@interface IDESourceControlTreeGroup : IDESourceControlTreeItem
@end


@interface IDESourceControlRepository : IDESourceControlTree
@property(retain) NSURL *URL;
- (IDESourceControlTreeGroup *)itemAtURL:(NSURL *)url isGroup:(BOOL)isGroup;
- (BOOL)containsItemAtLocation:(id)arg1;
- (id)initWithLocation:(id)arg1 sourceControlManager:(id)arg2;
@end

@interface IDESourceControlCommitViewerNavigatorDataSource : NSObject <IDEReviewFilesDataSource>//, DVTInvalidation>
{
    //    IDENavigatorDataCell *_cachedSourceTreeItemCell;
    //    IDENavigatorDataCell *_cachedRepositoryContainerCell;
    //    NSArray *_navigableItems;
    //    IDESourceControlRepository *_repository;
    //    NSMutableSet *_bindingTokens;
}

@property(retain) IDESourceControlRepository *repository; // @synthesize repository=_repository;
@property(retain) NSArray *navigableItems; // !!! these are set in [IDESourceControlCommitViewerWindowController _configureDataSources]
- (void)primitiveInvalidate;
- (id)reviewFilesNavigator:(id)arg1 documentLocationForNavigableItem:(id)arg2;
- (id)reviewFilesNavigator:(id)arg1 outlineView:(id)arg2 dataCellForNavigableItem:(id)arg3;
- (id)repositoryContainerCell;
- (id)sourceTreeItemCell;
- (id)sourceControlCategoryStatusCellsWithRepresentedObject:(id)arg1;
- (id)issueNavigableItems;
- (id)flatNavigableItems;
- (id)fileSystemNavigableItems;
- (id)workspaceNavigableItems;
- (id)init;

//// Remaining properties
//@property(retain) DVTStackBacktrace *creationBacktrace;
//@property(readonly) DVTStackBacktrace *invalidationBacktrace;
//@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

@interface IDESourceControlLogItem : NSObject

@property BOOL isChangedFilesExpanded;
@property(readonly) NSArray *itemsWithStatus;
@property(readonly) IDESourceControlRepository *filesChangedRepository;
@property(readonly) IDESourceControlTree *sourceTree;
@property(retain) NSDictionary *filesWithStatus;
@property(retain) NSString *message;
@property(readonly) NSDate *date;
@property(readonly) NSString *revision;
//@property(readonly) IDESourceControlPerson *author;
- (void)loadFilesChanged;
- (id)initWithAuthor:(id)arg1 revision:(id)arg2 date:(id)arg3 message:(id)arg4 filesWithStatus:(id)arg5 sourceTree:(id)arg6;

@end

@interface IDESourceControlWorkingTree : IDESourceControlTree
- (id)initWithDictionary:(id)arg1 repository:(id)arg2 sourceControlExtension:(id)arg3 sourceControlManager:(id)arg4;
- (id)initWithLocation:(id)arg1 sourceControlManager:(id)arg2;
@property(readonly) IDESourceControlRepository *repository;
@end

@interface IDESourceControlLog : NSObject

- (void)invalidate;
+ (id)logAspect;
+ (void)initialize;
@property(getter=isDatasourceExternal) BOOL datasourceExternal; // @synthesize datasourceExternal=_datasourceExternal;
@property(retain) NSArray *logContents; // @synthesize logContents=_logContents;
@property(copy) NSString *endingRevision; // @synthesize endingRevision=_endingRevision;
@property(copy) NSString *startingRevision; // @synthesize startingRevision=_startingRevision;
@property(copy) NSString *searchTerm; // @synthesize searchTerm=_searchTerm;
@property(retain) NSArray *authors; // @synthesize authors=_authors;
@property(retain) NSString *branchName; // @synthesize branchName=_branchName;
@property BOOL displayFilesChanged; // @synthesize displayFilesChanged=_displayFilesChanged;
@property(readonly) NSArray *logItems; // logItems are the same as returned by the completion block in loadLogItemsFromRevisions:completionBlock: except that they come as an array of dicts containing the date for a date and the logItems for this date
- (void)previousLogItemOfRevision:(id)arg1 completionBlock:(id)arg2;
- (void)logItemForRevision:(id)arg1 completionBlock:(id)arg2;
- (id)_logItemForRevision:(id)arg1;

// how to get the signature for a block:
// http://ddeville.me/2013/02/block-debugging/
// steps:
// 1) method swizzle this method
// 2) add a breakpoint within the swizzled method and stop there
// 3) (lldb) memory read --size 8 --format x <address of block>
// 3b) (lldb) memory read --size 4 --format x <address of block> 3. value should be (<3rd value> & (1 « 30)) != 0) to check if block signature is there
// 4) (lldb) memory read --size 8 --format x <4th address of 3)>
// 5) (lldb) p (const char *) <3rd address of 4)>
// 6) (lldb) po [NSMethodSignature signatureWithObjCTypes:<value of 5>]

// revisions
- (id)loadLogItemsFromRevisions:(NSArray *)revisionStrings completionBlock:(void (^)(NSArray *array, BOOL aBool, NSError *error))completion;
- (id)_computeLogsWithResult:(id)arg1 indexOfSourceTree:(unsigned long long)arg2 startingRevision:(id)arg3 sourceTree:(id)arg4;
- (id)createLogItemFromLogInfo:(id)arg1 withSourceTreeItem:(IDESourceControlWorkingTree *)workingTree;
- (void)arrangeLogEntries:(id)arg1;
- (void)setLogContentsWithItems:(id)arg1;
- (void)clearLog;
- (void)cancelAllLogRequests;
- (void)removeLogRequest:(id)arg1;
- (void)addLogRequest:(id)arg1;
- (void)_resetLastRevisionsLoaded;
@property(retain) NSArray *sourceTreeItems;
- (void)primitiveInvalidate;
@property(readonly) NSArray *lastRevisionsLoaded;
- (id)init;
@end


@class DVTComparisonDocumentLocation;
@interface IDESourceControlCommitViewerWindowController : NSWindowController
+ (void)runPreviewSheetForWindow:(NSWindow *)arg1 viewingCommit:(IDESourceControlLogItem *)arg2 onRepository:(IDESourceControlRepository *)arg3 itemsWithStatus:(NSArray *)sourceControlTreeItems withInitialSelection:(id)arg5; //arg5 maybe nil

- (void)willOpenDocumentLocation:(DVTComparisonDocumentLocation *)document completionBlock:(void (^)(IDEEditorOpenSpecifier *, NSError *))completion;
@end;


@interface IDESourceControlRevision : NSObject

+ (id)inMemoryRevision;
+ (IDESourceControlRevision *)localRevision;
+ (id)keyPathsForValuesAffectingLongRevisionString;
@property BOOL isCurrent; // @synthesize isCurrent=_isCurrent;
@property BOOL isBASE; // @synthesize isBASE=_isBASE;
@property BOOL isHEAD; // @synthesize isHEAD=_isHEAD;
@property(readonly) NSString *message; // @synthesize message=_message;
@property(readonly) NSDate *date; // @synthesize date=_date;
@property(readonly) NSString *author; // @synthesize author=_author;
@property(readonly) NSString *revision; // @synthesize revision=_revision;
- (BOOL)isEqual:(id)arg1;
- (unsigned long long)hash;
@property(readonly) NSString *longRevisionString;
- (id)ideModelObjectTypeIdentifier;
- (id)description;
- (IDESourceControlRevision *)initWithRevision:(NSString *)arg1 author:(NSString *)arg2 date:(NSDate *)arg3 message:(NSString *)arg4;

@end

@interface DVTComparisonDocumentLocation : DVTDocumentLocation
{
    DVTDocumentLocation *_primaryDocumentLocation;
    DVTDocumentLocation *_secondaryDocumentLocation;
    DVTDocumentLocation *_ancestorDocumentLocation;
}

@property(readonly) DVTDocumentLocation *ancestorDocumentLocation; // @synthesize ancestorDocumentLocation=_ancestorDocumentLocation;
@property(copy) DVTDocumentLocation *secondaryDocumentLocation; // @synthesize secondaryDocumentLocation=_secondaryDocumentLocation;
@property(copy) DVTDocumentLocation *primaryDocumentLocation; // @synthesize primaryDocumentLocation=_primaryDocumentLocation;

- (long long)compare:(id)arg1;
- (id)description;
- (BOOL)isEqualToDocumentLocationDisregardingDocumentURL:(id)arg1;
- (unsigned long long)hash;
- (BOOL)isEqualDisregardingTimestamp:(id)arg1;
- (BOOL)isEqual:(id)arg1;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)timestamp;
- (id)documentURL;
- (id)initWithDocumentURL:(id)arg1 timestamp:(id)arg2;
- (id)initWithPrimaryDocumentLocation:(id)arg1 secondaryDocumentLocation:(id)arg2 ancestorDocumentLocation:(id)arg3;

@end

@interface IDESourceControlRequest : NSObject
@property(copy) NSString *endingRevision;
@property(copy) NSString *startingRevision;
@end
