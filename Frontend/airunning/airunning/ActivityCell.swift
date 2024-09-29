//
//  ActivityCell.swift
//  airunning
//
//  Created by Niam Bashambu on 9/28/24.
//

import SwiftUI

// MARK: - ActivityCell

struct ActivityCell: View {
    let activity: Activity

    var body: some View {
        VStack(alignment: .leading) {
            Text(activity.name)
                .font(.headline)
            Text("Distance: \(activity.distance) meters")
            Text("Average Speed: \(activity.average_speed) m/s")
        }
        .padding()
    }
}
