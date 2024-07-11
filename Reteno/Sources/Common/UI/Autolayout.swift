//
//  Autolayout.swift
//  UI
//

import UIKit

protocol LayoutAnchor {
    
    func constraint(equalTo anchor: Self, constant: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualTo anchor: Self, constant: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualTo anchor: Self, constant: CGFloat) -> NSLayoutConstraint
}

protocol LayoutDimension: LayoutAnchor {
    
    func constraint(equalToConstant constant: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualToConstant constant: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualToConstant constant: CGFloat) -> NSLayoutConstraint
    
    func constraint(equalTo anchor: Self, multiplier: CGFloat) -> NSLayoutConstraint
}

extension NSLayoutAnchor: LayoutAnchor {}
extension NSLayoutDimension: LayoutDimension {}

class LayoutProperty<Anchor: LayoutAnchor> {
    
    fileprivate let anchor: Anchor
    fileprivate let kind: Kind
    
    enum Kind { case leading, trailing, top, bottom, centerX, centerY, width, height }
    
    init(anchor: Anchor, kind: Kind) {
        self.anchor = anchor
        self.kind = kind
    }
}

class LayoutAttribute<Dimension: LayoutDimension>: LayoutProperty<Dimension> {
    
    fileprivate let dimension: Dimension
    
    init(dimension: Dimension, kind: Kind) {
        self.dimension = dimension
        
        super.init(anchor: dimension, kind: kind)
    }
}

final class LayoutProxy {
    
    lazy var leading = property(with: view.leadingAnchor, kind: .leading)
    lazy var trailing = property(with: view.trailingAnchor, kind: .trailing)
    lazy var top = property(with: view.topAnchor, kind: .top)
    lazy var bottom = property(with: view.bottomAnchor, kind: .bottom)
    lazy var centerX = property(with: view.centerXAnchor, kind: .centerX)
    lazy var centerY = property(with: view.centerYAnchor, kind: .centerY)
    lazy var width = attribute(with: view.widthAnchor, kind: .width)
    lazy var height = attribute(with: view.heightAnchor, kind: .height)
    
    private let view: UIView
    
    fileprivate init(view: UIView) {
        self.view = view
    }
    
    private func property<A: LayoutAnchor>(with anchor: A, kind: LayoutProperty<A>.Kind) -> LayoutProperty<A> {
        return LayoutProperty(anchor: anchor, kind: kind)
    }
    
    private func attribute<D: LayoutDimension>(with dimension: D, kind: LayoutProperty<D>.Kind) -> LayoutAttribute<D> {
        return LayoutAttribute(dimension: dimension, kind: kind)
    }
}

extension LayoutAttribute {
    
    @discardableResult
    func equal(to constant: CGFloat, priority: UILayoutPriority? = nil, isActive: Bool = true) -> NSLayoutConstraint {
        let constraint = dimension.constraint(equalToConstant: constant)
        (constraint.firstItem as? UIView)?.layout.update(constraint: constraint, kind: kind)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = isActive
        return constraint
    }
    
    @discardableResult
    func greaterThanOrEqual(to constant: CGFloat, priority: UILayoutPriority? = nil,
                            isActive: Bool = true) -> NSLayoutConstraint {
        let constraint = dimension.constraint(greaterThanOrEqualToConstant: constant)
        (constraint.firstItem as? UIView)?.layout.update(constraint: constraint, kind: kind)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = isActive
        return constraint
    }
    
    @discardableResult
    func lessThanOrEqual(to constant: CGFloat, priority: UILayoutPriority? = nil,
                         isActive: Bool = true) -> NSLayoutConstraint {
        let constraint = dimension.constraint(lessThanOrEqualToConstant: constant)
        (constraint.firstItem as? UIView)?.layout.update(constraint: constraint, kind: kind)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = isActive
        return constraint
    }
    
    @discardableResult
    func equal(to otherDimension: Dimension, multiplier: CGFloat,
               priority: UILayoutPriority? = nil, isActive: Bool = true) -> NSLayoutConstraint {
        let constraint = dimension.constraint(equalTo: otherDimension, multiplier: multiplier)
        (constraint.firstItem as? UIView)?.layout.update(constraint: constraint, kind: kind)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = isActive
        return constraint
    }
}

extension LayoutProperty {
    
    @discardableResult
    func equal(
        to otherAnchor: Anchor,
        offsetBy constant: CGFloat = 0,
        priority: UILayoutPriority? = nil,
        multiplier: CGFloat? = nil,
        isActive: Bool = true) -> NSLayoutConstraint {
        var constraint = anchor.constraint(equalTo: otherAnchor, constant: constant)
        
        if let multiplier = multiplier {
            constraint = constraint.constraintWithMultiplier(multiplier)
        }
        
        (constraint.firstItem as? UIView)?.layout.update(constraint: constraint, kind: kind)
        
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = isActive
        return constraint
    }
    
    @discardableResult
    func greaterThanOrEqual(to otherAnchor: Anchor, offsetBy constant: CGFloat = 0,
                            priority: UILayoutPriority? = nil, isActive: Bool = true) -> NSLayoutConstraint {
        let constraint = anchor.constraint(greaterThanOrEqualTo: otherAnchor, constant: constant)
        (constraint.firstItem as? UIView)?.layout.update(constraint: constraint, kind: kind)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = isActive
        return constraint
    }
    
    @discardableResult
    func lessThanOrEqual(to otherAnchor: Anchor, offsetBy constant: CGFloat = 0,
                         priority: UILayoutPriority? = nil, isActive: Bool = true) -> NSLayoutConstraint {
        let constraint = anchor.constraint(lessThanOrEqualTo: otherAnchor, constant: constant)
        (constraint.firstItem as? UIView)?.layout.update(constraint: constraint, kind: kind)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = isActive
        return constraint
    }
}

