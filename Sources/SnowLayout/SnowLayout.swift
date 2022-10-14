import UIKit

// MARK: - Precedence Group
precedencegroup SnowLayoutConstraintPrecedence {
  associativity: left
  assignment: false
  lowerThan: AdditionPrecedence
  higherThan: SnowLayoutConstraintPriorityPrecendence
}

precedencegroup SnowLayoutConstraintPriorityPrecendence {
  associativity: left
  assignment: false
  lowerThan: AdditionPrecedence
}

// MARK: - Operator
/// Option + X key
infix operator ≈: SnowLayoutConstraintPrecedence
/// Option + > key
infix operator ≥: SnowLayoutConstraintPrecedence
/// Option + < key
infix operator ≤: SnowLayoutConstraintPrecedence
/// Option + 8 key
infix operator •: SnowLayoutConstraintPriorityPrecendence

// MARK: - Priority Operator
public func •(lhs: NSLayoutConstraint, rhs: UILayoutPriority) -> NSLayoutConstraint {
  lhs.priority = rhs
  return lhs
}

public func •(lhs: NSLayoutConstraint, rhs: Int) -> NSLayoutConstraint {
  lhs.priority = UILayoutPriority(rawValue: Float(rhs))
  return lhs
}

public func •(lhs: [NSLayoutConstraint], rhs: UILayoutPriority) -> [NSLayoutConstraint] {
  return lhs.map { $0 • rhs }
}

public func •(lhs: [NSLayoutConstraint], rhs: Int) -> [NSLayoutConstraint] {
  return lhs.map { $0 • UILayoutPriority(rawValue: Float(rhs)) }
}

// MARK: - SnowAnchor
public protocol SnowAnchor {
  associatedtype AnchorType
  
  var constant: CGFloat { get }
  var anchor: AnchorType { get }
  var priority: UILayoutPriority { get }
  var multipier: CGFloat { get }
}

public extension SnowAnchor {
  var priority: UILayoutPriority { .required }
  var multipier: CGFloat { 1 }
  var constant: CGFloat { 0 }
}

public extension SnowAnchor {
  static func +(lhs: Self, rhs: CGFloat) -> SnowAnchorContainer<AnchorType> {
    return SnowAnchorContainer(anchor: lhs, constant: rhs)
  }
  
  static func -(lhs: Self, rhs: CGFloat) -> SnowAnchorContainer<AnchorType> {
    return SnowAnchorContainer(anchor: lhs, constant: -rhs)
  }
  
  static func *(lhs: Self, rhs: CGFloat) -> SnowAnchorContainer<AnchorType> {
    return SnowAnchorContainer(anchor: lhs, multipier: rhs)
  }
  
  @available(*, deprecated, message: "Use recommend '*' operator instead of '/'")
  static func /(lhs: Self, rhs: CGFloat) -> SnowAnchorContainer<AnchorType> {
    return SnowAnchorContainer(anchor: lhs, multipier: 1 / rhs)
  }
}

// MARK: - SnowAnchorContainer
public struct SnowAnchorContainer<U>: SnowAnchor {
  public typealias AnchorType = U
  
  public var anchor: AnchorType
  public var constant: CGFloat
  public var multipier: CGFloat
  public var priority: UILayoutPriority

  init<T: SnowAnchor>(anchor: T, constant: CGFloat) where T.AnchorType == AnchorType {
    self.anchor = anchor.anchor
    self.constant = constant
    self.multipier = anchor.multipier
    self.priority = anchor.priority
  }
  
  init<T: SnowAnchor>(anchor: T, multipier: CGFloat) where T.AnchorType == AnchorType {
    self.anchor = anchor.anchor
    self.constant = anchor.constant
    self.multipier = multipier
    self.priority = anchor.priority
  }
  
  init<T: SnowAnchor>(anchor: T, priority: UILayoutPriority) where T.AnchorType == AnchorType {
    self.anchor = anchor.anchor
    self.constant = anchor.constant
    self.multipier = anchor.multipier
    self.priority = priority
  }
}

// MARK: - SnowAxisAnchorConstraint
public protocol SnowAxisAnchorConstraint: SnowAnchor {
  func constraint(equalTo: AnchorType, constant: CGFloat) -> NSLayoutConstraint
  func constraint(lessThanOrEqualTo: AnchorType, constant: CGFloat) -> NSLayoutConstraint
  func constraint(greaterThanOrEqualTo: AnchorType, constant: CGFloat) -> NSLayoutConstraint
}

