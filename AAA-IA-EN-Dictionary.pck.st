'From Cuis 5.0 of 7 November 2016 [latest update: #3099] on 23 June 2017 at 12:47:59 am'!
'Description Please enter a description for this package'!
!provides: 'AAA-IA-EN-Dictionary' 1 4!
!classDefinition: #IEENDict category: #'AAA-IA-EN-Dictionary'!
Object subclass: #IEENDict
	instanceVariableNames: 'resultIndex searchResult'
	classVariableNames: 'Data'
	poolDictionaries: ''
	category: 'AAA-IA-EN-Dictionary'!
!classDefinition: 'IEENDict class' category: #'AAA-IA-EN-Dictionary'!
IEENDict class
	instanceVariableNames: ''!

!classDefinition: #IEENDictView category: #'AAA-IA-EN-Dictionary'!
SystemWindow subclass: #IEENDictView
	instanceVariableNames: 'entryTextMorph resultMorph'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAA-IA-EN-Dictionary'!
!classDefinition: 'IEENDictView class' category: #'AAA-IA-EN-Dictionary'!
IEENDictView class
	instanceVariableNames: ''!


!IEENDict methodsFor: 'initialization' stamp: 'AAA 6/19/2017 20:56:15'!
initialize

	super initialize.
	searchResult _ #().
	resultIndex  _ 0.! !

!IEENDict methodsFor: 'read' stamp: 'matt 6/22/2017 19:49:22'!
resultAsList

	"Answer a list of form 'this <---> that' "
	
	^ searchResult collect: [:pair | (pair at: 1), '  <--->  ', (pair at: 2) ].! !

!IEENDict methodsFor: 'read' stamp: 'AAA 6/18/2017 09:36:07'!
resultIndex
	
	^ resultIndex! !

!IEENDict methodsFor: 'write' stamp: 'AAA 6/18/2017 10:05:12'!
resultIndex: aResultIndex
	
	resultIndex _ aResultIndex .! !

!IEENDict methodsFor: 'read' stamp: 'AAA 6/19/2017 21:35:39'!
search: aString lang: aLanguage method: aMethod

	self searchResult: (IEENDict search: aString lang: aLanguage method: aMethod) .
	self resultIndex: 0 .
! !

!IEENDict methodsFor: 'write' stamp: 'AAA 6/19/2017 21:17:20'!
searchResult: newResult

	searchResult _ newResult .
	self triggerEvent: #searchResultChanged .! !

!IEENDict class methodsFor: 'as yet unclassified' stamp: 'AAA 6/18/2017 16:19:17'!
initialize
	"Read in my data"
"
	IEENDict initialize.
"
	| curIndex aLine |
	Data _ Array new: 30811. "We know the exact size (wc -l iedict.txt) less 1"

	(self package fullFileName asFileEntry parent  // 'iedict.txt') readStreamDo: [ :fileStream |
		fileStream nextLine. "Skip initial comment line"
		curIndex _ 1.
		aLine _ fileStream nextLine. 
		[aLine isNil] whileFalse: [
			Data 
				at: curIndex 
				put: ((aLine findBetweenSubStrs: ':') 
						collect: [:str| str withBlanksTrimmed]). 
			aLine _ fileStream nextLine. 
			curIndex _ 1 + curIndex.
		]
	] ! !

!IEENDict class methodsFor: 'as yet unclassified' stamp: 'matt 6/22/2017 19:52:02'!
search: aString lang: aLanguage method: aMethod

	| search matchStrStarts matchStrContains |
	matchStrStarts _  aString , '*'  .
	matchStrContains _ ('*', aString, '*' ) .
	search  _ [ :for :at | Data select: [ :pairArray | for match: (pairArray at: at) ] ].

	aLanguage == #english & aMethod == #starts ifTrue: [ ^ (search value: matchStrStarts value: 2) ].
	aLanguage == #english & aMethod == #contains ifTrue: [ ^ (search value: matchStrContains value: 2) . ].
	aLanguage == #interlingua & aMethod == #starts ifTrue: [ ^ (search value: matchStrStarts value: 1). ].
	aLanguage == #interlingua & aMethod == #contains ifTrue: [ ^ (search value: matchStrContains value: 1) . ].
	^ #() .! !

!IEENDictView methodsFor: 'noise' stamp: 'matt 6/23/2017 00:21:46'!
buildMorphicWindow

	"
	Replaced by buildWindow.
	Why?
		To create an instance of IEENDictView, one has to do: 
			IEENDictView open .
		Which is traduced into:
			aIEENDictView  := self open: (IEENDict new) label: 'IE <--> EN' .
		where 'self' stands for  aIEENDictView class.
		
		Which is traduced into:
			window := self new.
			window
				model: model;
				buildMorphicWindow.
				aString ifNotNil: [ window setLabel: aString ].
			window openInWorld.
			
		And it turns out that any style change that may be done in:
			window buildMorphicWindow .
				(your stuff are supposed to go here)
			
		Has a good chance to be overwritten by:
			window openInWorld.
				(some stuff are done here that may overwrite your stuff)
			
		Which leads to complications: going forward two steps then one step behind.
		
		On the other hand, one may wait for the instanciation of open:label: to finish and then do
		whatever he wants with the guaranty that nothing by someone else will override  the 
		modifications done.
			
		This is why the function of IEENDictView>>buildMorphicWindow has been replaced by IEENDictView>>buildWindow .
	"! !

!IEENDictView methodsFor: 'initialization' stamp: 'AAA 6/19/2017 21:21:07'!
buildWindow

	self layoutMorph
		beColumn ;
		layoutSpec: LayoutSpec useAll ;
		color: Color white ;
		separation: self defaultSeparation ;
		addMorph: self makeEntryArea ;
		addMorph: self makeButtonArea ;
		addMorph: self makeResultArea .
		! !

