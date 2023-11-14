import SwiftUI
import Alamofire

struct ContentView: View {
    @State private var showingAlert = false
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    var body: some View {
        Button("오늘의 급식 가져오기") {
            self.showingAlert.toggle()
            
            let currentDate = Date()
            let dateString = dateFormatter.string(from: currentDate)
            let currentTime = Calendar.current.component(.hour, from: currentDate) * 100 + Calendar.current.component(.minute, from: currentDate)
            
            var mealType = ""
            var mealTitle = ""
            
            if currentTime <= 830 {
                mealType = "breakfast"
                mealTitle = "아침 급식"
            } else if currentTime <= 1310 {
                mealType = "lunch"
                mealTitle = "점심 급식"
            } else {
                mealType = "dinner"
                mealTitle = "저녁 급식"
            }
            
            let url = "https://let.team-alt.com/api/openapi/meal?date=\(dateString)"
            
            AF.request(url).responseJSON { response in
                if let data = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let mealData = try decoder.decode(MealResponse.self, from: data)
                        
                        var selectedMeal: MealInfo?
                        
                        switch mealType {
                        case "breakfast":
                            selectedMeal = mealData.data.breakfast
                        case "lunch":
                            selectedMeal = mealData.data.lunch
                        case "dinner":
                            selectedMeal = mealData.data.dinner
                        default:
                            break
                        }
                        
                        if let selectedMeal = selectedMeal {
                            let mealString = "\(mealTitle)\n\n \(selectedMeal.menu.joined(separator: ", "))"
                            
                            UIPasteboard.general.string = mealString
                            
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "급식 정보", message: mealString, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MealResponse: Codable {
    let status: Int
    let data: MealData
}

struct MealData: Codable {
    let exists: Bool
    let breakfast: MealInfo
    let lunch: MealInfo
    let dinner: MealInfo
}

struct MealInfo: Codable {
    let menu: [String]
    let calorie: String
    let carbohydrates: String
    let protein: String
    let fat: String
    let mealType: String
}
