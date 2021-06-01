//
//  BillCurveView.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/5/31.
//

import SwiftUI


struct BillCurveView: View {
    @Binding var data: [Double]
    
    var body: some View {
        return iLineChart(data: data,
                   lineGradient: GradientColor(start: Color(#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)), end: Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1))),
                   chartBackgroundGradient: GradientColor(start: Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)), end: Color(red: 255, green: 255, blue: 255, opacity: 70)),
                   canvasBackgroundColor: Color(#colorLiteral(red: 0.01176470588, green: 0.8078431373, blue: 0.6431372549, alpha: 1)),
                   numberColor: Color.white,
                   displayChartStats: true)
    }
}

struct BillCurveView_Previews: PreviewProvider {
    static var previews: some View {
        BillCurveView(data: .constant([8,23,54,32,12,37,7,23,43]))
    }
}
