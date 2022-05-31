//
//  ViewController.swift
//  Infinite ScrollVie
//
//  Created by Thanh - iOS on 31/05/2022.
//

import UIKit

class ViewController: UIViewController {
    private let slideShow = CarouselView()
    
    private let colorfulSlide = CarouselView()
    
    private let animeSlide = CarouselView()

    override func viewDidLoad() {
        super.viewDidLoad()
        inputImageSlideShow()
        setupLayout()
        // Do any additional setup after loading the view.
    }
    
    func inputImageSlideShow() {
        let sources = [UIImage(named: "travel1")!,
                       UIImage(named: "travel2")!,
                       UIImage(named: "travel3")!,
                       UIImage(named: "travel4")!,
                       UIImage(named: "travel5")!]
        slideShow.inputImages = sources
        
        let colorfulSource = [UIImage(named: "colorful1")!,
                              UIImage(named: "colorful2")!,
                              UIImage(named: "colorful3")!,
                              UIImage(named: "colorful4")!]
        colorfulSlide.inputImages = colorfulSource
        
        let animeSource = [UIImage(named: "1")!,
                           UIImage(named: "2")!,
                           UIImage(named: "3")!,
                           UIImage(named: "4")!,
                           UIImage(named: "5")!]
        animeSlide.inputImages = animeSource
        
        [slideShow, colorfulSlide, animeSlide].forEach({ $0.shouldScrollAutomatically = true })
    }

    func setupLayout() {
        view.addSubview(slideShow)
        slideShow.translatesAutoresizingMaskIntoConstraints = false
        slideShow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        slideShow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        slideShow.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0).isActive = true
        slideShow.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.28).isActive = true
        
        view.addSubview(colorfulSlide)
        colorfulSlide.translatesAutoresizingMaskIntoConstraints = false
        colorfulSlide.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        colorfulSlide.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        colorfulSlide.topAnchor.constraint(equalTo: slideShow.layoutMarginsGuide.bottomAnchor, constant: 30).isActive = true
        colorfulSlide.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.28).isActive = true
        
        view.addSubview(animeSlide)
        animeSlide.translatesAutoresizingMaskIntoConstraints = false
        animeSlide.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        animeSlide.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        animeSlide.topAnchor.constraint(equalTo: colorfulSlide.layoutMarginsGuide.bottomAnchor, constant: 30).isActive = true
        animeSlide.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.28).isActive = true
    }

}