extension UIView {
    
    func layout(using closure: (LayoutProxy) -> Void) {
        translatesAutoresizingMaskIntoConstraints = false
        closure(LayoutProxy(view: self))
    }
    
    func layout(in superview: UIView, with insets: UIEdgeInsets = .zero) {
        superview.addSubview(self)
        pinEdges(to: superview, with: insets)
    }
    
    func pinEdges(to view: UIView, with insets: UIEdgeInsets = .zero) {
        layout { proxy in
            proxy.bottom == view.bottomAnchor - insets.bottom
            proxy.top == view.topAnchor + insets.top
            proxy.leading == view.leadingAnchor + insets.left
            proxy.trailing == view.trailingAnchor - insets.right
        }
    }
}

//swiftlint:disable large_tuple

func +<A: LayoutAnchor>(lhs: A, rhs: CGFloat) -> (A, CGFloat) {
    return (lhs, rhs)
}

func -<A: LayoutAnchor>(lhs: A, rhs: CGFloat) -> (A, CGFloat) {
    return (lhs, -rhs)
}

@discardableResult
func ==<A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: (A, CGFloat)) -> NSLayoutConstraint {
    return lhs.equal(to: rhs.0, offsetBy: rhs.1)
}

@discardableResult
func ==<A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: ((A, CGFloat), UILayoutPriority)) -> NSLayoutConstraint {
    return lhs.equal(to: rhs.0.0, offsetBy: rhs.0.1, priority: rhs.1)
}

@discardableResult
func ==<A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: (A, UILayoutPriority)) -> NSLayoutConstraint {
    return lhs.equal(to: rhs.0, priority: rhs.1)
}

@discardableResult
func ==<A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: A) -> NSLayoutConstraint {
    return lhs.equal(to: rhs)
}

@discardableResult
func >=<A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: (A, CGFloat)) -> NSLayoutConstraint {
    return lhs.greaterThanOrEqual(to: rhs.0, offsetBy: rhs.1)
}

@discardableResult
func >=<A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: A) -> NSLayoutConstraint {
    return lhs.greaterThanOrEqual(to: rhs)
}

@discardableResult
func <=<A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: (A, CGFloat)) -> NSLayoutConstraint {
    return lhs.lessThanOrEqual(to: rhs.0, offsetBy: rhs.1)
}

@discardableResult
func <=<A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: A) -> NSLayoutConstraint {
    return lhs.lessThanOrEqual(to: rhs)
}

@discardableResult
func <=<D: LayoutDimension>(lhs: LayoutAttribute<D>, rhs: CGFloat) -> NSLayoutConstraint {
    return lhs.lessThanOrEqual(to: rhs)
}

@discardableResult
func ==<D: LayoutDimension>(lhs: LayoutAttribute<D>, rhs: CGFloat) -> NSLayoutConstraint {
    return lhs.equal(to: rhs)
}

@discardableResult
func ==<D: LayoutDimension>(lhs: LayoutAttribute<D>, rhs: (CGFloat, UILayoutPriority)) -> NSLayoutConstraint {
    return lhs.equal(to: rhs.0, priority: rhs.1)
}

@discardableResult
func ==<D: LayoutDimension>(lhs: LayoutAttribute<D>, rhs: LayoutAttribute<D>) -> NSLayoutConstraint {
    return lhs.equal(to: rhs.dimension)
}

@discardableResult
func *=<D: LayoutDimension>(lhs: LayoutAttribute<D>,
                                   rhs: (LayoutAttribute<D>, CGFloat, UILayoutPriority)) -> NSLayoutConstraint {
    return lhs.equal(to: rhs.0.dimension, multiplier: rhs.1, priority: rhs.2)
}

@discardableResult
func >=<D: LayoutDimension>(lhs: LayoutAttribute<D>, rhs: CGFloat) -> NSLayoutConstraint {
    return lhs.greaterThanOrEqual(to: rhs)
}

//swiftlint:enable large_tuple

extension UIView {
    
    private struct AssociatedKeys {
        static var layout: Void?
    }
    
    var layout: Layout {
        get {
            var layout: Layout!
            let lookup = objc_getAssociatedObject(self, &AssociatedKeys.layout) as? Layout
            if let lookup = lookup {
                layout = lookup
            } else {
                let newLayout = Layout()
                self.layout = newLayout
                layout = newLayout
            }
            return layout
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.layout, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

final class Layout: NSObject {
    
    weak var top: NSLayoutConstraint?
    weak var bottom: NSLayoutConstraint?
    weak var leading: NSLayoutConstraint?
    weak var trailing: NSLayoutConstraint?
    weak var centerX: NSLayoutConstraint?
    weak var centerY: NSLayoutConstraint?
    weak var width: NSLayoutConstraint?
    weak var height: NSLayoutConstraint?
    
    fileprivate func update<A: LayoutAnchor>(constraint: NSLayoutConstraint, kind: LayoutProperty<A>.Kind) {
        switch kind {
        case .top: top = constraint
        case .bottom: bottom = constraint
        case .leading: leading = constraint
        case .trailing: trailing = constraint
        case .centerX: centerX = constraint
        case .centerY: centerY = constraint
        case .width: width = constraint
        case .height: height = constraint
        }
    }
}

extension NSLayoutConstraint {
    
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(
            item: self.firstItem as Any,
            attribute: self.firstAttribute,
            relatedBy: self.relation,
            toItem: self.secondItem,
            attribute: self.secondAttribute,
            multiplier: multiplier,
            constant: self.constant
        )
    }
}
