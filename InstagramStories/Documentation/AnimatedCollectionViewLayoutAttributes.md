# AnimatedCollectionViewLayoutAttributes

A custom layout attributes that contains extra information.

``` swift
open class AnimatedCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes
```

## Inheritance

`UICollectionViewLayoutAttributes`

## Properties

## contentView

``` swift
var contentView: UIView?
```

## scrollDirection

``` swift
var scrollDirection: UICollectionView.ScrollDirection = .vertical
```

## startOffset

The ratio of the distance between the start of the cell and the start of the collectionView and the height/width of the cell depending on the scrollDirection. It's 0 when the start of the cell aligns the start of the collectionView. It gets positive when the cell moves towards the scrolling direction (right/down) while getting negative when moves opposite.

``` swift
var startOffset: CGFloat = 0
```

## middleOffset

The ratio of the distance between the center of the cell and the center of the collectionView and the height/width of the cell depending on the scrollDirection. It's 0 when the center of the cell aligns the center of the collectionView. It gets positive when the cell moves towards the scrolling direction (right/down) while getting negative when moves opposite.

``` swift
var middleOffset: CGFloat = 0
```

## endOffset

The ratio of the distance between the **start** of the cell and the end of the collectionView and the height/width of the cell depending on the scrollDirection. It's 0 when the **start** of the cell aligns the end of the collectionView. It gets positive when the cell moves towards the scrolling direction (right/down) while getting negative when moves opposite.

``` swift
var endOffset: CGFloat = 0
```

## Methods

## copy(with:)

``` swift
open override func copy(with zone: NSZone? = nil) -> Any
```

## isEqual(\_:)

``` swift
open override func isEqual(_ object: Any?) -> Bool
```
