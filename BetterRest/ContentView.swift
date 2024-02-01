//
//  ContentView.swift
//  BetterRest
//
//  Created by Djroton Noé SOSSOU on 30/01/2024.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1 
    @State private var alertMessage = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    

    var body: some View {
        NavigationStack{
            Form{
                Section{
                    Text("When do you want to wake up?")
                                .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                }

                Section{
                    Text("Desired amount of sleep")
                        .font(.headline)

                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    
                }
                Section{
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Picker("Cups", selection: $coffeeAmount) {
                        ForEach(0...5, id: \.self) {
                                Text("\($0)")
                            }
                    }.pickerStyle(.segmented)

                }
                
                Section{
                    Text("Your ideal bedtime prediction : ")
                                .font(.headline)
                    Text(alertMessage)
                }
            }.navigationTitle("BetterRest")
                .toolbar {
                                    Button("Calculate", action: calculateBedtime)
                                }
            


        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
        
            let prediction = try model.prediction(wake: Int64(Double(hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(Double(coffeeAmount)))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            print(sleepTime)

        } catch {
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
    }
    
}

#Preview {
    ContentView()
}
