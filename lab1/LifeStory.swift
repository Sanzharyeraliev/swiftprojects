// Step 1: Personal info
let firstName: String = "Санжар"
let lastName: String = "Ералы"
let birthYear: Int = 2005
let currentYear: Int = 2026
let age: Int = currentYear - birthYear          
let isStudent: Bool = true
let height: Double = 1.83                        
let city: String = "Талгар"

// Step 2: Hobbies and interests
let hobby: String = "футбол ⚽"
let numberOfHobbies: Int = 3                     
let favoriteNumber: Int = 10
let isHobbyCreative: Bool = false                
let favoriteMusicGenre: String = "музыка 🎵"     
let hobby2: String = "баскетбол 🏀"
let hobby3: String = "музыка 🎵"

// Bonus
let futureGoals: String = "стать успешным"

// Step 3: Summary via string interpolation
let studentText = isStudent ? "Я сейчас учусь." : "Я не учусь."
let creativeText = isHobbyCreative ? "это творческое хобби" : "это не творческое хобби"

let lifeStory: String = """
Меня зовут \(firstName) \(lastName). Мне \(age) лет, я родился в \(birthYear) году. \
\(studentText) Мой рост — \(height) м, я живу в городе \(city). \
Моё любимое хобби — \(hobby), и \(creativeText). \
Ещё я увлекаюсь \(hobby2) и \(hobby3). \
Всего у меня \(numberOfHobbies) хобби, а моё любимое число — \(favoriteNumber). \
В будущем я хочу \(futureGoals).
"""

// Step 4: Print
print(lifeStory)