public protocol SnowAnchorDimensionConstraint: SnowAnchor {
  func constraint(equalToConstant: CGFloat) -> NSLayoutConstraint
  func constraint(lessThanOrEqualToConstant: CGFloat) -> NSLayoutConstraint
  func constraint(greaterThanOrEqualToConstant: CGFloat) -> NSLayoutConstraint

  func constraint(equalTo: AnchorType, multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint
  func constraint(lessThanOrEqualTo: AnchorType, multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint
  func constraint(greaterThanOrEqualTo: AnchorType, multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint
}

public extension SnowAxisAnchorConstraint {
  @discardableResult
  static func ≈<T: SnowAnchor>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
    return lhs.constraint(equalTo: rhs.anchor, constant: rhs.constant)
  }
  
  @discardableResult
  static func ≥<T: SnowAnchor>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
    return lhs.constraint(greaterThanOrEqualTo: rhs.anchor, constant: rhs.constant)
  }
  
  @discardableResult
  static func ≤<T: SnowAnchor>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
    return lhs.constraint(lessThanOrEqualTo: rhs.anchor, constant: rhs.constant)
  }
}

public extension SnowAnchorDimensionConstraint {
  @discardableResult
  static func ≈<T: SnowAnchor>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
    return lhs.constraint(equalTo: rhs.anchor, multiplier: rhs.multipier, constant: rhs.constant)
  }
  
  @discardableResult
  static func ≥<T: SnowAnchor>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
    return lhs.constraint(greaterThanOrEqualTo: rhs.anchor, multiplier: rhs.multipier, constant: rhs.constant)
  }
  
  @discardableResult
  static func ≤<T: SnowAnchor>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
    return lhs.constraint(lessThanOrEqualTo: rhs.anchor, multiplier: rhs.multipier, constant: rhs.constant)
  }
  
  @discardableResult
  static func ≈(lhs: Self, rhs: CGFloat) -> NSLayoutConstraint {
    return lhs.constraint(equalToConstant: rhs)
  }
  
  @discardableResult
  static func ≥(lhs: Self, rhs: CGFloat) -> NSLayoutConstraint {
    return lhs.constraint(greaterThanOrEqualToConstant: rhs)
  }
  
  @discardableResult
  static func ≤(lhs: Self, rhs: CGFloat) -> NSLayoutConstraint {
    return lhs.constraint(lessThanOrEqualToConstant: rhs)
  }
}

// MARK: - Protocol SnowAxisAnchorConstraint conform to NSLayoutAnchor implementation class.
extension NSLayoutXAxisAnchor: SnowAxisAnchorConstraint {
  public typealias AnchorType = NSLayoutAnchor<NSLayoutXAxisAnchor>

  public var anchor: AnchorType { self }
}

extension NSLayoutYAxisAnchor: SnowAxisAnchorConstraint {
  public typealias AnchorType = NSLayoutAnchor<NSLayoutYAxisAnchor>

  public var anchor: AnchorType { self }
}

extension NSLayoutDimension: SnowAnchorDimensionConstraint {
  public typealias AnchorType = NSLayoutDimension
  
  public var anchor: AnchorType { self }
}

// MARK: - Multiple Anchor
public struct SnowMultipleAnchor: SnowAnchor {
  public typealias AnchorType = ([NSLayoutXAxisAnchor], [NSLayoutYAxisAnchor])
  public var anchor: AnchorType
  
  public init(xAxis: [NSLayoutXAxisAnchor], yAxis: [NSLayoutYAxisAnchor]) {
    self.anchor = (xAxis, yAxis)
  }
}

public extension SnowMultipleAnchor {
  @discardableResult
  static func ≈<T: SnowAnchor>(lhs: Self, rhs: T) -> [NSLayoutConstraint] where T.AnchorType == AnchorType {
    let (lhsXAxisAnchors, lhsYAxisAnchors) = lhs.anchor
    let (rhsXAxisAnchors, rhsYAxisAnchors) = rhs.anchor
    
    var constraints = [NSLayoutConstraint]([])
    
    for (lhsXAnchor, rhsXAnchor) in zip(lhsXAxisAnchors, rhsXAxisAnchors) {
      constraints.append(lhsXAnchor.constraint(equalTo: rhsXAnchor, constant: rhs.constant))
    }
    
    for (lhsYAnchor, rhsYAnchor) in zip(lhsYAxisAnchors, rhsYAxisAnchors) {
      constraints.append(lhsYAnchor.constraint(equalTo: rhsYAnchor, constant: rhs.constant))
    }
    
    return constraints
  }
}

