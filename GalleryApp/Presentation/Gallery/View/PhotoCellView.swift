import UIKit

class PhotoCellView: UICollectionViewCell {
    private let imageView = UIImageView()
    private let favoriteButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private var viewModel: PhotoCellViewModel?
    
    var onFavoriteTapped: ((Photo) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        
        favoriteButton.tintColor = .red
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        activityIndicator.hidesWhenStopped = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func favoriteTapped() {
        guard let viewModel = viewModel else { return }
        let photo = Photo(
            id: viewModel.photoId,
            title: nil,
            description: nil,
            urls: PhotoURLs(thumb: viewModel.thumbURL, full: viewModel.thumbURL),
            isFavorite: viewModel.isFavorite
        )
        onFavoriteTapped?(photo)
    }
    
    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(activityIndicator)
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    func configure(with viewModel: PhotoCellViewModel) {
        self.viewModel = viewModel
        
        let imageName = viewModel.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        if let image = viewModel.image {
            imageView.image = image
            activityIndicator.stopAnimating()
        } else if viewModel.isLoading {
            imageView.image = nil
            activityIndicator.startAnimating()
        } else {
            imageView.image = nil
            activityIndicator.startAnimating()
            viewModel.loadImage()
        }
        
        viewModel.onStateChanged = { [weak self] in
            self?.updateUI()
        }
    }
    
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
        let imageName = viewModel.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        if let image = viewModel.image {
            imageView.image = image
            activityIndicator.stopAnimating()
        } else if viewModel.isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
        imageView.image = nil
        activityIndicator.stopAnimating()
    }
}
