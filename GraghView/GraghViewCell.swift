//
//  GraghViewCell.swift
//  GraghView
//
//  Created by 酒井恭平 on 2016/11/27.
//  Copyright © 2016年 酒井恭平. All rights reserved.
//

import UIKit

// MARK: - GraghViewCell Class

class GraghViewCell: UIView {
    // MARK: - Pablic properties
    
    var endPoint: CGPoint? {
        guard let toY = toY else { return nil }
        return CGPoint(x: x, y: toY)
    }
    
    var comparisonValueY: CGFloat? {
        guard let comparisonValueHeight = comparisonValueHeight, let y = y else { return nil }
        return y - comparisonValueHeight
    }
    
    // MARK: - Private properties
    
    // MARK: Shared
    
    private var graghView: GraghView?
    private var style: GraghStyle?
    private var dateStyle: GraghViewDateStyle?
    private var dataType: GraghViewDataType?
    
    private let cellLayout: GraghView.GraghViewCellLayoutOptions?
    
    private var graghValue: CGFloat
    private var maxGraghValue: CGFloat? { return graghView?.maxGraghValue }
    
    private var date: Date?
    private var comparisonValue: CGFloat?
    
    private var maxBarAreaHeight: CGFloat? {
        guard let maxGraghValue = maxGraghValue, let cellLayout = cellLayout else { return nil }
        return maxGraghValue / cellLayout.maxGraghValueRate
    }
    
    private var barAreaHeight: CGFloat? {
        guard let cellLayout = cellLayout else { return nil }
        return frame.height * cellLayout.barAreaHeightRate
    }
    
    private var barHeigth: CGFloat? {
        guard let maxBarAreaHeight = maxBarAreaHeight, let barAreaHeight = barAreaHeight else { return nil }
        return barAreaHeight * graghValue / maxBarAreaHeight
    }
    
    // barの終点のY座標・roundのposition
    private var toY: CGFloat? {
        guard let barHeigth = barHeigth, let y = y else { return nil }
        return y - barHeigth
    }
    
    private var labelHeight: CGFloat? {
        guard let barAreaHeight = barAreaHeight else { return nil }
        return (frame.height - barAreaHeight) / 2 }
    
    private var comparisonValueHeight: CGFloat? {
        guard let maxBarAreaHeight = maxBarAreaHeight, let comparisonValue = comparisonValue, let barAreaHeight = barAreaHeight else { return nil }
        return barAreaHeight * comparisonValue / maxBarAreaHeight
    }
    
    // MARK: Only Bar
    
    private var barWidth: CGFloat? {
        guard let cellLayout = cellLayout else { return nil }
        return frame.width * cellLayout.barWidthRate
    }
    
    // barの始点のX座標（＝終点のX座標）
    private var x: CGFloat { return frame.width / 2 }
    // barの始点のY座標（上下に文字列表示用の余白がある）
    private var y: CGFloat? {
        guard let barAreaHeight = barAreaHeight else { return nil }
        return barAreaHeight + (frame.height - barAreaHeight) / 2
    }
    
    // MARK: Only Round
    
    private var roundSize: CGFloat? {
        guard let roundSizeRate = cellLayout?.roundSizeRate else { return nil }
        return roundSizeRate * frame.width
    }
    
    // MARK: - Initializers
    
    init(frame: CGRect, graghValue: CGFloat, date: Date, comparisonValue: CGFloat, target graghView: GraghView? = nil) {
        self.graghView = graghView
        self.style = graghView?.graghStyle
        self.dateStyle = graghView?.dateStyle
        self.dataType = graghView?.dataType
        self.cellLayout = graghView?.cellLayout
        
        self.graghValue = graghValue
        self.date = date
        self.comparisonValue = comparisonValue
        
        super.init(frame: frame)
        self.backgroundColor = cellLayout?.GraghBackgroundColor
        self.graghView?.graghViewCells.append(self)
    }
    
    // storyboardで生成する時
    required init?(coder aDecoder: NSCoder) {
        self.graghValue = 0
        self.cellLayout = nil
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Override
    
    override func draw(_ rect: CGRect) {
        guard let style = style else { return }
        
        if let y = y, let endPoint = endPoint {
            // Graghを描画
            switch style {
            case .bar: drawBar(from: CGPoint(x: x, y: y), to: endPoint)
            case .round:
                if let cellLayout = cellLayout, !cellLayout.onlyPathLine {
                    drawRound(point: endPoint)}
            }
        }
        
        if let labelHeight = labelHeight {
            // over labelを表示
            drawLabel(centerX: x, centerY: labelHeight / 2, width: rect.width, height: labelHeight, text: overTextFormatter(from: graghValue))
            
            if let date = date {
                // under labelを表示
                drawLabel(centerX: x, centerY: rect.height - labelHeight / 2, width: rect.width, height: labelHeight, text: underTextFormatter(from: date))
            }
            
        }
        
    }
    
    
    // MARK: - Private methods
    
    // MARK: Under Label's text format
    private func underTextFormatter(from date: Date) -> String {
        guard let dateStyle = dateStyle else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        
        switch dateStyle {
        case .year: dateFormatter.dateFormat = "yyyy"
        case .month: dateFormatter.dateFormat = "yyyy/MM"
        case .day: dateFormatter.dateFormat = "MM/dd"
        }
        
        return dateFormatter.string(from: date)
    }
    
    // MARK: Over Label's text format
    private func overTextFormatter(from value: CGFloat) -> String {
        guard let dataType = dataType else {
            return ""
        }
        
        switch dataType {
        case .normal: return String("\(value)")
        case .yen: return String("\(Int(value)) 円")
        }
        
    }
    
    // MARK: Drawing
    
    private func drawBar(from startPoint: CGPoint, to endPoint: CGPoint) {
        let BarPath = UIBezierPath()
        BarPath.move(to: startPoint)
        BarPath.addLine(to: endPoint)
        BarPath.lineWidth = barWidth ?? 0
        cellLayout?.barColor.setStroke()
        BarPath.stroke()
    }
    
    private func drawRound(point: CGPoint) {
        guard let cellLayout = cellLayout, let roundSize = roundSize else { return }
        
        let origin = CGPoint(x: point.x - roundSize / 2, y: point.y - roundSize / 2)
        let size = CGSize(width: roundSize, height: roundSize)
        let round = UIBezierPath(ovalIn: CGRect(origin: origin, size: size))
        cellLayout.roundColor.setFill()
        round.fill()
    }
    
    private func drawLabel(centerX x: CGFloat, centerY y: CGFloat, width: CGFloat, height: CGFloat, text: String) {
        let label: UILabel = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: width, height: height)
        label.center = CGPoint(x: x, y: y)
        label.text = text
        label.textAlignment = .center
        label.font = label.font.withSize(10)
        label.backgroundColor = cellLayout?.labelBackgroundColor
        addSubview(label)
    }
    
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
