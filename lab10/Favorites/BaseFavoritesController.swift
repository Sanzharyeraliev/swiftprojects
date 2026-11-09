import UIKit

class BaseFavoritesController: UITableViewController {
    
    var mediaList: [FavoriteMedia] = []
    private let reuseIdentifier = "FavoriteMediaCell"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? FavoriteMediaCell else {
            return UITableViewCell()
        }
        let media = mediaList[indexPath.row]
        cell.setup(with: media)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // Убираем ручной вызов performSegue, чтобы не было двойного перехода!
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Передаем данные перед переходом
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            // Находим выбранную строку
            if let indexPath = tableView.indexPathForSelectedRow {
                let media = mediaList[indexPath.row]
                // Передаем данные на экран деталей
                if let detailVC = segue.destination as? MediaDetailViewController {
                    detailVC.mediaItem = media
                }
            }
        }
    }
}
