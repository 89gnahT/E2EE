//
//  Database+FakeData.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/13/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit



extension Database{
    
    func random() -> Int{
        return Int.random(in: 0...10000)
    }
    
    func randomInt(_ max : Int) -> Int{
        return Int.random(in: 0..<max)
    }
    
    func randomInt(_ min: Int, _ max : Int) -> Int{
        return Int.random(in: min..<max)
    }
    
    func randomMsgTime()->(TimeInterval, TimeInterval, TimeInterval){
        let sent = timeNow - Double(Int.random(in: 0...3600*24*30))
        let deliveried : TimeInterval = sent + Double(Int.random(in: 1...1000))
        var seen : TimeInterval = deliveried + Double(Int.random(in: 1...1000))
        
        if self.random() % 2 == 0{
            seen = MessageTime.TimeInvalidate
        }
        
        return (sent, deliveried, seen)
    }
    
    func randomMuteTime() -> TimeInterval{
        return timeNow + Double(Int.random(in: -10000...10000))
    }
    
    func randomID(length: Int)->String{
        
        enum s {
            static let c = Array("abcdefghjklmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ012345789")
            static let k = UInt32(c.count)
        }
        
        var result = [Character](repeating: "-", count: length)
        
        for i in 0..<length {
            let r = Int(arc4random_uniform(s.k))
            result[i] = s.c[r]
        }
        
        return String(result)
    }
    
    func randomUserID() -> UserID{
        return randomID(length: 16)
    }
    
    func randomMsgID(with userID : UserID) -> String{
        return userID + String(timeNow)
    }
    
    func randomGender() -> Gender{
        let i = Int.random(in: 0...2)
        var gender : Gender
        
        switch i {
        case 0:
            gender = .male
        case 1:
            gender = .female
        default:
            gender = .other
        }
        
        return gender
    }
}
extension Database{
    
    var userName : [String] {
        
        return ["Hồ Ngọc Hà‎",
                "Lệ Quyên",
                "Bảo Anh",
                "Mỹ Tâm‎",
                "Bảo Thy",
                "Bùi Lan Hương",
                "Cindy Thái Tài",
                "Cao Thái Sơn",
                "Châu Gia Kiệt",
                "Đàm Vĩnh Hưng",
                "Duy Mạnh",
                "Dương Triệu Vũ",
                "Phương Thanh",
                "Phương Vy",
                "Quốc Thiên",
                "Trương Thanh Hằng",
                "Trần Siêu",
                "Người Sắt",
                "Caption Marval",
                "Caption America",
                "Black Widow",
                "Loki",
                "Thor",
                "Odin",
                "Natasa",
                "Nick Furi",
                "Triệu Tử Long",
                "Lữ Bố",
                "Triệu Thị Vân",
                "Tôn Ngộ Không",
                "Đường Tăng Tạng",
                "Chư Bát Giới",
                "Mỹ Hầu Vương",
                "Long Vương",
                "Hạo Thiên Khuyển",
                "Siu Black",
                "Sơn Tùng M-TP",
                "Ngân Khánh",
                "Tây Môn Khánh Nam Tiêu Phong",
                "Trần Hồ Như Thuỷ Điện Gió",
                "Linda McCartney",
                "Shirley MacLaine",
                "Laura Prepon SaraConer",
                "Bebe Rexha Scout Taylor-Compton",
                "Maria Quintanilla Keys",
                "Nicole Scherzinger Krystal Jung",
                "Tiffany Thornton",
                "Trish Thùy Trang",
                "Carrie Underwood",
                "Jenna Ushkowitz Teri Moïse",
                "Francisca Valenzuela Grace VanderWaal",]
    }
    
