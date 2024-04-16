//
//  HomeViewModel.swift
//  NC1-TIL
//
//  Created by 이정동 on 4/13/24.
//

import Foundation

@Observable
class HomeViewModel {
    var monthlys: [Monthly] = []
    var isLoading: Bool = false
    var totalContributions: Int = 0
    
    /// 모든 Link 데이터를 가져옴
    func fetchAllLink() {
        isLoading = true
        
        CloudService.shared.fetchLinks { result in
            switch result {
            case .success(let links):
                self.createMonthlys(links)
                self.totalContributions = links.count
            case .failure(let error):
                print(error)
            }
            
            self.isLoading = false
        }
    }
    
    
    /// 특정 Link 데이터 삭제
    /// - Parameter link: 삭제할 Link 데이터
    func deleteLink(_ link: URLLink) {
        isLoading = true
        
        CloudService.shared.deleteLink(link.recordID) { result in
            switch result {
            case .success:
                self.fetchAllLink()
            case .failure(let failure):
                print(failure.localizedDescription)
                self.isLoading = false
            }
        }
    }
    
    /// Link 데이터로 Monthlys 데이터를 만듦
    /// - Parameter links: [Link] 데이터
    func createMonthlys(_ links: [URLLink]) {
        
        let dic = groupedLink(links)
        let sortedDic = dic.sorted { $0.key < $1.key }
        
        var newMonthlys: [Monthly] = []
        
        for (key, value) in sortedDic {
            let days = self.assignLinkToDays(days: key.daysInMonth(), links: value)
            newMonthlys.append(Monthly(date: key, days: days, links: value))
        }
        
        monthlys = newMonthlys
    }
    
    /// Link 데이터를 Date별로 그룹화
    /// - Parameter links: [Link] 데이터
    /// - Returns: [Date: [Link]]
    func groupedLink(_ links: [URLLink]) -> [Date: [URLLink]] {
        var dic: [Date: [URLLink]] = [:]
        for link in links {
            let date = link.date.convertYearAndMonthDate()
            if dic[date] == nil {
                dic[date] = [link]
            } else {
                dic[date]?.append(link)
            }
        }
        return dic
    }
    
    /// 일수만큼 배열을 만들고 각 일수마다 Link가 얼마나 등록됐는지 카운트
    /// - Parameters:
    ///   - days: 총 일수
    ///   - links: [URLLink] 데이터
    /// - Returns: 일수
    func assignLinkToDays(days: Int, links: [URLLink]) -> [Int] {
        var array = Array(repeating: 0, count: days)
        
        for link in links {
            array[link.date.currentDay()-1] += 1
        }
        
        return array
    }
}
