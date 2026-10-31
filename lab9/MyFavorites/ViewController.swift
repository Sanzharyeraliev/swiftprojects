import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        data = [favMovies, favBooks]
    }
    
    var data: [[FavItem]] = []
    let sectionTitles = ["Movies & Series", "Books"]
    
    let favMovies: [FavItem] = [
        FavItem(imageName: "Fury", title: "Ярость", subtitle: "Боевик, Драма, 2014", description: "Майор Армии США и его экипаж танка «Шерман» отправляются на опасную миссию в самом конце Второй мировой войны.", rating: 5),
        FavItem(imageName: "FightClub", title: "Бойцовский клуб", subtitle: "Триллер, Драма, 1999", description: "Офисный работник и мыловар создают подпольный бойцовский клуб, который перерастает в нечто гораздо большее.", rating: 5),
        FavItem(imageName: "Rocky4", title: "Рокки 4", subtitle: "Спорт, Драма, 1985", description: "Рокки Бальбоа должен выйти на ринг против советского боксера Ивана Драго, чтобы отомстить за смерть друга.", rating: 4),
        FavItem(imageName: "TheBoys", title: "Пацаны", subtitle: "Сериал, Боевик, 2019", description: "Отряд обычных людей мстит коррумпированным супергероям, которые злоупотребляют своей силой.", rating: 5),
        FavItem(imageName: "GameOfThrones", title: "Игра престолов", subtitle: "Сериал, Фэнтези, 2011", description: "Девять знатных домов сражаются за контроль над Вестеросом, в то время как древнее зло пробуждается за Стеной.", rating: 5),
        FavItem(imageName: "Vikings", title: "Викинги", subtitle: "Сериал, История, 2013", description: "Приключения Рагнара Лодброка, фермера, который стремится к новым открытиям и завоеваниям.", rating: 4),
        FavItem(imageName: "BreakingBad", title: "Во все тяжкие", subtitle: "Сериал, Криминал, 2008", description: "Школьный учитель химии, узнав о смертельном диагнозе, начинает производить метамфетамин, чтобы обеспечить семью.", rating: 5),
        FavItem(imageName: "Gladiator", title: "Гладиатор", subtitle: "Боевик, Драма, 2000", description: "Римский генерал предан императором и продан в рабство. Теперь он должен сражаться на арене как гладиатор, чтобы отомстить.", rating: 5),
        FavItem(imageName: "Joker", title: "Джокер", subtitle: "Триллер, Драма, 2019", description: "Неудачливый комик в Готэме с Хоакином Фениксом в главной роли погружается в безумие и становится опасным преступником.", rating: 4),
        FavItem(imageName: "JohnWick", title: "Джон Уик", subtitle: "Боевик, Триллер, 2014", description: "Бывший наемный убийца возвращается к своей профессии, чтобы отомстить за смерть любимой собаки.", rating: 5)
    ]
        
    let favBooks: [FavItem] = [
        FavItem(imageName: "1984", title: "1984", subtitle: "Джордж Оруэлл", description: "Антиутопия о мире тотального надзора, где Большой Брат следит за каждым шагом граждан.", rating: 5),
        FavItem(imageName: "AnimalFarm", title: "Скотный двор", subtitle: "Джордж Оруэлл", description: "Сатирическая повесть о животных, которые захватывают ферму, но сталкиваются с предательством своих идеалов.", rating: 5),
        FavItem(imageName: "MysteriousIsland", title: "Таинственный остров", subtitle: "Жюль Верн", description: "Пятеро американцев спасаются из плена на воздушном шаре и оказываются на необитаемом острове.", rating: 4),
        FavItem(imageName: "BookOfFiveRings", title: "Книга пяти колец", subtitle: "Миямото Мусаси", description: "Классический трактат о стратегии и тактике ведения боя от легендарного японского фехтовальщика.", rating: 5),
        FavItem(imageName: "DoctorSleep", title: "Доктор Сон", subtitle: "Стивен Кинг", description: "Продолжение «Сияния», в котором выросший Дэнни Торранс использует свой дар, чтобы помогать другим.", rating: 4),
        FavItem(imageName: "TheShining", title: "Сияние", subtitle: "Стивен Кинг", description: "Семья становится смотрителями отеля «Оверлук», который скрывает в себе древнее зло, сводящее с ума.", rating: 5),
        FavItem(imageName: "BloodSweatPixels", title: "Кровь, пот и пиксели", subtitle: "Джейсон Шрейер", description: "Книга о закулисье создания популярных видеоигр, полная увлекательных и порой шокирующих историй.", rating: 4),
        FavItem(imageName: "TheHobbit", title: "Хоббит", subtitle: "Дж. Р. Р. Толкин", description: "Бильбо Бэггинс отправляется в приключение с компанией гномов, чтобы вернуть сокровища дракона Смауга.", rating: 5),
        FavItem(imageName: "Dune", title: "Дюна", subtitle: "Фрэнк Герберт", description: "Научно-фантастический роман о борьбе за контроль над пустынной планетой Арракис и её ценным ресурсом.", rating: 5),
        FavItem(imageName: "Metro2033", title: "Метро 2033", subtitle: "Дмитрий Глуховский", description: "Постапокалиптический роман о выживших в московском метро после ядерной войны.", rating: 4)
    ]
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavCell", for: indexPath) as! FavCell
        let item = data[indexPath.section][indexPath.row]
        
        cell.configure(with: item)
        
        return cell
    }
}
