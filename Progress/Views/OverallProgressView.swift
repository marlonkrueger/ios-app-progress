//
//  OverallProgressView.swift
//  Progress
//
//  Created by mkrueger on 20.01.25.
//

import SwiftUI

// Overall progress bar in ContentView
struct OverallProgressView: View {
    let progress: Double
    @EnvironmentObject var colorManager: ColorManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Overall Progress")
                    .font(.headline)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.headline)
            }
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
                .background(colorManager.progressBGColor)
                .accentColor(colorManager.progressColor)
                .frame(height: 10)
                .cornerRadius(5)
                .scaleEffect(y: progress == 1.0 ? 1.2 : 1.0)
                .brightness(progress == 1.0 ? 0.1 : 0)
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}


#Preview {
    OverallProgressView(progress: 0.5)
}
