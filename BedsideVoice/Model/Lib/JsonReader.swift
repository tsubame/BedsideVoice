//
//  JsonReader.swift
//
//  依存ライブラリ: SwiftyJSON
//
//  Created by hideki on 2014/12/11.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import Foundation
class JsonReader: NSObject {

    // エラー
    var _hasError = false
    // エラーメッセージ
    var _errorMessage: String?
    // ファイル名
    var _fileName: String = ""
    
    override init() {
        super.init()
    }
    
    // エラーがあるか
    func hasError() -> Bool {
        return _hasError
    }
    
    // エラーメッセージを返す
    func getErrorMessage() -> String? {
        return _errorMessage
    }
    
    // ファイルからJsonデータを取得
    func getJsonFromFile(fileName: String) ->JSON? {
        // ファイルのパス取得
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json")
        // ファイルがなければnilを返す
        if path == nil {
            _hasError     = true
            _errorMessage = "=== error! === ファイルがありません！: " + fileName
            println(_errorMessage!)
            return nil
        }
        
        let jsonData = NSData(contentsOfFile: path!)
        let json = JSON(data: jsonData!)
        
        if !isValidSyntax(json) {
            _hasError     = true
            _errorMessage = "=== error! === Jsonファイルの書式エラーです: " + fileName
            println(_errorMessage!)
            return nil
        }
        
        return json
    }
    
    // 書式チェック
    func isValidSyntax(json: JSON) -> Bool {
        // 辞書型に変換できなければfalse
        if json.dictionaryValue == nil {
            return false
        }
        
        return true
    }

}