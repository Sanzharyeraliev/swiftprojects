import UIKit

struct FavoriteMedia {
    let imageName: String
    let title: String
    let subtitle: String
    let description: String
    let rating: Int
}

class FavoriteMediaCell: UITableViewCell {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func setup(with item: FavoriteMedia) {
        itemImage.image = UIImage(named: item.imageName)
        nameLabel.text = item.title
    }
}
