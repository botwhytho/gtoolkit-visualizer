Class {
	#name : #GtWardleyMapFromDictionaryImporter,
	#superclass : #Object,
	#category : #'GToolkit-WardleyMap-Exporter/Importer'
}

{ #category : #'api - import' }
GtWardleyMapFromDictionaryImporter class >> importMapFromJSONString: aString [
	^ self new importWardleyMapFrom: (STONJSON fromString: aString)
]

{ #category : #'api - importer' }
GtWardleyMapFromDictionaryImporter >> connectWardleyMapNodePipelines: theMapNodes from: theNodeDictionaries [ 

	theMapNodes withIndexDo: [ :eachPipelineNode :anIndex |
		eachPipelineNode isPipelineVisible ifTrue: [ 
			| aNodeDictionary |
			aNodeDictionary := theNodeDictionaries at: anIndex.
			aNodeDictionary 
				at: #pipeline 
				ifPresent: [ :aPipelineDictionary | 
					aPipelineDictionary 
						at: #inner_nodes
						ifPresent: [ :theInnerNodeIds | 
							| theInnerNodes |
							theInnerNodes := theInnerNodeIds 
								collect: [ :eachInnerNodeId | 
									| anId | 
									anId := self importIdFrom: eachInnerNodeId.
									theMapNodes 
										detect: [ :otherNode | 
											otherNode id = anId and: [ 
												otherNode isPipelineVisible not ] ]
										ifNone: [ nil ] ]
								thenReject: #isNil.
							eachPipelineNode innerNodes: theInnerNodes
						]
				]
		]
	]
]

{ #category : #'api - importer' }
GtWardleyMapFromDictionaryImporter >> importColorFrom: aDictionary [
	| aRed aGreen aBlue anAlpha |
	
	aRed := aDictionary at: #red ifAbsent: [ 0 ].
	aGreen := aDictionary at: #green ifAbsent: [ 0 ].
	aBlue := aDictionary at: #blue ifAbsent: [ 0 ].
	anAlpha := aDictionary at: #alpha ifAbsent: [ 1 ].
	
	^ Color r: aRed g: aGreen b: aBlue alpha: anAlpha
]

{ #category : #'api - importer' }
GtWardleyMapFromDictionaryImporter >> importIdFrom: aString [
	^ UUID fromString: aString
]

{ #category : #'api - importer' }
GtWardleyMapFromDictionaryImporter >> importLegacyEvolveNodeFrom: aDictionary to: aWardleyMapNode [
	aWardleyMapNode isEvolveVisible: true.

	aDictionary
		at: #color
		ifPresent: [ :aColorDictionary | aWardleyMapNode evolveModel color: (self importColorFrom: aColorDictionary) ].

	aDictionary
		at: #x
		ifPresent: [ :anX | aWardleyMapNode evolveModel evolution: anX ].
	aDictionary
		at: #width
		ifPresent: [ :aWidth | aWardleyMapNode evolveModel width: aWidth ].
	aDictionary
		at: #height
		ifPresent: [ :aHeight | aWardleyMapNode evolveModel height: aHeight ].

	aDictionary
		at: #label
		ifPresent: [ :aLabelDictionary | 
			aWardleyMapNode evolveModel
				labelModel: (self importWardleyMapEvolveLabelFrom: aLabelDictionary) ]
]

{ #category : #'api - importer' }
GtWardleyMapFromDictionaryImporter >> importLegacyEvolveNodesFrom: theNodeDictionaries to: theMapNodes [ 
	theNodeDictionaries do: [ :aNodeDictionary |
		(self isEvolveNodeDictionary: aNodeDictionary) ifTrue: [ 
			aNodeDictionary
				at: #evolve 
				ifPresent: [ :anEvolveDictionary | 
					anEvolveDictionary
						at: #source_node
						ifPresent: [ :aSourceNodeId | 
							| anId | 
							anId := self importIdFrom: aSourceNodeId.
							theMapNodes
								detect: [ :otherNode | 
									otherNode id = anId ]
								ifFound: [ :aSourceNode | 
									self importLegacyEvolveNodeFrom: aNodeDictionary to: aSourceNode ]
								ifNone: [ ]
						]
				]
		]
	].
]

{ #category : #'api - importer' }
GtWardleyMapFromDictionaryImporter >> importWardleyMapEdgeFrom: aDictionary [
	| aWardleyMapEdge |

	aWardleyMapEdge := GtWardleyMapEdgeModel new.

	aDictionary
		at: #color
		ifPresent: [ :aColorDictionary | aWardleyMapEdge color: (self importColorFrom: aColorDictionary) ].

	aDictionary at: #width ifPresent: [ :aWidth | aWardleyMapEdge width: aWidth ].
	aDictionary at: #arrow ifPresent: [ :anArrow | aWardleyMapEdge arrow: anArrow ].
	
	aDictionary
		at: #label
		ifPresent: [ :aLabelDictionary | 
			aWardleyMapEdge labelModel: (self importWardleyMapEdgeLabelFrom: aLabelDictionary) ].
		
	^ aWardleyMapEdge
]

{ #category : #'api - importer' }
GtWardleyMapFromDictionaryImporter >> importWardleyMapEdgeFrom: aDictionary map: aWardleyMap [
	| aWardleyMapEdge |

	aWardleyMapEdge := self importWardleyMapEdgeFrom: aDictionary.

	aDictionary
		at: #from
		ifPresent: [ :aFromId |
			aWardleyMap
				nodeWithId: (self importIdFrom: aFromId)
				ifFound: [ :aFromNode |
					aWardleyMapEdge fromNode: aFromNode ]
				ifNone: [  ] ].

	aDictionary
		at: #to
		ifPresent: [ :aToId |
			aWardleyMap
				nodeWithId: (self importIdFrom: aToId)
				ifFound: [ :aToNode | aWardleyMapEdge toNode: aToNode ]
				ifNone: [ 
					"It is a legacy edge to an evolve node
					which we do not import as a standalone node,
					therefore do not import it."
					^ nil ] ].
	
	^ aWardleyMapEdge
]

{ #category : #'api - importer' }
GtWardleyMapFromDictionaryImporter >> importWardleyMapEdgeLabelFrom: aDictionary [
	| aWardleyMapEdgeLabel |
	
	aWardleyMapEdgeLabel := GtWardleyMapEdgeLabelModel new.
	
	aDictionary at: #x ifPresent: [ :anX | aWardleyMapEdgeLabel x: anX ].
	aDictionary at: #y ifPresent: [ :anY | aWardleyMapEdgeLabel y: anY ].
	aDictionary at: #text ifPresent: [ :aText | aWardleyMapEdgeLabel label: aText ].
	aDictionary at: #is_visible ifPresent: [ :aBoolean | aWardleyMapEdgeLabel isVisible: aBoolean ].

	^ aWardleyMapEdgeLabel
]

{ #category : #'api - importer' }
GtWardleyMapFromDictionaryImporter >> importWardleyMapEvolveFrom: aDictionary [
	| aWardleyMapEvolve |
	aWardleyMapEvolve := GtWardleyMapNodeEvolveModel new.

	"The maturity is not recommended. Use evolution instead (evolution == x). 
	See https://swardley.medium.com/map-evolution-not-maturity-bae6ea1a2743"
	aDictionary
		at: #maturity
		ifPresent: [ :aMaturity | aWardleyMapEvolve evolution: aMaturity ].
	aDictionary
		at: #evolution
		ifPresent: [ :anEvolution | aWardleyMapEvolve evolution: anEvolution ].

	aDictionary at: #width ifPresent: [ :aWidth | aWardleyMapEvolve width: aWidth ].
	aDictionary
		at: #height
		ifPresent: [ :aHeight | aWardleyMapEvolve height: aHeight ].
	aDictionary
		at: #color
		ifPresent: [ :aColorDictionary | aWardleyMapEvolve color: (self importColorFrom: aColorDictionary) ].

	aDictionary
		at: #label
		ifPresent: [ :aLabelDictionary | 
			aWardleyMapEvolve
				labelModel: (self importWardleyMapEvolveLabelFrom: aLabelDictionary) ].

	^ aWardleyMapEvolve
]

{ #category : #'api - importer' }
GtWardleyMapFromDictionaryImporter >> importWardleyMapEvolveLabelFrom: aDictionary [
	| aWardleyMapEvolveLabel |
	
	aWardleyMapEvolveLabel := GtWardleyMapEvolveLabelModel new.
	
	self importWardleyMapNodeLabelFrom: aDictionary to: aWardleyMapEvolveLabel.
	aDictionary at: #is_visible ifPresent: [ :aBoolean | aWardleyMapEvolveLabel isVisible: aBoolean ].

	^ aWardleyMapEvolveLabel
]

{ #category : #'api - importer' }
GtWardleyMapFromDictionaryImporter >> importWardleyMapFrom: aDictionary [
	| aWardleyMap |
	aWardleyMap := GtWardleyMapModel new.
	
	aDictionary
		at: #title
		ifPresent: [ :theTitleDictionary |
			theTitleDictionary
				at: #text
				ifPresent: [ :aText | aWardleyMap title: aText asString ];
				at: #is_visible
				ifPresent: [ :aBoolean | aWardleyMap isTitleVisible: aBoolean ] ].
	
	aDictionary
		at: #evolution_axis
		ifPresent: [ :theEvolutionAxisDictionary |
			theEvolutionAxisDictionary
				at: #is_visible
				ifPresent: [ :aBoolean | aWardleyMap isEvolutionAxisVisible: aBoolean ];
				at: #sections
				ifPresent: [ :anArray | aWardleyMap evolutionSections: anArray ] ].
	
	aDictionary
		at: #notes
		ifPresent: [ :theNoteDictionaries | 
			theNoteDictionaries
				do: [ :eachNoteDictionary | aWardleyMap addNote: (self importWardleyMapNoteFrom: eachNoteDictionary) ] ].

	aDictionary
		at: #nodes
		ifPresent: [ :theNodeDictionaries | 
			theNodeDictionaries
				do: [ :eachNodeDictionary | 
					(self importWardleyMapNodeFrom: eachNodeDictionary)
						ifNotNil: [ :aNode | aWardleyMap addNode: aNode ] ].

			self
				connectWardleyMapNodePipelines: aWardleyMap nodes
				from: theNodeDictionaries.
			self importLegacyEvolveNodesFrom: theNodeDictionaries to: aWardleyMap nodes ].

	aDictionary
		at: #edges
		ifPresent: [ :theEdgeDictionaries | 
			theEdgeDictionaries
				do: [ :eachEdgeDictionary | 
					(self importWardleyMapEdgeFrom: eachEdgeDictionary map: aWardleyMap) 
						ifNotNil: [ :anEdge |
							aWardleyMap addEdge: anEdge ] ] ].

	^ aWardleyMap
]

{ #category : #'api - importer' }
GtWardleyMapFromDictionaryImporter >> importWardleyMapNodeFrom: aDictionary [
	| aWardleyMapNode |

	"A legacy form of storing evolve information.
	We skip such nodes here and import the evolve information later."
	(self isEvolveNodeDictionary: aDictionary) ifTrue: [ ^ nil ].
	
	aWardleyMapNode := GtWardleyMapNodeModel new.
	aDictionary
		at: #id
		ifPresent: [ :anId | aWardleyMapNode id: (self importIdFrom: anId) ].

	aDictionary
		at: #color
		ifPresent: [ :aColorDictionary | 
			aWardleyMapNode color: (self importColorFrom: aColorDictionary) ].

	"Node position can be stored using either maturity and visibility values,
	or x and y values. In this case, maturity == x and visibility == 1 - y.
	The maturity is not recommended. Use evolution instead (evolution == x). 
	See https://swardley.medium.com/map-evolution-not-maturity-bae6ea1a2743"
	aDictionary at: #maturity ifPresent: [ :aMaturity | aWardleyMapNode evolution: aMaturity ].
	aDictionary at: #evolution ifPresent: [ :anEvolution | aWardleyMapNode evolution: anEvolution ].
	aDictionary at: #visibility ifPresent: [ :aVisibility | aWardleyMapNode visibility: aVisibility ].
	aDictionary at: #x ifPresent: [ :anX | aWardleyMapNode x: anX ].
	aDictionary at: #y ifPresent: [ :anY | aWardleyMapNode y: anY ].
	
	aDictionary at: #width ifPresent: [ :aWidth | aWardleyMapNode width: aWidth ].
	aDictionary at: #height ifPresent: [ :aHeight | aWardleyMapNode height: aHeight ].

	aDictionary
		at: #label
		ifPresent: [ :aLabelDictionary | aWardleyMapNode labelModel: (self importWardleyMapNodeLabelFrom: aLabelDictionary) ].
		
	aDictionary
		at: #pipeline
		ifPresent: [ :aPipelineDictionary | 
			aPipelineDictionary 
				at: #is_visible 
				ifPresent: [ :aValue | aWardleyMapNode isPipelineVisible: aValue ].
				
			"The pipeline coordinates depends on inner node evolution positions.
			In other words, while those values are read, the pipeline coordinates
			are recomputed when inner nodes are added."
			
			"The maturity is not recommended. Use evolution instead (evolution == x). 
			See https://swardley.medium.com/map-evolution-not-maturity-bae6ea1a2743"
			aPipelineDictionary 
				at: #min_maturity
				ifPresent: [ :aMinValue | 
					aPipelineDictionary 
						at: #max_maturity
						ifPresent: [ :aMaxValue | aWardleyMapNode pipelineCoordinate: aMinValue @ aMaxValue ] ].
			
			aPipelineDictionary 
				at: #min_evolution
				ifPresent: [ :aMinValue | 
					aPipelineDictionary 
						at: #max_evolution
						ifPresent: [ :aMaxValue | aWardleyMapNode pipelineCoordinate: aMinValue @ aMaxValue ] ].
						
			aPipelineDictionary 
				at: #x 
				ifPresent: [ :aXValue | 
					aPipelineDictionary 
						at: #y 
						ifPresent: [ :aYValue | aWardleyMapNode pipelineCoordinate: aXValue @ aYValue ] ] ].
					
	aDictionary
		at: #evolve
		ifPresent: [ :anEvolveDictionary | 
			anEvolveDictionary 
				at: #is_visible 
				ifPresent: [ :aBoolean | aWardleyMapNode isEvolveVisible: aBoolean ].
			aWardleyMapNode evolveModel: (self importWardleyMapEvolveFrom: anEvolveDictionary) ].

	^ aWardleyMapNode
]

{ #category : #'api - importer' }
GtWardleyMapFromDictionaryImporter >> importWardleyMapNodeLabelFrom: aDictionary [
	| aWardleyMapNodeLabel |
	aWardleyMapNodeLabel := GtWardleyMapNodeLabelModel new.
	
	self importWardleyMapNodeLabelFrom: aDictionary to: aWardleyMapNodeLabel.
	
	^ aWardleyMapNodeLabel
]

{ #category : #private }
GtWardleyMapFromDictionaryImporter >> importWardleyMapNodeLabelFrom: aDictionary to: aWardleyMapNodeLabel [
	aDictionary at: #x ifPresent: [ :anX | aWardleyMapNodeLabel x: anX ].
	aDictionary at: #y ifPresent: [ :anY | aWardleyMapNodeLabel y: anY ].
	aDictionary at: #text ifPresent: [ :aText | aWardleyMapNodeLabel label: aText ]
]

{ #category : #'api - importer' }
GtWardleyMapFromDictionaryImporter >> importWardleyMapNoteFrom: aDictionary [
	| aWardleyMapNote |

	aWardleyMapNote := GtWardleyMapNoteModel new.
	aDictionary
		at: #id
		ifPresent: [ :anId | aWardleyMapNote id: (self importIdFrom: anId) ].

	aDictionary
		at: #color
		ifPresent: [ :aColorDictionary | 
			aWardleyMapNote color: (self importColorFrom: aColorDictionary) ].

	"Note position can be stored using either maturity and visibility values,
	or x and y values. In this case, maturity == x and visibility == 1 - y.
	The maturity is not recommended. Use evolution instead (evolution == x). 
	See https://swardley.medium.com/map-evolution-not-maturity-bae6ea1a2743"
	aDictionary at: #maturity ifPresent: [ :aMaturity | aWardleyMapNote evolution: aMaturity ].
	aDictionary at: #evolution ifPresent: [ :anEvolution | aWardleyMapNote evolution: anEvolution ].
	aDictionary at: #visibility ifPresent: [ :aVisibility | aWardleyMapNote visibility: aVisibility ].
	aDictionary at: #x ifPresent: [ :anX | aWardleyMapNote x: anX ].
	aDictionary at: #y ifPresent: [ :anY | aWardleyMapNote y: anY ].

	aDictionary
		at: #label
		ifPresent: [ :aLabel | aWardleyMapNote label: aLabel ].
	
	^ aWardleyMapNote
]

{ #category : #'api - importer' }
GtWardleyMapFromDictionaryImporter >> isEvolveNodeDictionary: aDictionary [ 
	aDictionary 
		at: #evolve 
		ifPresent: [ :anEvolveDictionary |
			anEvolveDictionary 
				at: #is_evolve_target 
				ifPresent: [ :aBoolean |
					^ aBoolean ] ].
					
	^ false
]
