import UIKit

@MainActor
class DetailViewController: UIViewController {
    
    private let viewModel: DetailViewModel
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let titleLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private var imageLoadTask: Task<Void, Never>?
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        bindViewModel()
        updateUI(with: viewModel.photo)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageLoadTask?.cancel()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 20)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        
        favoriteButton.tintColor = .systemRed
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        
        view.addSubview(imageView)
        view.addSubview(descriptionLabel)
        view.addSubview(titleLabel)
        view.addSubview(favoriteButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false 
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            favoriteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.centerYAnchor.constraint(equalTo: favoriteButton.centerYAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -12)
        ])
    }

    
    private func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    private func bindViewModel() {
        viewModel.onPhotoChanged = { [weak self] photo in
            self?.updateUI(with: photo)
        }
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            viewModel.next()
        } else if gesture.direction == .right {
            viewModel.previous()
        }
    }
    
    @objc private func favoriteTapped() {
        viewModel.toggleFavorite()
    }
    
    private func updateUI(with photo: Photo) {
        titleLabel.text = photo.title ?? "Photo"
        descriptionLabel.text = photo.description ?? "No description available"
        
        let iconName = photo.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: iconName), for: .normal)
        
        imageLoadTask?.cancel()
        imageView.image = nil
        
        imageLoadTask = Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: photo.urls.full)
                if !Task.isCancelled {
                    if let image = UIImage(data: data) {
                        self.imageView.image = image
                    }
                }
            } catch {
                if !(error is CancellationError) {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
