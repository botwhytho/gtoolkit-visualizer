"
I represent one step in which {{gtClass:GtGraphTreemapNode}} nodes are allocated along with shorter rectangle size.
I use {{gtClass:GtGraphTreemapSquarifyAreaRectangle}} to layout nodes.
My main algorithm that split an orignal area into sub-areas is implemented in the {{gtMethod:GtGraphTreemapSquarifyStep>>#squarifyHereNode:}} method.
I use {{gtClass:GtGraphTreemapSquarifyWorst}} in order to decide whether a new node should be added to my area or rather a new area should be created.

1. # Example 


In the following example, you can see one are with two nodes: 
{{gtExample:GtGraphTreemapLayoutExamples>>#stepWithTwoNodes|codeExpanded=false|previewExpanded=true}}

If we add another node, all area nodes get less squared:
{{gtExample:GtGraphTreemapLayoutExamples>>#stepWithThreeNodes|codeExpanded=false|previewExpanded=true}}

The algorithm therefore decides to rather create a new area with the third node and keeps the first two nodes in the existing area. A new node is added only if the worst aspect ratio (among all area nodes) is improved. Otherwise, the new node is added to a new area.

See the {{gtClass:GtGraphTreemapSquarify}} class comment for more details.


"
Class {
	#name : #GtGraphTreemapSquarifyStep,
	#superclass : #GtGraphTreemapSquarifyAbstractStep,
	#instVars : [
		'nodes',
		'rectangle',
		'worst',
		'nextStep',
		'rejectedStep',
		'previousStep'
	],
	#category : #'GToolkit-BlocGraph-Layouts-Data Structures - Treemap'
}

{ #category : #factory }
GtGraphTreemapSquarifyStep class >> null [
	^ GtGraphTreemapSquarifyNoStep default
]

{ #category : #'accessing - nodes' }
GtGraphTreemapSquarifyStep >> addNode: aNode [ 
	self nodes: (self nodes copyWith: aNode).
]

{ #category : #enumerating }
GtGraphTreemapSquarifyStep >> allSteps [
	<return: #Array of: #GtGraphTreemapSquarifyStep>
	^ Array streamContents: [ :aStream | 
		self stepsDo: [ :eachRow | aStream nextPut: eachRow ] ]
]

{ #category : #converting }
GtGraphTreemapSquarifyStep >> asElementWithOccupiedArea [
	| anElement |
	anElement := self asPreviewStep asElementWithOccupiedArea.
	anElement padding: (BlInsets all: 5).
	anElement border: (BlBorder paint: BrGlamorousColors successBorderColor width: 3).
	^ anElement
]

{ #category : #converting }
GtGraphTreemapSquarifyStep >> asRejectedStep [
	^ GtGraphTreemapSquarifyRejectedStep new step: self
]

{ #category : #copying }
GtGraphTreemapSquarifyStep >> copyWithNode: aNode [ 
	^ self class new 
		nodes: self nodes with: aNode;
		rectangle: self rectangle copy
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> extent [
	^ rectangle extent
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> extent: aPoint [ 
	self rectangle: (GtGraphTreemapSquarifyAreaRectangle position: 0@0 extent: aPoint).
]

{ #category : #testing }
GtGraphTreemapSquarifyStep >> hasNextStep [
	^ self nextStep isDefinedStep
]

{ #category : #initialization }
GtGraphTreemapSquarifyStep >> initialize [
	super initialize.
	previousStep := self class null.
	nextStep := self class null.
	rejectedStep := self class null.
	nodes := #().
	rectangle := GtGraphTreemapSquarifyAreaRectangle null.
	worst := GtGraphTreemapSquarifyWorst default.
]

{ #category : #testing }
GtGraphTreemapSquarifyStep >> isRejectedStep [
	^ false
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> nextStep [
	^ nextStep
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> nextStep: aStep [
	aStep previousStep: self.
	nextStep := aStep
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> nodes [
	^ nodes
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> nodes: aGtGraphTreemapSquarifyNodes [
	nodes := aGtGraphTreemapSquarifyNodes.
	worst nodes: aGtGraphTreemapSquarifyNodes.
	self updateOccupiedArea
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> nodes: anArray with: aNode [
	self nodes: (anArray copyWith: aNode)
]

{ #category : #'accessing - nodes' }
GtGraphTreemapSquarifyStep >> nodesCount [
	^ self nodes size
]

{ #category : #enumerating }
GtGraphTreemapSquarifyStep >> nodesDo: anOneArgBlock [
	self nodes do: anOneArgBlock
]

{ #category : #'accessing - nodes' }
GtGraphTreemapSquarifyStep >> occupiedWeight [
	^ self nodes 
		ifNotEmpty: [ :theNodes | theNodes sum: #weight ]
		ifEmpty: [ 0 ]
]

{ #category : #'accessing - rectangle' }
GtGraphTreemapSquarifyStep >> orientationName [
	^ self rectangle name
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> previousStep [
	<return: #GtGraphTreemapSquarifyStep>
	^ previousStep
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> previousStep: anObject [
	previousStep := anObject
]

{ #category : #enumerating }
GtGraphTreemapSquarifyStep >> previousStepsFromDownDo: aBlock [
	| aPreviousStep |
	aPreviousStep := self previousStep.
	aPreviousStep isDefinedStep ifFalse: [ ^ self ].
	aBlock cull: aPreviousStep.
	aPreviousStep previousStepsFromDownDo: aBlock
]

{ #category : #enumerating }
GtGraphTreemapSquarifyStep >> previousStepsFromTopDo: aBlock [
	| aPreviousStep |
	aPreviousStep := self previousStep.
	aPreviousStep isDefinedStep ifFalse: [ ^ self ].
	aPreviousStep previousStepsFromTopDo: aBlock.
	aBlock cull: aPreviousStep
]

{ #category : #enumerating }
GtGraphTreemapSquarifyStep >> previousStepsWithDifferentAreasFromDownDo: aBlock [
	| aRectangleBounds |
	aRectangleBounds := self rectangleBounds.
	self previousStepsFromDownDo: [ :eachStep | 
		aRectangleBounds = eachStep rectangleBounds ifFalse: [ 
			aBlock cull: eachStep.
			aRectangleBounds := eachStep rectangleBounds ] ]
]

{ #category : #enumerating }
GtGraphTreemapSquarifyStep >> previousStepsWithDifferentAreasFromTopDo: aBlock [
	| aQueue |
	aQueue := LIFOQueue new.
	self previousStepsWithDifferentAreasFromDownDo: [ :eachStep | 
		aQueue push: eachStep ].
	[ 
		| aStep |
		aStep := aQueue nextIfNone: [ ^ self ].
		aBlock cull: aStep 
	] repeat
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> rectangle [
	^ rectangle
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> rectangle: aGtGraphTreemapSquarifyAreaRectangle [
	rectangle := aGtGraphTreemapSquarifyAreaRectangle.
	worst totalArea: rectangle original height * rectangle original width.
	worst length: rectangle length.
	self updateOccupiedArea.
]

{ #category : #'accessing - rectangle' }
GtGraphTreemapSquarifyStep >> rectangleBounds [
	^ self rectangle bounds
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> rejectedStep [
	^ rejectedStep
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> rejectedStep: aStep [
	aStep previousStep: self.
	rejectedStep := aStep asRejectedStep
]

{ #category : #squarifying }
GtGraphTreemapSquarifyStep >> squarifyHereNode: aNode [ 
	| aNewStep |
	self nodes ifEmpty: [ 
		self addNode: aNode.
		self squarifyNodes.
		^ self ].
	aNewStep := self copyWithNode: aNode.
	self worst >= aNewStep worst
		ifTrue: [
			"the aspect ratio is improved"
			self nextStep: aNewStep.
			aNewStep squarifyNodes ]
		ifFalse: [ 
			"the aspect ratio is worst, let's create a new area"
			self rejectedStep: aNewStep.
			self nextStep: self class new.
			self nextStep rectangle: self rectangle remainingRectangle.
			self nextStep squarifyHereNode: aNode ].
]

{ #category : #squarifying }
GtGraphTreemapSquarifyStep >> squarifyNode: aNode [ 
	self nextStep squarifyNode: aNode in: self
]

{ #category : #squarifying }
GtGraphTreemapSquarifyStep >> squarifyNode: aGtGraphTreemapNode in: aGtGraphTreemapSquarifyStep [ 
	self squarifyNode: aGtGraphTreemapNode
]

{ #category : #squarifying }
GtGraphTreemapSquarifyStep >> squarifyNodes [
	self rectangle squarifyStep: self
]

{ #category : #enumerating }
GtGraphTreemapSquarifyStep >> stepsDo: anOneArgBlock [
	anOneArgBlock cull: self.
	self rejectedStep stepsDo: anOneArgBlock.
	self nextStep stepsDo: anOneArgBlock
]

{ #category : #'accessing - step' }
GtGraphTreemapSquarifyStep >> successName [
	<return: #BlRope>
	^ 'Accepted' asRopedText foreground: BrGlamorousColors successBackgroundColor
]

{ #category : #squarifying }
GtGraphTreemapSquarifyStep >> updateOccupiedArea [
	self rectangle updateOccupiedArea: self
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> withPreviousAndNextSteps [
	<return: #Array of: #GtGraphTreemapSquarifyStep>
	^ Array streamContents: [ :aStream | 
		self previousStepsWithDifferentAreasFromTopDo: [ :eachStep | 
			aStream nextPut: eachStep ].
		self stepsDo: [ :eachRow | aStream nextPut: eachRow ] ]
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> worst [
	<return: #GtGraphTreemapSquarifyWorst>
	^ worst
]

{ #category : #accessing }
GtGraphTreemapSquarifyStep >> worst: aGtGraphTreemapSquarifyWorst [
	worst := aGtGraphTreemapSquarifyWorst
]

{ #category : #'accessing - worst' }
GtGraphTreemapSquarifyStep >> worstString [
	<return: #String>
	^ GtGraphUtilities default printNumber: self worstValue
]

{ #category : #'accessing - worst' }
GtGraphTreemapSquarifyStep >> worstValue [
	^ self worst value
]
