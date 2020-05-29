//
//  CommentViewController.swift
//  Instagram
//
//  Created by 0001 QBS on 2020/05/22.
//  Copyright © 2020 qbs0001. All rights reserved.
//

import Firebase
import SVProgressHUD
import UIKit

class CommentViewController: UIViewController {
    var documentId: String!
    
    @IBOutlet var textField: UITextField!
    
    @IBAction func handlePostButton(_ sender: Any) {
        if let comment = textField.text {
            // コメントが入力されていない時はHUDを出して何もしない
            if comment.isEmpty {
                SVProgressHUD.showError(withStatus: "コメントを入力して下さい")
                return
            }
            
            // コメントを更新する
            if let myid = Auth.auth().currentUser?.uid {
                // 画面に表示名を表示するため、コメントの先頭にユーザのIDを付与する
                var updateValue: FieldValue
                updateValue = FieldValue.arrayUnion([myid + " : " + comment])
                // commentsに更新データを書き込む
                let postRef = Firestore.firestore().collection(Const.PostPath).document(self.documentId)
                postRef.updateData(["comments": updateValue])
                
                print("DEBUG_PRINT: documentId = \(self.documentId!)のコメントに成功しました。")
                
                // HUDで完了を知らせる
                SVProgressHUD.showSuccess(withStatus: "コメントを投稿しました")
                
                // HOME画面に戻る
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func handleCancelButton(_ sender: Any) {
        // HOME画面に戻る
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: コメントを追加するdocumentId = \(self.documentId!)")
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
