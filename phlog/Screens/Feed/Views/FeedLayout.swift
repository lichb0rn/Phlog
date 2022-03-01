//
//  FeedLayout.swift
//  phlog
//
//  Created by Miroslav Taleiko on 16.12.2021.
//

import UIKit

public enum FeedViewLayout {
    case feed
    case grouped
}

//https://www.raywenderlich.com/5436806-modern-collection-views-with-compositional-layouts
class FeedLayout: UICollectionViewLayout {
    
    private let numberOfColums = 3
    private let padding: CGFloat = 2
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
//        let insets = collectionView.contentInset
        return collectionView.bounds.size.width - ( padding * ( CGFloat(numberOfColums) - 1) )
    }
    
    
    override func prepare() {
        super.prepare()
        guard  let collectionView = collectionView, collectionView.numberOfSections > 0 else { return }
        cache.removeAll()

        let itemsPerRow = 3
        let defaultWidth = contentWidth / CGFloat(itemsPerRow)
        let defaultHeight = defaultWidth
        
        let featuredWidth = defaultWidth * 2 + padding
        let featuredHeight = featuredWidth
        
        var xOffsets = [CGFloat]()
        // Generating offsets for the first 6 "standard" cells
        for item in 0..<6 {
            let multiplier = item % 3
            let xPos = CGFloat(multiplier) * (defaultWidth + padding)
            xOffsets.append(xPos)
        }
        xOffsets.append(0.0)
        
        // Featured cell offsets
        for _ in 0..<2 {
            xOffsets.append(featuredWidth + padding)
        }
        
        var yOffsets = [CGFloat]()
        for item in 0..<9 {
            var yPos = floor( Double(item / 3) *
                              Double(defaultHeight + padding) )
            
            if item == 8 {
                yPos += Double(defaultHeight + padding)
            }
            yOffsets.append(yPos)
        }
        
        let itemsPerPattern = 9
        let patternHeight = ( 4 * defaultHeight ) + ( 4 * padding )
        
        var itemInPattern = 0
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            
            let xPos = xOffsets[itemInPattern]
            let multiplier = floor( Double(item) / Double(itemsPerPattern) )
            
            let yPos = yOffsets[itemInPattern] + patternHeight * CGFloat(multiplier)
            
            var cellWidth = defaultWidth
            var cellHeight = defaultHeight
            if (itemInPattern + 1) % 7 == 0 && itemInPattern != 0 {
                cellWidth = featuredWidth
                cellHeight = featuredHeight
            }
            
            let frame = CGRect(x: xPos, y: yPos, width: cellWidth, height: cellHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            
            itemInPattern = itemInPattern < (itemsPerPattern - 1) ? itemInPattern + 1 : 0
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    
}
