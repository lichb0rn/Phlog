//
//  ModalViewController.swift
//  phlog
//
//  Created by Miroslav Taleiko on 11.12.2021.
//

import UIKit

class ModalViewController: UIViewController {
    
    // --------------------------------------
    // MARK: - Magic constants
    // --------------------------------------
    private static let topViewDimmingDuration: CGFloat = 0.5
    private static let containerBottomConstraintDuration: CGFloat = 0.5
    private static let containerHeightConstraintDuration: CGFloat = 0.5
    private static let dissmissDuration: CGFloat = 0.3
    
    // --------------------------------------
    // MARK: - Properties and Views
    // --------------------------------------
    let childViewController: UIViewController
    
    let dimmedAlpha: CGFloat = 0.5
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = dimmedAlpha
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    let containerViewMaxHeight: CGFloat = 170
    let dismissHeight: CGFloat = 100
    var containerViewCurrentHeight: CGFloat = 170
    
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    // --------------------------------------
    // MARK: - Init
    // --------------------------------------
    init(child: UIViewController) {
        self.childViewController = child
        
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // --------------------------------------
    // MARK: - Lifecycle
    // --------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureConstraints()
        configureChild()
        
        tapGesture()
        setupGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateTopView()
        animateContainerView()
    }
    
    // --------------------------------------
    // MARK: - UI Setup and Configuration
    // --------------------------------------
    
    private func configureView() {
        self.view.backgroundColor = .clear
    }

    private func configureConstraints() {
        configureTopViewConstraints()
        configureContainerViewConstraints()
    }

    private func configureTopViewConstraints() {
        self.view.addSubview(topView)
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: self.view.topAnchor),
            topView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    private func configureContainerViewConstraints() {
        self.view.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: containerViewMaxHeight)
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    private func updateBottomConstraints() {
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: containerViewMaxHeight)
    }
    
    
    private func configureChild() {
        self.addChild(childViewController)
        self.containerView.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
        
        guard let childSuperview = childViewController.view.superview else  { return }
        
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childViewController.view.topAnchor.constraint(equalTo: childSuperview.topAnchor),
            childViewController.view.bottomAnchor.constraint(equalTo: childSuperview.bottomAnchor),
            childViewController.view.leadingAnchor.constraint(equalTo: childSuperview.leadingAnchor),
            childViewController.view.trailingAnchor.constraint(equalTo: childSuperview.trailingAnchor)
        ])
    }
    
    // --------------------------------------
    // MARK: - Animation
    // --------------------------------------
    
    private func animateTopView(withDuration duration: CGFloat = topViewDimmingDuration) {
        topView.alpha = 0
        UIView.animate(withDuration: duration) {
            self.topView.alpha = self.dimmedAlpha
        }

    }
    
    private func animateContainerView(withDuriation duration: CGFloat = containerBottomConstraintDuration) {
        
        UIView.animate(withDuration: duration) {
            self.containerViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func animateDismiss(withDuration duration: CGFloat = dissmissDuration) {
        UIView.animate(withDuration: duration) {
            self.containerViewBottomConstraint?.constant = self.containerViewMaxHeight
            self.view.layoutIfNeeded()
        }
        
        topView.alpha = dimmedAlpha
        UIView.animate(withDuration: duration) {
            self.topView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    private func animateContainerViewHeight(withDuration duration: CGFloat = containerHeightConstraintDuration, to height: CGFloat) {
        UIView.animate(withDuration: duration) {
            self.containerViewHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        }
        
        containerViewCurrentHeight = height
    }
    
    // --------------------------------------
    // MARK: - Gestures
    // --------------------------------------
    
    private func setupGestures() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        self.view.addGestureRecognizer(gesture)
    }
    
    private func tapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture))
        topView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTapGesture() {
        self.animateDismiss()
    }
    
    @objc private func handleGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
    
        let height = containerViewCurrentHeight - translation.y
        
        switch gesture.state {
        case .changed:
            // Updating the height constraint while user is dragging
            if height < containerViewMaxHeight {
                containerViewHeightConstraint?.constant = height
                self.view.layoutIfNeeded()
            }
        case .ended:
            if height < dismissHeight {
                // If a user dragged below dismissable height, hide the view
                self.animateDismiss()
            } else if height < containerViewMaxHeight {
                self.animateContainerViewHeight(to: containerViewMaxHeight)
            }
        default:
            break
        }
    }
}


public extension UIViewController {
    func presentModalViewController(with child: UIViewController = UIViewController(), completion: (() -> Void)? = nil) {
        let modalViewController = ModalViewController(child: child)
        self.present(modalViewController, animated: false, completion: completion)
    }
}
