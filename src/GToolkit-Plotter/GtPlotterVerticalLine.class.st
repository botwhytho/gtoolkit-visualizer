Class {
	#name : #GtPlotterVerticalLine,
	#superclass : #GtPlotterBarChartLine,
	#category : #'GToolkit-Plotter-Builder - Bar lines'
}

{ #category : #accessing }
GtPlotterVerticalLine >> setAxisPercent: aNumber in: aBlPercentSideAnchor [
	aBlPercentSideAnchor ypercent: aNumber
]

{ #category : #accessing }
GtPlotterVerticalLine >> setPercent: aNumber in: aBlPercentSideAnchor [
	aBlPercentSideAnchor xpercent: aNumber
]

{ #category : #accessing }
GtPlotterVerticalLine >> transformRectangle: aRectangle [
	| e corner |
	e := parent list children first computeVerticalScrollExtent.
	corner := aRectangle corner.
	^ Rectangle 
		origin: aRectangle origin 
		extent: aRectangle width @ (aRectangle height min: e)
]

{ #category : #accessing }
GtPlotterVerticalLine >> valuePercent [
	^ barChart barWidthScale map: self dataValue
]