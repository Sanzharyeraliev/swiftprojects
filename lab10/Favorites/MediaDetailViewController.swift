import UIKit

class MediaDetailViewController: UIViewController {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    // 5 отдельных связей для звезд
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    
    var mediaItem: FavoriteMedia?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populate()
    }

    private func populate() {
        guard let media = mediaItem else { return }
        
        nameLabel.text = media.title
        subtitleLabel.text = media.subtitle
        descLabel.text = media.description
        itemImage.image = UIImage(named: media.imageName)
        
        // Собираем звезды в массив прямо здесь, в коде
        let allStars = [star1, star2, star3, star4, star5]
        
        // Закрашиваем в зависимости от рейтинга
        for (index, star) in allStars.enumerated() {
            if index < media.rating {
                star?.image = UIImage(systemName: "star.fill")
                star?.tintColor = .systemYellow
            } else {
                star?.image = UIImage(systemName: "star")
                star?.tintColor = .systemGray4
            }
        }
    }
}
