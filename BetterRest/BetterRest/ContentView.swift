//
//  ContentView.swift
//  BetterRest
//
//  Created by Vinay Kumar Thapa on 2023-01-26.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeIntake = 1
    @State private var idealBedTime = ""
    
    static var defaultWakeTime: Date {
         var components = DateComponents()
         components.hour = 7
         components.minute = 0
         return Calendar.current.date(from: components) ?? Date.now
     }
    
    var body: some View {
      
        NavigationView{
            ZStack{
                
                LinearGradient(colors: [.cyan, .white], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                
                VStack (spacing: 20) {
                    Text("When do you want to wake up?").font(.headline)
                    DatePicker("Please pick a time", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden()
                    
                    Text("Desired amount of sleep required").font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    
                    Text("Daily coffee intake").font(.headline)
                    Stepper(coffeeIntake == 1 ? "1 cup" : "\(coffeeIntake) cups", value: $coffeeIntake, in: 1...20)
                    
                    
                    
                    Button("Calculate") {
                        calculateBedTime()
                    }.buttonStyle(.borderedProminent).tint(.cyan)
                    
                    Text("Your ideal bed time is : \(idealBedTime)").font(.headline)
                    
                    
                    Spacer()
                }.navigationTitle("Better Rest")
            }
        }
    }
    
    func calculateBedTime() {
        do{
            let config = MLModelConfiguration()
            let model = try BetterRestML(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let min = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour+min), estimatedSleep: sleepAmount, coffee: Double(coffeeIntake))

            let sleepTime = wakeUp - prediction.actualSleep
            idealBedTime = sleepTime.formatted(date: .omitted, time: .shortened)
            
        }catch{
            print("There was problem calculating bed time")
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
