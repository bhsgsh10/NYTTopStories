//
//  TopStoryTableViewCell.swift
//  NYTTopStories
//
//  Created by Bhaskar Ghosh on 9/15/20.
//  Copyright © 2020 Bhaskar Ghosh. All rights reserved.
//

import UIKit

class TopStoryTableViewCell: UITableViewCell {
    
    var cachedImage: UIImage?
    
    var topStoryResult: TopStoryResult? {
        didSet {
            headlineLabel.text = topStoryResult?.title ?? ""
            authorLabel.text = topStoryResult?.byline ?? "NA"
            if let multimedia: TopStoryMultimedia = topStoryResult?.multimedia![0],
                let imageUrlStr = multimedia.url,
                let imageUrl = URL(string: imageUrlStr) {
                    
                let imageTask = URLSession.shared.dataTask(with: URLRequest(url: imageUrl)) { (data, response, error) in
                    
                    if let error = error {
                        print("Error took place \(error)")
                        return
                    }
                    
                    if let imageData = data, let image = UIImage(data: imageData) {
                        self.cachedImage = image
                        DispatchQueue.main.async {
                            self.storyImageView.image = image
                        }
                    }
                    
                }
                imageTask.resume()
            }
        }
    }
    
    private var headlineLabel: UILabel = {
        let label: UILabel = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.font = UIFont(name: "Helvetica", size: 20)
        return label
    }()
    
    private var authorLabel: UILabel = {
        let authLabel = UILabel(frame: .zero)
        authLabel.numberOfLines = 0
        authLabel.font = UIFont(name: "Helvetica", size: 12)
        authLabel.textColor = UIColor.lightGray
        return authLabel
    }()
    
    private var storyImageView: UIImageView = {
        let imgView = UIImageView(frame: .zero)
        imgView.contentMode = .scaleToFill
        imgView.applyStandardBorderAndShadow()
        return imgView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        contentView.addSubview(headlineLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(storyImageView)
        
        applyConstraints()
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func applyConstraints() {
        applyConstraintsToImageView()
        applyConstraintsToHeadlineLabel()
        applyConstraintsToAuthorLabel()
    }
    
    private func applyConstraintsToHeadlineLabel() {
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
           headlineLabel.leadingAnchor.constraint(equalTo: storyImageView.leadingAnchor),
           headlineLabel.trailingAnchor.constraint(equalTo: storyImageView.trailingAnchor),
           headlineLabel.topAnchor.constraint(equalTo: storyImageView.bottomAnchor, constant: 8),
       ])
    }
    
    private func applyConstraintsToAuthorLabel() {
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            authorLabel.leadingAnchor.constraint(equalTo: headlineLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: headlineLabel.trailingAnchor),
            authorLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 8),
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func applyConstraintsToImageView() {
        storyImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
        
            storyImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            storyImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            storyImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            storyImageView.heightAnchor.constraint(equalToConstant: 200.0)
        ])
    }
}

extension UIImageView {
    func applyStandardBorderAndShadow() {
        self.layer.masksToBounds = true // this property has to be set true for the corner radius property to have any effect
        self.layer.cornerRadius = 5.0
        
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.8
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.clipsToBounds = false //if this property is true, the shadow will be clipped for UIImageView
        
        self.layer.shouldRasterize = true
    }
}
