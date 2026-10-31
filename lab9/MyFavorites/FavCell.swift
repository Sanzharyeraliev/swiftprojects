import UIKit

struct FavItem {
    let imageName: String
    let title: String
    let subtitle: String
    let description: String
    let rating: Int
}

class FavCell: UITableViewCell {
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemType: UILabel!
    @IBOutlet weak var itemDescription: UILabel!
    
    // 5 отдельных связей для звездочек
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    
    func configure(with item: FavItem) {
        itemName.text = item.title
        itemType.text = item.subtitle
        itemDescription.text = item.description
        itemImage.image = UIImage(named: item.imageName)
        
        // Собираем все звезды в один массив прямо здесь, в коде
        let allStars = [star1, star2, star3, star4, star5]
        
        for (index, star) in allStars.enumerated() {
            // index идет от 0 до 4. А рейтинг от 1 до 5.
            // Поэтому если index (0) < rating (4), то звезда желтая.
            if index < item.rating {
                star?.image = UIImage(systemName: "star.fill")
                star?.tintColor = .systemYellow
            } else {
                star?.image = UIImage(systemName: "star")
                star?.tintColor = .systemGray4
            }
        }
    }
}
