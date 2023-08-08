import Foundation

struct GeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    var paddingWidth: CGFloat {
        return leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }

    init(cellCount: Int,
         leftInset: CGFloat,
         rightInset: CGFloat,
         cellSpacing: CGFloat
    ) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
    }
}