    var avatarURL : [String]{
        return ["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrg_fNLiyMUKhe8KVqfUTxgHy5e8WhaUky3RQxqGaa5X8WK905&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPPLFmeNLOITpYS70BumIDvyRMvCXH33aRGXPJTLOSerawzJiCAg&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDKZXiKQLgVzWUDCIldGbtYtsczoMFHFtAkuOM-fPNQVyR1uhS0w&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRCKO5G5jj5FneTDhTUyviXp8NZFbYZpwkFJQlMaRhsVny6y9_Zvg&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRYO88dxyHln3thD_c70bp01NWh4-euJfgQgDr0dx34xoUd2gP-&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzArRwwKYzc0f692I6Yu-_7b_JzIR0LVADaSlL5kDAUUCRCRARYg&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSExDHgW5rD1qq4SFx7Pgkm3PECSoEeC5fKSDGQD6Q5vbvRrYBbHA&s",
                "https://thichanhdep.com/wp-content/uploads/2019/03/anh-dai-dien-spider-man.jpg",
                "https://static.intercomassets.com/avatars/136502/square_128/Mitchel1-1480463093.jpg?1480463093",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSYtX81y3dkxbGnCFun3MvdonimPInsxFke_4MNexE50vCpLVy6&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRAWbBKH1bR-NSQGkYE8MVm0KT3ROWTcONdOrXzt8UuEy2r-iDi&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQg8TC0RXv6i614LXIscQGewzO3rKQPNDw70WMOlrqBEilN1VCp&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQUOEnFC5N333EtBAOrhelsH6MGiEKLQkoucTZVP2PQ9dpHfTpN0Q&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT0_Y-ASShOnYjwa_l_1VQEgTB8PXlTWllqvhMa8Lus5QaxsZOi&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQIid37wyUyJLYxnL4ucpRuzo6vAFSG43RM8CFfz9mYaSFvzYQYtw&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShhWniFKtZH2CvojJ08p9fP2wQrn06i2DBM9W-DijISWPP4LKz&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSW6RORjE7-G6oi7dsGRXHXQIOAxKx5FzdkVk1DO10NMf3-CKnGcg&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSfrpAKvPy2_w4jtU5dQE8r5b8IMwfoh3ni9IHlzfMb_Bx27Bqw&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQbFpbNH-EOR2lv4W3dVjtvOH_YGzcaPA1cVkeLj1MfjGVetDSh&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSzhuTPVlTyrs0CCjoqOJ_3RYIARGxrjsOrIZexQCeAhsN3afcwBw&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQgNxJLrKC3XHlrB3LiQhgRfH_9hXOG1TS_R4txpxvAHHj1-h55&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNXxosZT_xX9kSLRxJQcV4mtZ1jhQEgI0Rgu8_bth77L1powlD&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSNKMV37Oigb7Ud9NuhA3ecHhO-WmMdG9iMc_eE93XK2YSigEQOgA&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnTO5r7ussPg2-sXBH2PwjJS9Jy05YeCd1Lv_jwqLjC8Q5AqRj3w&s",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZf0qgy9SqbiWgJkmg-RsEr1NUJev9HjspUn3UYhDKfK5YE1OmGA&s",]
    }
    
    var textMsg : [String]{
        return ["Haha",
                "Xin chào, đang làm gì thế?",
                "Ô mai chuối",
                "What the hell",
                "Phật ở trên kia cao quá",
                "Mãi mãi không độ tới nàng",
                "Vạn vật tương tư vì ai",
                "Tiếng mõ vang lên phũ phàng",
                "Chùa này không thấy bóng nàng",
                "Bồ đề chẳng muốn nở hoa",
                "Dòng kinh còn lưu vạn chữ",
                "Bỉ ngạn phủ lên mấy thu",
                "Hồng trần hôm nay xa quá",
                "Ái ố không thể giải bày",
                "Hỏi người ra đi vì đâu",
                "Chắc chắn không thể quay đầu",
                "Mộng này tan theo bóng Phật",
                "Trả lại người áo cà sa",
                "Vì sao độ ta không độ nàng",
                "Hồng trần trên đôi cánh tay",
                "Họa đời em trong phút giây",
                "Từ ngày thơ ấy còn ngủ mơ đến khi em thờ ơ",
                "Lòng người anh đâu có hay",
                "Một ngày khi vỗ cánh bay",
                "Từ người yêu hóa thành người dưng đến khi ta tự xưng à. Thương em bờ vai nhỏ nhoi",
                "Đôi mắt hóa mây đêm. Thương sao mùi dạ lý hương. Vương vấn mãi bên thềm",
                "Đời phiêu du cố tìm một người thật lòng. Dẫu trời mênh mông anh nhớ em",
                "Chim kia về vẫn có đôi. Sao chẳng số phu thê. Em ơi đừng xa cách tôi",
                "Trăng cố níu em về. Bình yên trên mái nhà. Nhìn đời ngược dòng. Em còn bên anh có phải không?",
                "Trời ban ánh sáng, năm tháng tư bề. Dáng ai về chung lối",
                "Người mang tia nắng nhưng cớ sao còn tăm tối. Một mai em lỡ vấp ngã trên đời thay đổi",
                "Nhìn về anh‚ người chẳng khiến em lẻ loi",
                "Ah! Nếu em có về",
                "Anh sẽ mang hết những suy tư, mang hết hành trang những ngày sống khổ để cho gió biển di cư",
                "Anh thà lênh đênh không có ngày về hoá kiếp thân trai như Thủy Hử",
                "Chẳng đành để em từ một cô bé sóng gió vây quanh thành quỷ dữ",
                "Ta tự đẩy mình hay tự ta trói. Bây giờ có khác gì đâu",
                "Ta chả bận lòng hay chẳng thể nói. Tụi mình có khác gì nhau",
                "Dêu sao cánh điệp phủ mờ nét bút. Dẫu người chẳng hẹn đến về sau",
                "Phố thị đèn màu ta chỉ cần chung lối. Để rồi sống chết cũng vì nhau",
                "Nhặt một nhành hoa rơi. Đoạn đường về nhà thật buồn em ơi",
                "Dòng người vội vàng giờ này. Tình ơi‚ tình ơi‚ tình ơi em ở đâu rồi",
                "Lặng nhìn bờ vai xưa. Tựa đầu mình hỏi rằng khổ chưa",
                "Đành lòng chặn đường giờ. Đừng đi, đừng đi, đừng đi vì câu hứa",
                "Những điểm thay đổi trong Điều khoản dịch vụ của YouTube",]
    }
    
    var imageURLMessage : [String]{
        return avatarURL
    }
}
