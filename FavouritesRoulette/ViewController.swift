import UIKit

struct Favorite {
    let title: String
    let description: String
    let imageName: String
}

class ViewController: UIViewController {


    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private let favorites: [Favorite] = [
        Favorite(title: "Интерстеллар", description: "Космос, время и любовь", imageName: "movie1"),
        Favorite(title: "Начало", description: "Сон внутри сна", imageName: "movie2"),
        Favorite(title: "Матрица", description: "Красная или синяя таблетка", imageName: "movie3"),
        Favorite(title: "Форрест Гамп", description: "Беги, Форрест, беги", imageName: "movie4"),
        Favorite(title: "Побег из Шоушенка", description: "Надежда умирает последней", imageName: "movie5"),
        Favorite(title: "Тёмный рыцарь", description: "Почему такой серьёзный?", imageName: "movie6"),
        Favorite(title: "Криминальное чтиво", description: "Крутые диалоги и чемодан", imageName: "movie7"),
        Favorite(title: "Бойцовский клуб", description: "Первое правило — не говорить о нём", imageName: "movie8"),
        Favorite(title: "Гладиатор", description: "Арена, честь и месть", imageName: "movie9"),
        Favorite(title: "Аватар", description: "Пандора и синие человечки", imageName: "movie10")
    ]

    private var lastIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        showFavorite(at: 0)
    }

    private func showFavorite(at index: Int) {
        let fav = favorites[index]
        favoriteImageView.image = UIImage(named: fav.imageName)
        titleLabel.text = fav.title
        descriptionLabel.text = fav.description
    }

    @IBAction func spinTapped(_ sender: UIButton) {
        var newIndex = Int.random(in: 0..<favorites.count)
        while newIndex == lastIndex {
            newIndex = Int.random(in: 0..<favorites.count)
        }
        lastIndex = newIndex
        showFavorite(at: newIndex)
    }
}