!IEENDictView methodsFor: 'geometry' stamp: 'AAA 6/17/2017 23:31:35'!
defaultSeparation
	^ 5 "pixels"! !

!IEENDictView methodsFor: 'events' stamp: 'AAA 6/19/2017 20:42:40'!
englishContainsClick
	
	self model
		search: entryTextMorph contents asString
		lang: #english
		method: #contains! !

!IEENDictView methodsFor: 'events' stamp: 'AAA 6/19/2017 20:42:53'!
englishStartsClick
	
	self model
		search: entryTextMorph contents asString
		lang: #english
		method: #starts! !

!IEENDictView methodsFor: 'initialization' stamp: 'matt 6/22/2017 19:59:58'!
initInternalState

	self interlinguaStartsClick .! !

!IEENDictView methodsFor: 'events' stamp: 'AAA 6/19/2017 20:43:08'!
interlinguaContainsClick
	
	self model
		search: entryTextMorph contents asString
		lang: #interlingua
		method: #contains! !

!IEENDictView methodsFor: 'events' stamp: 'AAA 6/19/2017 20:43:26'!
interlinguaStartsClick

	self model
		search: entryTextMorph contents asString
		lang: #interlingua
		method: #starts! !

!IEENDictView methodsFor: 'GUI building' stamp: 'AAA 6/18/2017 08:20:24'!
makeButtonArea
	"Answer a LayoutMorph with our four buttons -- a column of two rows"
	
	|  interlinguaButtonLayout englishButtonLayout buttonArea buildButton buildRow |
		
	buildButton _ [ :act :label | 
		PluggableButtonMorph model: self action: act label: label :: 
		layoutSpec:  (LayoutSpec proportionalWidth: 0.3 fixedHeight: self textSizeUnit * 2) ; 
		yourself ] .
		
	buildRow _ [ :btnOne :btnTwo | | row |
		row _ LayoutMorph newRow. 
		row 
			padding: #center; 
			separation: 2 ;
			addMorph: btnOne ;
			addMorph:  btnTwo .
		] .
		
	interlinguaButtonLayout _ 
		buildRow 
			value: (buildButton value: #interlinguaContainsClick  value: 'Interlingua Contains') 
			value: (buildButton value: #interlinguaStartsClick  value: 'Interlingua Starts') .
	
	englishButtonLayout _ 
		buildRow 
			value: (buildButton value: #englishContainsClick  value: 'English Contains') 
			value: (buildButton value: #englishStartsClick  value: 'English Starts') .

	buttonArea := LayoutMorph newColumn.
	^ buttonArea 
			layoutSpec: (LayoutSpec proportionalWidth: 1; fixedHeight: 4 * self textSizeUnit);
			addMorph: interlinguaButtonLayout ;
			addMorph: englishButtonLayout ;
			yourself! !

!IEENDictView methodsFor: 'GUI building' stamp: 'AAA 6/18/2017 16:24:49'!
makeEntryArea
	
	| promptMorph |
	
	promptMorph _ (StringMorph contents: 'Enter text: ').
	promptMorph 
		emphasis: AbstractFont boldCode ;
		layoutSpec: (LayoutSpec fixedWidth: (promptMorph measureContents x)) .
		
	entryTextMorph _ (OneLineEditorMorph contents: 'salute') . 
	entryTextMorph 
		layoutSpec: (LayoutSpec proportionalWidth: 0.9) ;
		crAction: [self interlinguaContainsClick] .

	^ LayoutMorph newRow 
		separation: self defaultSeparation ;
		layoutSpec: 
			(LayoutSpec 
				proportionalWidth: 1 
				fixedHeight: (self defaultSeparation * 2 + self textSizeUnit));
		color: Color lightGray ;
		addMorph: promptMorph ;
		addMorph: entryTextMorph ;
		yourself .! !

!IEENDictView methodsFor: 'GUI building' stamp: 'AAA 6/20/2017 01:26:01'!
makeResultArea
	"Answer a LayoutMoph containing the results of the query"
	
	resultMorph _ (PluggableListMorph
		model: model 
		listGetter: #resultAsList
		indexGetter: #resultIndex
		indexSetter: #resultIndex:
		mainView: self
		menuGetter: nil
		keystrokeAction: nil).
		
	^ resultMorph 
		layoutSpec: (LayoutSpec proportionalWidth: 1.0 proportionalHeight: 0.98);  
		color: Color white;
		yourself! !

!IEENDictView methodsFor: 'initialization' stamp: 'matt 6/22/2017 19:59:02'!
observeExternalState

	model when: #searchResultChanged send: #updateResultArea to: self .
! !

!IEENDictView methodsFor: 'initialization' stamp: 'matt 6/22/2017 20:01:25'!
open

	self buildWindow .
	self observeExternalState .
	self initInternalState .! !

!IEENDictView methodsFor: 'geometry' stamp: 'AAA 6/17/2017 23:38:44'!
textSizeUnit
	"Answer the scaling factor for sizing; note  method #fontPreferenceChanged"

	^ AbstractFont default height! !

!IEENDictView methodsFor: 'GUI building' stamp: 'AAA 6/18/2017 10:17:54'!
updateResultArea
	resultMorph updateList ! !

!IEENDictView class methodsFor: 'instance creation' stamp: 'AAA 6/19/2017 21:30:13'!
open

	"
	 IEENDictView open.
	"

	| aIEENDictView |
	
	aIEENDictView  _ self open: (IEENDict new) label: 'IE <--> EN' .
	aIEENDictView open .
	^ aIEENDictView! !
IEENDict initialize!
