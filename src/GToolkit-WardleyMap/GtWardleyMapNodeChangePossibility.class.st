Class {
	#name : #GtWardleyMapNodeChangePossibility,
	#superclass : #Object,
	#instVars : [
		'nodeViewModel'
	],
	#category : #'GToolkit-WardleyMap-Helpers'
}

{ #category : #private }
GtWardleyMapNodeChangePossibility >> anyEdgeFromNodeHasEdgeToEvolveNode: aCollectionOfEdges [
	aCollectionOfEdges
		do: [ :eachIncomingEdge | 
			| otherOutgoingEdges |
			otherOutgoingEdges := self
					outgoingEdgeViewModelsForNodeViewModel: eachIncomingEdge fromNodeViewModel.
			otherOutgoingEdges
				do: [ :eachOutgoingEdge | 
					eachOutgoingEdge == eachIncomingEdge
						ifFalse: [ eachOutgoingEdge toNodeViewModel isEvolveTargetType ifTrue: [ ^ true ] ] ] ].
						
	^ false
]

{ #category : #testing }
GtWardleyMapNodeChangePossibility >> canAddEvolveNode [
	^ nodeViewModel isEvolveTargetType not
		and: [ self outgoingEdgeViewModels
				allSatisfy: [ :eachEdge | eachEdge toNodeViewModel isEvolveTargetType not ] ]
]

{ #category : #testing }
GtWardleyMapNodeChangePossibility >> canManipulateEvolveType [
	^ nodeViewModel isPipelineVisible not
		and: [ nodeViewModel wardleyMapViewModel isNotNil
				and: [ | incomingEdges |
					incomingEdges := self incommingEdgeViewModels.
					incomingEdges size = 1
						and: [ self outgoingEdgeViewModels size = 0
								and: [ (self anyEdgeFromNodeHasEdgeToEvolveNode: incomingEdges) not ] ] ] ]
]

{ #category : #testing }
GtWardleyMapNodeChangePossibility >> canManipulatePipelineVisibility [
	^ nodeViewModel pipelineNodeViewModel isNil
		and: [ nodeViewModel isEvolveTargetType not ]
]

{ #category : #accessing }
GtWardleyMapNodeChangePossibility >> edgeViewModels [
	^ nodeViewModel wardleyMapViewModel edgeViewModels
]

{ #category : #testing }
GtWardleyMapNodeChangePossibility >> incommingEdgeViewModels [
	^ self edgeViewModels
		select: [ :eachEdge | eachEdge toNodeViewModel == nodeViewModel ]
]

{ #category : #testing }
GtWardleyMapNodeChangePossibility >> isEvolveTargetType [
	^ self nodeViewModel isEvolveTargetType
]

{ #category : #testing }
GtWardleyMapNodeChangePossibility >> isPipelineVisible [
	^ self nodeViewModel isPipelineVisible
]

{ #category : #accessing }
GtWardleyMapNodeChangePossibility >> nodeViewModel [
	^ nodeViewModel
]

{ #category : #accessing }
GtWardleyMapNodeChangePossibility >> nodeViewModel: anObject [
	nodeViewModel := anObject
]

{ #category : #accessing }
GtWardleyMapNodeChangePossibility >> outgoingEdgeViewModels [
	^ self outgoingEdgeViewModelsForNodeViewModel: nodeViewModel
]

{ #category : #accessing }
GtWardleyMapNodeChangePossibility >> outgoingEdgeViewModelsForNodeViewModel: aNodeViewModel [
	^ self edgeViewModels
		select: [ :eachEdge | eachEdge fromNodeViewModel == aNodeViewModel ]
]