import UIKit

@MainActor
class GalleryViewController: UIViewController {
    private let collectionView: UICollectionView
    private let viewModel: GalleryViewModel
    private let layout = UICollectionViewFlowLayout()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    var onPhotoSelected: ((Photo, [Photo]) -> Void)?
    
    init(viewModel: GalleryViewModel) {
        self.viewModel = viewModel
        
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .vertical
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        collectionView.register(PhotoCellView.self, forCellWithReuseIdentifier: "PhotoCellView")
        collectionView.register(UICollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: "Footer")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] in
            self?.collectionView.reloadData()
            if let errorMessage = self?.viewModel.errorMessage, !errorMessage.isEmpty {
                let alert = UIAlertController(
                    title: "Error",
                    message: errorMessage,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Repeat", style: .default) { _ in
                    Task { await self?.viewModel.loadMorePhotos() }
                })
                alert.addAction(UIAlertAction(title: "Cancellation", style: .cancel))
                self?.present(alert, animated: true)
                self?.viewModel.errorMessage = nil
            }
        }
    }
}

extension GalleryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCellView", for: indexPath) as? PhotoCellView else {
            return UICollectionViewCell()
        }
        
        let photo = viewModel.photos[indexPath.item]
        let cellViewModel = PhotoCellViewModel(photo: photo)
        cell.configure(with: cellViewModel)
        
        cell.onFavoriteTapped = { [weak self] photo in
            self?.viewModel.toggleFavorite(photo: photo)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = viewModel.photos[indexPath.item]
        onPhotoSelected?(photo, viewModel.photos)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                            viewForSupplementaryElementOfKind kind: String,
                            at indexPath: IndexPath) -> UICollectionReusableView {
            if kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "Footer",
                    for: indexPath
                )
                footer.subviews.forEach { $0.removeFromSuperview() }
                
                activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                footer.addSubview(activityIndicator)
                NSLayoutConstraint.activate([
                    activityIndicator.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
                    activityIndicator.centerYAnchor.constraint(equalTo: footer.centerYAnchor)
                ])
                
                if viewModel.isLoading {
                    activityIndicator.startAnimating()
                } else {
                    activityIndicator.stopAnimating()
                }
                return footer
            }
            return UICollectionReusableView()
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            referenceSizeForFooterInSection section: Int) -> CGSize {
            return viewModel.isLoading ? CGSize(width: collectionView.bounds.width, height: 50) : .zero
        }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        if offsetY > contentHeight - frameHeight - 100 {
            Task {
                await viewModel.loadMorePhotos()
            }
        }
    }
}
