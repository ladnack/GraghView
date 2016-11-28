//
//  GraghView.swift
//  GraghView
//
//  Created by 酒井恭平 on 2016/11/27.
//  Copyright © 2016年 酒井恭平. All rights reserved.
//

import UIKit

// MARK: - Enumeration

enum GraghStyle: Int {
    case bar, round
}

enum GraghViewDateStyle: Int {
    case year, month, day
}


// MARK: - GraghView Class

class GraghView: UIScrollView {
    
    // MARK: - Private properties
    
    // データの中の最大値 -> これをもとにBar表示領域の高さを決める
    var maxGraghValue: CGFloat? { return graghValues.max() }
    
    // MARK: Setting ComparisonValue
    private let comparisonValueLabel = UILabel()
    private let comparisonValueLineView = UIView()
    private let comparisonValueX: CGFloat = 0
    private var comparisonValueY: CGFloat?
    
    // MARK: - Public properties
    
    // データ配列
    var graghValues: [CGFloat] = []
    // グラフのラベルに表示する情報
    var minimumDate: Date?
    
    var graghStyle: GraghStyle = .bar
    
    // labelに表示するDate間隔
    var dateStyle: GraghViewDateStyle = .month
    
    // MARK: Setting ComparisonValue
    
    @IBInspectable var comparisonValue: CGFloat = 100000
    
    @IBInspectable var comparisonValueIsHidden: Bool = false {
        didSet {
            comparisonValueLabel.isHidden = comparisonValueIsHidden
            comparisonValueLineView.isHidden = comparisonValueIsHidden
        }
    }
    
    // Delegate
    //    var barDelegate: BarGraghViewDelegate?
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, graghValues: [CGFloat], minimumDate: Date, style: GraghStyle = .bar) {
        self.init(frame: frame)
        self.graghValues = graghValues
        self.minimumDate = minimumDate
        self.graghStyle = style
        loadGraghView()
    }
    
    // storyboardで生成する時
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - Override
    
    override var contentOffset: CGPoint {
        didSet {
            if !comparisonValueIsHidden {
                // ComparisonValueLabelをスクロールとともに追従させる
                comparisonValueLabel.frame.origin.x = contentOffset.x
            }
        }
    }
    
    
    // MARK: - Private methods
    
    private func dateToMinimumDate(addComponentValue index: Int) -> DateComponents {
        switch dateStyle {
        case .year: return DateComponents(year: index)
        case .month: return DateComponents(month: index)
        case .day: return DateComponents(day: index)
        }
    }
    
    // MARK: Drawing
    
    private func drawComparisonValue() {
        guard let comparisonValueY = comparisonValueY else {
            return
        }
        
        drawComparisonValueLine(from: CGPoint(x: comparisonValueX, y: comparisonValueY), to: CGPoint(x: contentSize.width, y: comparisonValueY))
        
        drawComparisonValueLabel(frame: CGRect(x: comparisonValueX, y: comparisonValueY, width: 50, height: 20), text: String(describing: comparisonValue))
    }
    
    private func drawComparisonValueLine(from statPoint: CGPoint, to endPoint: CGPoint) {
        // GraghViewと同じ大きさのViewを用意
        comparisonValueLineView.frame = CGRect(origin: .zero, size: contentSize)
        comparisonValueLineView.backgroundColor = UIColor.clear
        // Lineを描画
        UIGraphicsBeginImageContextWithOptions(contentSize, false, 0)
        let linePath = UIBezierPath()
        linePath.lineCapStyle = .round
        linePath.move(to: statPoint)
        linePath.addLine(to: endPoint)
        linePath.lineWidth = GraghLayoutData.lineWidth
        GraghLayoutData.lineColor.setStroke()
        linePath.stroke()
        comparisonValueLineView.layer.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
        // GraghViewに重ねる
        addSubview(comparisonValueLineView)
    }
    
    private func drawComparisonValueLabel(frame: CGRect, text: String) {
        comparisonValueLabel.frame = frame
        comparisonValueLabel.text = text
        comparisonValueLabel.textAlignment = .center
        comparisonValueLabel.font = comparisonValueLabel.font.withSize(10)
        comparisonValueLabel.backgroundColor = GraghLayoutData.labelBackgroundColor
        addSubview(comparisonValueLabel)
    }
    
    
    // MARK: - Public methods
    
    func loadGraghView() {
        let calendar = Calendar(identifier: .gregorian)
        contentSize.height = frame.height
        
        
        
        for index in 0..<graghValues.count {
            contentSize.width += GraghLayoutData.barAreaWidth
            
            if let minimumDate = minimumDate, let date = calendar.date(byAdding: dateToMinimumDate(addComponentValue: index), to: minimumDate) {
                // barの表示をずらしていく
                let rect = CGRect(origin: CGPoint(x: CGFloat(index) * GraghLayoutData.barAreaWidth, y: 0), size: CGSize(width: GraghLayoutData.barAreaWidth, height: frame.height))
                
                let cell = GraghViewCell(frame: rect, graghValue: graghValues[index], date: date, comparisonValue: comparisonValue, target: self)
                
                addSubview(cell)
                
                self.comparisonValueY = cell.comparisonValueY
            }
        }
        
        drawComparisonValue()
    }
    
    func reloadGraghView() {
        // GraghViewの初期化
        subviews.forEach { $0.removeFromSuperview() }
        contentSize = .zero
        
        loadGraghView()
    }
    
    // MARK: Set Gragh Customize
    
    func setBarArea(width: CGFloat) {
        GraghLayoutData.barAreaWidth = width
    }
    
    func setComparisonValueLabel(backgroundColor: UIColor) {
        GraghLayoutData.labelBackgroundColor = backgroundColor
    }
    
    func setComparisonValueLine(color: UIColor) {
        GraghLayoutData.lineColor = color
    }
    
    // BarのLayoutProportionはGraghViewから変更する
    func setBarAreaHeight(rate: CGFloat) {
        GraghViewCell.LayoutProportion.barAreaHeightRate = rate
    }
    
    func setMaxGraghValue(rate: CGFloat) {
        GraghViewCell.LayoutProportion.maxGraghValueRate = rate
    }
    
    func setBarWidth(rate: CGFloat) {
        GraghViewCell.LayoutProportion.barWidthRate = rate
    }
    
    func setBar(color: UIColor) {
        GraghViewCell.LayoutProportion.barColor = color
    }
    
    func setLabel(backgroundcolor: UIColor) {
        GraghViewCell.LayoutProportion.labelBackgroundColor = backgroundcolor
    }
    
    func setGragh(backgroundcolor: UIColor) {
        GraghViewCell.LayoutProportion.GraghBackgroundColor = backgroundcolor
    }
    
    func setRound(size: CGFloat) {
        GraghViewCell.LayoutProportion.roundSize = size
    }
    
    func setRound(color: UIColor) {
        GraghViewCell.LayoutProportion.roundColor = color
    }
    
    
    // MARK: - Struct
    
    private struct GraghLayoutData {
        // 生成するBar領域の幅
        static var barAreaWidth: CGFloat = 50
        static var labelBackgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        static var lineColor = UIColor.red
        static var lineWidth: CGFloat = 2
        
    }
    
}