// MARK: - Size Anchor
public extension Array where Element: SnowAnchorDimensionConstraint {
  @discardableResult
  static func ≈<T: SnowAnchor>(lhs: Self, rhs: [T]) -> [NSLayoutConstraint] where T.AnchorType == Element.AnchorType {
    
    var constraints = [NSLayoutConstraint]([])
    for (lhsAnchor, rhsAnchor) in zip(lhs, rhs) {
      constraints.append(lhsAnchor.constraint(equalTo: rhsAnchor.anchor,
                                              multiplier: rhsAnchor.multipier,
                                              constant: rhsAnchor.constant))
    }
    return constraints
  }
}

// MARK: UIView+Anchor
public extension UIView {
  var edgeAnchor: SnowMultipleAnchor {
    SnowMultipleAnchor(xAxis: [leadingAnchor, trailingAnchor],
                       yAxis: [topAnchor, bottomAnchor])
  }
  
  var centerAnchor: SnowMultipleAnchor {
    SnowMultipleAnchor(xAxis: [centerXAnchor], yAxis: [centerYAnchor])
  }
  
  var sizeAnchor: [NSLayoutDimension] {
    [widthAnchor, heightAnchor]
  }
}

// MARK: UIView+Safe Anchor
public extension UIView {
  struct SafeArea {
    unowned let view: UIView
    init(_ view: UIView) {
      self.view = view
    }
    
    public var edgeAnchor: SnowMultipleAnchor {
      SnowMultipleAnchor(xAxis: [view.safeAreaLayoutGuide.leadingAnchor, view.safeAreaLayoutGuide.trailingAnchor],
                         yAxis: [view.safeAreaLayoutGuide.topAnchor, view.safeAreaLayoutGuide.bottomAnchor])
    }
    
    public var topEdgeAnchor: SnowMultipleAnchor {
      SnowMultipleAnchor(xAxis: [view.leadingAnchor, view.trailingAnchor],
                         yAxis: [view.safeAreaLayoutGuide.topAnchor, view.bottomAnchor])
    }
    
    public var yEdgeAnchor: SnowMultipleAnchor {
      SnowMultipleAnchor(xAxis: [view.leadingAnchor, view.trailingAnchor],
                         yAxis: [view.safeAreaLayoutGuide.topAnchor, view.safeAreaLayoutGuide.bottomAnchor])
    }
    
    public var xEdgeAnchor: SnowMultipleAnchor {
      SnowMultipleAnchor(xAxis: [view.safeAreaLayoutGuide.leadingAnchor, view.safeAreaLayoutGuide.trailingAnchor],
                         yAxis: [view.topAnchor, view.bottomAnchor])
    }
  }
  
  var safeArea: SafeArea { SafeArea(self) }
}

// MARK: - Layout Builder
public protocol SnowLayoutAnchorGroup {
  var constraints: [NSLayoutConstraint] { get }
}

extension NSLayoutConstraint: SnowLayoutAnchorGroup {
  public var constraints: [NSLayoutConstraint] { [self] }
}

extension Array: SnowLayoutAnchorGroup where Element == NSLayoutConstraint {
  public var constraints: [NSLayoutConstraint] { self }
}

@resultBuilder
public struct SnowLayoutAnchorBuilder {
  public static func buildBlock(_ components: SnowLayoutAnchorGroup...) -> [NSLayoutConstraint] {
    return components.flatMap { $0.constraints }
  }
  
  public static func buildOptional(_ component: [SnowLayoutAnchorGroup]?) -> [NSLayoutConstraint] {
    return component?.flatMap { $0.constraints } ?? []
  }
  
  public static func buildEither(first component: [SnowLayoutAnchorGroup]) -> [NSLayoutConstraint] {
    return component.flatMap { $0.constraints }
  }
  
  public static func buildEither(second component: [SnowLayoutAnchorGroup]) -> [NSLayoutConstraint] {
    return component.flatMap { $0.constraints }
  }
}

public extension UIViewController {
  func activateConstraints(@SnowLayoutAnchorBuilder constraints: () -> [NSLayoutConstraint]) {
    NSLayoutConstraint.activate(constraints())
  }
  
  func deactivateConstraints(@SnowLayoutAnchorBuilder constraints: () -> [NSLayoutConstraint]) {
    NSLayoutConstraint.deactivate(constraints())
  }
}
