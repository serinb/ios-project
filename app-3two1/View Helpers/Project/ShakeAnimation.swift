//
//  ShakeAnimation.swift
//  app-3two1
//
//  Created by Aleksandra Kukawka on 28/01/2024.
//

import SwiftUI

/** LOGIC FOR SHAKE ANIMATION FEEDBACK **/

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
