//
//  CarouselView.swift
//  Infinite ScrollVie
//
//  Created by Thanh - iOS on 31/05/2022.
//

import UIKit

class CarouselView: UIView {
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.autoresizingMask = autoresizingMask
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            scrollView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        
        return scrollView
    }()
    
    private let scrollContentView = UIView()
    
    private weak var scrollTimer: Timer?
    
    //Enable and disable scroll view loop mode
    var circular = true {
        didSet {
            guard circular != oldValue else { return }
            
            //Every time the circular changes, reconfigure the layout of the scroll view
            inputImages = { inputImages }()
        }
    }
    
    var shouldScrollAutomatically = false {
        didSet {
            if shouldScrollAutomatically {
                enableAutomaticScroll()
            } else {
                disableAutomaticScroll()
            }
        }
    }
    
    var waitDuration: TimeInterval = 3 {
        didSet {
            guard shouldScrollAutomatically else { return }
            enableAutomaticScroll()
        }
    }
    
    private var canLoop: Bool {
        return circular && (inputImages.count > 1)
    }
    
    //User-specified initial input
    var inputImages = [UIImage]() {
        didSet {
            guard canLoop,
                  let lastImage = inputImages.last,
                  let firstImage = inputImages.first
            else {
                scrollViewImages = inputImages
                return
            }
            
            scrollViewImages = [lastImage] + inputImages + [firstImage]
        }
    }
    
    //Array containing original input and 2 fake inputs added if canLoop == true
    private var scrollViewImages = [UIImage]() {
        didSet {
            //Re-Config layout of scroll view
            reloadScrollView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //Adjust the page of scrollView to avoid stalling between 2 items
        let page = page(for: scrollView.contentOffset.x, width: scrollView.bounds.width)
        _set(page: page, animated: false)
    }
    
    //Set page based on inputImages
    //Users will interact through this function to avoid confusion
    func set(page newPage: Int, animated: Bool) {
        shouldScrollAutomatically = false
        _set(page: newPage + 1, animated: animated)
        shouldScrollAutomatically = true
    }
    
    //Set page based on scrollViewImages
    private func _set(page newPage: Int, animated: Bool) {
        //Handling invalid new Page input
        //if newPage < 0 will get 0
        //if newPage >= scrollViewImages.count will get scrollViewImages.count - 1
        let newPage = min(max(0, newPage), scrollViewImages.count - 1)
        let rect = CGRect(x: scrollView.bounds.width * CGFloat(newPage),
                          y: 0,
                          width: scrollView.bounds.width,
                          height: scrollView.bounds.height)
        scrollView.scrollRectToVisible(rect, animated: animated)
    }
    
    private func enableAutomaticScroll() {
        guard shouldScrollAutomatically else { return }
        guard inputImages.count > 1 else { return }
        scrollTimer?.invalidate()
        scrollTimer = Timer.scheduledTimer(withTimeInterval: waitDuration, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.scrollNext()
        }
    }
    
    private func disableAutomaticScroll() {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
    
    //Returns the page based on the contentOffset.x and the item's width
    //To get page current transport to scrollView.contentOffset.x and scrollView.bounds.width
    private func page(for offset: CGFloat, width: CGFloat) -> Int {
        return width > 0 ? Int(offset + width / 2) / Int(width) : 0
    }
    
    private func scrollNext() {
        guard inputImages.count > 1 else { return }
        let currentPage = page(for: scrollView.contentOffset.x, width: scrollView.bounds.width)
        let nextPage = currentPage + 1 == scrollViewImages.count ? 0 : currentPage + 1
        _set(page: nextPage, animated: true)
    }
    
    private func reloadScrollView() {
        //delete old item
        for view in scrollContentView.subviews {
            view.removeFromSuperview()
        }
        
        //Add new item
        //item.width == scrollView.bounds.width
        addScrollItems(for: scrollViewImages)
        layoutIfNeeded()
        
        //if circular == true & 2 item fake added
        //we have to offset the scroll view to hide the fake item at the top
        if canLoop {
            let focusRect = CGRect(x: scrollView.bounds.width,
                                   y: 0,
                                   width: scrollView.bounds.width,
                                   height: scrollView.bounds.height)
            
            scrollView.scrollRectToVisible(focusRect, animated: false)
        }
    }
    
    private func addScrollItems(for images: [UIImage]) {
        var leadingAnchor = scrollContentView.leadingAnchor
        for (index, image) in scrollViewImages.enumerated() {
            let item = item(for: image)
            scrollContentView.addSubview(item)
            
            item.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                item.leadingAnchor.constraint(equalTo: leadingAnchor),
                item.topAnchor.constraint(equalTo: scrollContentView.topAnchor),
                item.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
                item.widthAnchor.constraint(equalTo: widthAnchor)
            ])
            
            leadingAnchor = item.trailingAnchor
            
            if index == scrollViewImages.count - 1 {
                item.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor).isActive = true
            }
        }
    }
    
    private func item(for image: UIImage) -> UIImageView {
        let item = UIImageView(image: image)
        item.contentMode = .scaleAspectFill
        item.clipsToBounds = true
        return item
    }
    
    private func initialize() {
        autoresizesSubviews = true
        clipsToBounds = true
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        scrollView.addSubview(scrollContentView)
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollContentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scrollContentView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }
}

extension CarouselView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard canLoop else { return }
        
        if scrollView.contentOffset.x >= scrollView.bounds.width * CGFloat(inputImages.count + 1) {
            //Set offset to the real item at the beginning when fully scrolling the fake item at the end
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.width, y: 0)
        } else if scrollView.contentOffset.x <= 0 {
            //Set offset to real item at the end when fully scrolling fake item at the top
            let maxNormalContentOffset = scrollView.bounds.width * CGFloat(inputImages.count)
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x + maxNormalContentOffset, y: 0)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        disableAutomaticScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        enableAutomaticScroll()
    }
}
