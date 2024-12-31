//
//  File.swift
//  
//
//  Created by 정연호 on 10/29/24.
//

import Foundation
import Combine
import DGCharts

class LineChartViewModel {
    // Combine
    @Published var networkResponse: NetworkResponse?
    @Published var chartModel: LineChartModel?
    @Published var displayDate: String?
    @Published var initValue: Void?
    @Published var loading: Bool = false
    
    // DI
    private let repository: LineChartRepository
    
    init (repository: LineChartRepository) {
        self.repository = repository
    }
    
    
    func updateChartData() {
        displayDate = repository.getDisplayDate()
        
        initValue = ()
        
        Task {
            loading = true
            
            let (chartModel, response) = await repository.getLineChartGropData()
            
            switch response {
            case .success:
                // update model
                if let chartModel {
                    self.chartModel = chartModel
                } else {
                    networkResponse = .noData
                }
            default:
                networkResponse = response
            }
            
            loading = false
        }
    }
    
    
    // Update Data
    func refresh(type: LineChartType) {
        repository.refreshData(type)
        
        updateChartData()
    }
    
    func moveDate(nextDate: Bool) {
        repository.updateTargetDate(nextDate)
        
        updateChartData()
    }
    
    func moveDate(moveDate: Date) {
        repository.updateTargetDate(moveDate)
        
        updateChartData()
    }
    
    func updateChartType(_ updateType: LineChartType) {
        repository.updateChartType(type: updateType)
        
        updateChartData()
    }
    
    func updateDateType(_ updateType: LineChartDateType) {
        repository.updateChartDateType(type: updateType)
        
        updateChartData()
    }
    
}
