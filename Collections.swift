let fruits: [String] = ["яблоко", "банан", "апельсин", "груша", "виноград"]
print("Третий фрукт: \(fruits[2])")

var favoriteNumbers: Set<Int> = [1, 7, 10, 21]
favoriteNumbers.insert(42)
print("Любимые числа: \(favoriteNumbers)")

let languages: [String: Int] = [
    "Swift": 2014,
    "Python": 1991,
    "Java": 1995
]
print("Swift вышел в \(languages["Swift"]!) году")

var colors: [String] = ["красный", "зелёный", "синий", "жёлтый"]
colors[1] = "фиолетовый"
print("Обновлённые цвета: \(colors)")

let setA: Set<Int> = [1, 2, 3, 4]
let setB: Set<Int> = [3, 4, 5, 6]
let intersection = setA.intersection(setB)
print("Пересечение: \(intersection)")

var scores: [String: Int] = [
    "Арсен": 85,
    "Айгерим": 92,
    "Абылай": 78
]
scores["Арсен"] = 95
print("Обновлённые оценки: \(scores)")

let array1: [String] = ["apple", "banana"]
let array2: [String] = ["cherry", "date"]
let merged = array1 + array2
print("Объединённый массив: \(merged)")

var populations: [String: Int] = [
    "Казахстан": 20_000_000,
    "Россия": 144_000_000,
    "Китай": 1_400_000_000
]
populations["США"] = 335_000_000
print("Обновлённые страны: \(populations)")

let pets1: Set<String> = ["cat", "dog"]
let pets2: Set<String> = ["dog", "mouse"]
let unionSet = pets1.union(pets2)
let finalSet = unionSet.subtracting(pets2)
print("Финальный набор: \(finalSet)")

let studentGrades: [String: [Int]] = [
    "Арсен": [5, 4, 5, 3],
    "Айгерим": [4, 5, 5, 4],
    "Абылай": [3, 4, 4, 5]
]
print("Вторая оценка Арсена: \(studentGrades["Арсен"]![1])")