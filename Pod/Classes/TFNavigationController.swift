//
//  TFNavigationController.swift
//  TFTransparentNavigationBar
//
//  Created by Ales Kocur on 10/03/2015.
//  Copyright (c) 2015 Ales Kocur. All rights reserved.
//

import UIKit

@objc public enum TFNavigationBarStyle: Int {
  case Transparent, Solid
}

@objc public protocol TFTransparentNavigationBarProtocol {
  func navigationControllerBarPushStyle() -> TFNavigationBarStyle
}

public class TFNavigationController: UINavigationController {
  
  private var interactionController: UIPercentDrivenInteractiveTransition?
  private var temporaryBackgroundImage: UIImage?
  var navigationBarSnapshots: Dictionary<Int, UIView> = Dictionary()
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    navigationBar.translucent = false
    navigationBar.shadowImage = UIImage()
    
    delegate = self
    transitioningDelegate = self
    
    let left = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(TFNavigationController.handleSwipeFromLeft(_:)))
    left.edges = .Left
    view.addGestureRecognizer(left);
    
    
  }
  
  func handleSwipeFromLeft(gesture: UIScreenEdgePanGestureRecognizer) {
    let percent = gesture.translationInView(gesture.view!).x / gesture.view!.bounds.size.width
    
    if gesture.state == .Began {
      interactionController = UIPercentDrivenInteractiveTransition()
      
      if viewControllers.count > 1 {
        popViewControllerAnimated(true)
      } else {
        dismissViewControllerAnimated(true, completion: nil)
      }
    } else if gesture.state == .Changed {
      interactionController?.updateInteractiveTransition(percent)
    } else if gesture.state == .Ended || gesture.state == .Cancelled || gesture.state == .Failed {
      
      if percent > 0.5 {
        interactionController?.finishInteractiveTransition()
      } else {
        interactionController?.cancelInteractiveTransition()
      }
      interactionController = nil
    }
  }
  
  
  // MARK: - Helpers
  
  func forwardAnimator(fromViewController: UIViewController, toViewController: UIViewController) -> TFForwardAnimator? {
    
    var fromStyle: TFNavigationBarStyle = TFNavigationBarStyle.Solid
    
    if let source = fromViewController as? TFTransparentNavigationBarProtocol {
      fromStyle = source.navigationControllerBarPushStyle()
    }
    
    var toStyle: TFNavigationBarStyle = TFNavigationBarStyle.Solid
    
    if let presented = toViewController as? TFTransparentNavigationBarProtocol {
      toStyle = presented.navigationControllerBarPushStyle()
    }
    
    var styleTransition: TFNavigationBarStyleTransition!
    
    if fromStyle == .Solid && toStyle == .Solid {
      return nil
    } else if (fromStyle == .Transparent && toStyle == .Transparent) {
      styleTransition = .toSame
    } else if fromStyle == .Transparent && toStyle == .Solid {
      styleTransition = .toSolid
    } else if fromStyle == .Solid && toStyle == .Transparent {
      styleTransition = .toTransparent
    }
    
    return TFForwardAnimator(navigationController: self, navigationBarStyleTransition: styleTransition, isInteractive: interactionController != nil)
  }
  
  func backwardAnimator(fromViewController: UIViewController, toViewController: UIViewController) -> TFBackwardAnimator? {
    
    var fromStyle: TFNavigationBarStyle = TFNavigationBarStyle.Solid
    
    if let fromViewController = fromViewController as? TFTransparentNavigationBarProtocol {
      fromStyle = fromViewController.navigationControllerBarPushStyle()
    }
    
    var toStyle: TFNavigationBarStyle = TFNavigationBarStyle.Solid
    
    if let toViewController = toViewController as? TFTransparentNavigationBarProtocol {
      toStyle = toViewController.navigationControllerBarPushStyle()
    }
    var styleTransition: TFNavigationBarStyleTransition!
    
    if fromStyle == toStyle {
      styleTransition = .toSame
    } else if fromStyle == .Solid && toStyle == .Transparent {
      styleTransition = .toTransparent
    } else if fromStyle == .Transparent && toStyle == .Solid {
      styleTransition = .toSolid
    }
    
    return TFBackwardAnimator(navigationController: self, navigationBarStyleTransition: styleTransition, isInteractive: interactionController != nil)
  }
  
  
  func setupNavigationBarByStyle(transitionStyle: TFNavigationBarStyleTransition) {
    
    if (transitionStyle == .toTransparent) {
      
      navigationBar.translucent = true
      temporaryBackgroundImage = navigationBar.backgroundImageForBarMetrics(.Default)
      navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
      navigationBar.shadowImage = UIImage()
      
      
    } else if (transitionStyle == .toSolid) {
      
      navigationBar.translucent = false
      navigationBar.setBackgroundImage(temporaryBackgroundImage, forBarMetrics: .Default)
      navigationBar.shadowImage = nil
    }
  }
  
}

// MARK: - UINavigationBarDelegate
extension TFNavigationController: UINavigationBarDelegate {
  
  
}

// MARK: - UINavigationControllerDelegate
extension TFNavigationController: UINavigationControllerDelegate {
  
  public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    if operation == .Push {
      return forwardAnimator(fromVC, toViewController: toVC)
    } else if operation == .Pop {
      return backwardAnimator(fromVC, toViewController: toVC)
    }
    return nil
  }
  
  public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactionController
  }
}

// MARK: - UIViewControllerTransitioningDelegate
extension TFNavigationController: UIViewControllerTransitioningDelegate {
  
  public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    return forwardAnimator(source, toViewController: presented)
  }
  
  public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    if (viewControllers.count < 2) {
      return nil
    }
    
    // Last but one controller in stack
    let previousController = viewControllers[self.viewControllers.count - 2]
    
    return backwardAnimator(dismissed, toViewController: previousController)
  }
  
  public func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    return interactionController
  }
  
  public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    return interactionController
  }
}
