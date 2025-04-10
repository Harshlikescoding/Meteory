//
//  MeteorywidgetBundle.swift
//  Meteorywidget
//
//  Created by Harsh on 2025-04-07.
//

import WidgetKit
import SwiftUI

@main
struct MeteorywidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        CurrentTempWidget()
        AdviceWidget()
        DailyForecastWidget()
    }
}

