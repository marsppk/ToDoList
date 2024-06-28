//
//  ColorPicker.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 25.06.2024.
//

import SwiftUI

struct ColorPickerView: View {
    @Binding var chosenColor: Color
    @State private var isDragging: Bool = false
    @State private var startLocation: CGFloat = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var brightness: Double = 1.0
    @State private var colors: [Color] = []
    
    init(chosenColor: Binding<Color>) {
        self._chosenColor = chosenColor
    }
    
    private var circleWidth: CGFloat {
        isDragging ? 35 : 20
    }
    
    private var linearGradientWidth: CGFloat = 280
    
    private var currentColor: Color {
        Color(UIColor.init(hue: self.normalizeGesture() / linearGradientWidth, saturation: 1.0, brightness: brightness, alpha: 1.0))
    }
    
    private func normalizeGesture() -> CGFloat {
        let offset = startLocation + dragOffset.width
        let maxX = max(0, offset)
        let minX = min(maxX, linearGradientWidth)
        return minX
    }
    
    private func setupColors() {
        let hueValues = Array(0...359)
        colors = hueValues.map {
            Color(
                UIColor(
                    hue: CGFloat($0) / 359.0,
                    saturation: 1.0,
                    brightness: brightness,
                    alpha: 1.0
                )
            )
        }
    }
    
    var circleColorPicker: some View {
        Circle()
            .foregroundColor(currentColor)
            .frame(width: circleWidth, height: circleWidth, alignment: .center)
            .shadow(radius: 5)
            .overlay(
                RoundedRectangle(cornerRadius: circleWidth / 2.0).stroke(Color.white, lineWidth: 2.0)
            )
            .offset(x: normalizeGesture() - circleWidth / 2, y: 0.0)
    }
    
    var slider: some View {
        Slider(value: $brightness, in: 0...1, step: 0.01)
            .padding()
            .onChange(of: brightness) { newBrightness, _ in
                withAnimation(Animation.spring().speed(2)) {
                    setupColors()
                    chosenColor = currentColor
                }
            }
    }
    
    var gradient: some View {
        LinearGradient(gradient: Gradient(colors: colors),
                       startPoint: .leading,
                       endPoint: .trailing)
        .cornerRadius(5)
        .shadow(radius: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 2.0)
        )
        .frame(height: 60)
        .gesture(
            DragGesture()
                .onChanged({ (value) in
                    withAnimation(Animation.spring().speed(2)) {
                        dragOffset = value.translation
                        startLocation = value.startLocation.x
                        chosenColor = currentColor
                        isDragging = true
                    }
                })
                .onEnded({ (_) in
                    isDragging = false
                })
        )
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .leading) {
                gradient
                circleColorPicker
            }
            slider
        }
        .frame(width: linearGradientWidth)
        .padding()
        .onAppear() {
            setupColors()
        }
    }
}
