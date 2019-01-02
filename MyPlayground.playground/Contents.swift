import UIKit
import Foundation

let tod = Date()
Calendar.current.dateComponents(Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year]), from: tod, to: tod + 60000)
