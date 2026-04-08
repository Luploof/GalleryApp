import UIKit

class PhotoCellView: UICollectionViewCell {
    private let imageView = UIImageView()
    private let favoriteButton = UIButton(type: .system)
    
    private var currentPhotoId: String?
    private var downloadTask: Task<Void, Never>?
    
    var onFavoriteTapped: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        
        favoriteButton.tintColor = .red
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func favoriteTapped() {
        guard let id = currentPhotoId else { return }
        onFavoriteTapped?(id)
    }
    
    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(favoriteButton)
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(photo: Photo) {
        currentPhotoId = photo.id
        let imageName = photo.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        downloadTask?.cancel()
        imageView.image = nil
        
        downloadTask = Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: photo.urls.thumb)
                try Task.checkCancellation()
                
                if let image = UIImage(data: data) {
                    self.imageView.image = image
                }
            } catch {
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
        imageView.image = nil
        currentPhotoId = nil
    }
}
