//
//  ContentViewModel.swift
//  SpeachAlarmSample
//
//  Created by 春蔵 on 2023/01/23.
//

import Foundation
import UserNotifications
import AVFoundation

class ContentViewModel:ObservableObject {
    /// 話す内容
    @Published var spechText = "アラームのテストです。"
    
    /// AVSpeechSynthesizer
    let synthesizer = AVSpeechSynthesizer()
    
    /// アラーム設定
    func onSetAlaram(){
        let fileName = "testSound"
        
        // 音源ファイルの生成
        let sound = save(text:spechText , fileName: fileName)
        
        // 5秒後
        let modifiedDate = Calendar.current.date(byAdding: .second, value: 5, to: Date())!
        
        // アラーム
        timeMotification(date:modifiedDate , identifier: fileName + "_id" , sound: sound , message: spechText)
    }
    
    /// 通知の許可
    func requestAuthorization(){
        // 通知の許可
        UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .sound]){
            (granted, _) in
            if granted{
                // 通知が許可された
                print("granted")
            }
        }
    }
    
    /// 時限式通知トリガー
    /// - Parameters:
    ///   - date: 通知時間
    ///   - identifier: 通知identifier
    ///   - sound: 通知サウンド
    ///   - message: 通知メッセージ
    func timeMotification(date :Date , identifier :String , sound:String , message : String){
        /// アプリケーション名
        let appName = "SpeachAlarmSample"

        // Contentの作成
        let dateComps = date.getComponents()
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComps, repeats: false)
        let content = UNMutableNotificationContent()
        let notificationSound = UNNotificationSoundName(rawValue: sound)
        
        // コンテントの作成
        content.title = appName
        content.body = message
        content.sound = UNNotificationSound(named: notificationSound)
        content.categoryIdentifier = appName

        // リクエストの作成
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    /// 文言をファイルにLibrary/Soundsに保存
    /// - Parameters:
    ///   - text: 読上げ文言
    ///   - fileName: ファイル名
    ///   - extension: 拡張し
    func save(text:String , fileName:String)->String{
        let ext = "caf"
        
        // Library/Sounds URLの取得
        let libraryUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        print("libraryUrl:" + libraryUrl.path)
        var fileUrl = libraryUrl.appendingPathComponent("Sounds")
        // ディレクトリの作成
        if !FileManager.default.fileExists(atPath: fileUrl.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: fileUrl, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                return ""
            }
        }
        // ファイル名の生成
        fileUrl.appendPathComponent(fileName)
        fileUrl.appendPathExtension(ext)
        
        print("fileUrl:" + fileUrl.path)

        // 読上げ文言の保存
        try? save(text:text , fileURL:fileUrl)
        
        return fileName + "." + ext
    }
    
    /// ファイル保存
    /// - Parameters:
    ///   - text: 読上げテキスト
    ///   - fileURL: 保存先URL
    func save(text:String, fileURL: URL) throws {
        var output: AVAudioFile?
        let utterance = AVSpeechUtterance.init(string: text)

        // 既存ファイルの削除
        try? FileManager.default.removeItem(at: fileURL)
                
        synthesizer.write(utterance) { buffer in
            guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                return
            }
            if pcmBuffer.frameLength == 0 {
                // no length
                print("No length")
            }else{
                if output == nil {
                    output = try! AVAudioFile(forWriting: fileURL, settings: pcmBuffer.format.settings, commonFormat: .pcmFormatInt16, interleaved: false)
                }
                try! output!.write(from: pcmBuffer)
            }
            
        }
    }
}

extension Date{
    // DateComponentsへの変換
    func getComponents() -> DateComponents {
        return Calendar(identifier: .gregorian).dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
    }
}


