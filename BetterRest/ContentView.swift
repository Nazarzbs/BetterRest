//
//  ContentView.swift
//  BetterRest
//
//  Created by Nazar on 20.01.2024.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
       
            NavigationStack {
                    
                Form {
                    
                    Section(header: Text("When do you want to wake up?").font(.headline)) {
                        HStack {
                            Image(systemName: "bed.double")
                            DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }
    
                    Section(header: Text("Desired amount of sleep").font(.headline)) {
                        HStack {
                            Image(systemName: "clock")
                            Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        }
                    }
                    
                    
                    Section(header: Text("Daily coffee intake")) {
                        HStack {
                            Image(systemName: "cup.and.saucer")
                        Picker("Number of cups", selection: $coffeeAmount) {
                            ForEach(0...20, id: \.self) { cups in
                                Text("  \(cups) cup").tag(cups)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Recommended bedtime")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                    ) {
                        Text(calculateBedTime)
                            .font(.system(size: 96, design: .monospaced)) // use a system font with a size of 36 and a rounded design
                            .frame(maxWidth: .infinity, alignment: .center) // add this line
                            .bold()
                    }
                    
                    
                }
                .background(Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [        Color(cgColor: CGColor(red: 0, green: 0.198, blue: 0.375, alpha: 1)),
                                Color(cgColor: CGColor(red: 0.8, green: 0.6, blue: 0.55, alpha: 0.8)),
                               
                                Color(cgColor: CGColor(red: 0.05, green: 0.3, blue: 0.4, alpha: 0.1)),
                                ]),
                            center: .center,
                            startRadius: 100,
                            endRadius: 1200
                        )
                    )
                    .frame(width: 3000, height: 3000)
                    .position(CGPoint(x: -100, y: 750)))
                
                .scrollContentBackground(.hidden)
                .navigationTitle("BetterRest 😴 ")
                
                Image(systemName: "moon.stars")
                    .font(.system(size: 130))
                    .symbolEffect(.pulse.wholeSymbol)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.yellow, .white)
                
                    
                    
            }
    }

    var calculateBedTime: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            // Int64?
            let prediction = try model.prediction(wake: Int64(Double(hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(Double(coffeeAmount)))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
           
            return "Sorry, there was a problem calculating your bedtime."
        }
    }
}

#Preview {
    ContentView()
}
