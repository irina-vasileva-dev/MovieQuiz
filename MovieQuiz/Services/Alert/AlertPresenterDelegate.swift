import UIKit

protocol AlertPresenterDelegate: AnyObject {
    var viewControllerForPresenting: UIViewController? { get }
}
