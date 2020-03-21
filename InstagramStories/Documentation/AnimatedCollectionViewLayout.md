# AnimatedCollectionViewLayout

A `UICollectionViewFlowLayout` subclass enables custom transitions between cells.

``` swift
open class AnimatedCollectionViewLayout: UICollectionViewFlowLayout
```

## Inheritance

`UICollectionViewFlowLayout`

## Properties

## animator

The animator that would actually handle the transitions.

``` swift
var animator: LayoutAttributesAnimator?
```

## layoutAttributesClass

Overrided so that we can store extra information in the layout attributes.

``` swift
var layoutAttributesClass: AnyClass
```

## Methods

## layoutAttributesForElements(in:)

``` swift
open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
```

## shouldInvalidateLayout(forBoundsChange:)

``` swift
open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
```

## prepare(forAnimatedBoundsChange:)

``` swift
override open func prepare(forAnimatedBoundsChange oldBounds: CGRect)
```

## targetContentOffset(forProposedContentOffset:)

``` swift
override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint
```

## finalizeAnimatedBoundsChange()

``` swift
override open func finalizeAnimatedBoundsChange()
```
