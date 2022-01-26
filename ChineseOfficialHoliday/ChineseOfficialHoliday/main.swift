//
//  main.swift
//  ChineseOfficialHoliday
//
//  Created by Darren Dai on 2022/1/25.
//

import Foundation

class CalendarDay {
    var name = ""
    var beginDate = ""
    var endDate = ""
    init(name: String, beginDate: String, endDate: String) {
        self.name = name
        self.beginDate = beginDate
        self.endDate = endDate
    }
}


let workdayColor = "#B38C6C"
let holidayColor = "#00D360"
let holidays = [
    CalendarDay(name: "元旦", beginDate: "20220101", endDate: "20220103"),
    CalendarDay(name: "春节", beginDate: "20220131", endDate: "20220206"),
    CalendarDay(name: "清明节", beginDate: "20220403", endDate: "20220405"),
    CalendarDay(name: "劳动节", beginDate: "20220430", endDate: "20220504"),
    CalendarDay(name: "端午节", beginDate: "20220603", endDate: "20220605"),
    CalendarDay(name: "中秋节", beginDate: "20220910", endDate: "20220912"),
    CalendarDay(name: "国庆节", beginDate: "20221001", endDate: "20221007")
]
let workdays = [
    CalendarDay(name: "上班", beginDate: "20220129", endDate: "20220130"),
    CalendarDay(name: "上班", beginDate: "20220402", endDate: "20220402"),
    CalendarDay(name: "上班", beginDate: "20220424", endDate: "20220424"),
    CalendarDay(name: "上班", beginDate: "20220507", endDate: "20220507"),
    CalendarDay(name: "上班", beginDate: "20221008", endDate: "20221009")
]


prepareData()

let holidayResult = generateICSString(holidays)
let workdayResult = generateICSString(workdays)
let allResult = generateICSString(holidays + workdays)

writeTextToFile("holiday.ics", holidayResult)
writeTextToFile("workday.ics", workdayResult)
writeTextToFile("all.ics", allResult)


func prepareData() -> Void {
    for holiday in holidays {
        holiday.name += "放假"
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    for calendarDay in holidays + workdays {
        var date = formatter.date(from: calendarDay.endDate)!
        date.addTimeInterval(24 * 60 * 60)
        let dateString = formatter.string(from: date)
        print(dateString)
        calendarDay.endDate = dateString
    }
}


func generate(_ calendarDay: CalendarDay, _ index: Int) -> String {
    var result = "BEGIN:VEVENT\n"
    let uid = "UID:\(calendarDay.beginDate)-\(index)\n"
    let begin = "DTSTART;VALUE=DATE:\(calendarDay.beginDate)\n"
    let end = "DTEND;VALUE=DATE:\(calendarDay.endDate)\n"
    let name = "SUMMARY:\(calendarDay.name)\n"
    let tail = """
    SEQUENCE:0
    BEGIN:VALARM
    TRIGGER;VALUE=DATE-TIME:19760401T005545Z
    ACTION:NONE
    END:VALARM
    END:VEVENT\n
    """
    result += uid + begin + end + name + tail
    return result
}


func generateICSString(_ calendarDays: Array<CalendarDay>) -> String {
    var title = "法定节假日", color = holidayColor
    if calendarDays[0].name.elementsEqual("上班") {
        title = "调休上班日期"
        color = workdayColor
    }
    var result = """
    BEGIN:VCALENDAR
    VERSION:2.0
    X-WR-CALNAME:\(title)
    X-APPLE-CALENDAR-COLOR:\(color)
    X-WR-TIMEZONE:Asia/Shanghai\n
    """
    for (index, calendarDay) in calendarDays.enumerated() {
        result += generate(calendarDay, index)
    }
    result += "END:VCALENDAR"
    return result
}


func writeTextToFile(_ fileName: String, _ result: String) -> Void {
    let homeDirURL = FileManager.default.homeDirectoryForCurrentUser
    var filePath = "\(homeDirURL)Desktop/\(fileName)"
    filePath.removeSubrange(filePath.startIndex...filePath.index(filePath.startIndex, offsetBy: 6))
    print(filePath)
    do {
        try result.write(toFile: filePath, atomically: true, encoding: .utf8)
    } catch {
        print(error)
    }
}
