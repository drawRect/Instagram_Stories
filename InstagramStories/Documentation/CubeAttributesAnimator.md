# CubeAttributesAnimator

An animator that applies a cube transition effect when you scroll.

``` swift
public struct CubeAttributesAnimator: LayoutAttributesAnimator
```

## Inheritance

[`LayoutAttributesAnimator`](LayoutAttributesAnimator)

## Initializers

## init(perspective:totalAngle:)

``` swift
public init(perspective: CGFloat = -1 / 500, totalAngle: CGFloat = .pi / 2)
```

## Properties

## perspective

The perspective that will be applied to the cells. Must be negative. -1/500 by default.
Recommended range \[-1/2000, -1/200\].

``` swift
var perspective: CGFloat
```

## totalAngle

The higher the angle is, the *steeper* the cell would be when transforming.

``` swift
var totalAngle: CGFloat
```

## Methods

## animate(collectionView:attributes:)

``` swift
public func animate(collectionView: UICollectionView, attributes: AnimatedCollectionViewLayoutAttributes)
```
