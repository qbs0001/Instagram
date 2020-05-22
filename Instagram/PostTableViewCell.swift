import Firebase
import FirebaseUI
import UIKit

class PostTableViewCell: UITableViewCell {
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var likeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var captionLabel: UILabel!

    @IBOutlet var commentButton: UIButton!
    @IBOutlet var commentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        // 画像の表示
        self.postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        self.postImageView.sd_setImage(with: imageRef)

        // キャプションの表示
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"

        // 日時の表示
        self.dateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
        }

        // いいね数の表示
        let likeNumber = postData.likes.count
        self.likeLabel.text = "\(likeNumber)"

        // いいねボタンの表示
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        
        
        

        var convComments: [String] = []
        
        for value in postData.comments {
            
            // " : "で配列に分解
            var array = value.components(separatedBy: " : ")
            
            // ひとつ目の要素（ユーザID）でユーザのドキュメントを取得
            let userRef = Firestore.firestore().collection(Const.UserPath).document(array[0])
            userRef.getDocument { document, _ in
                if let document = document, document.exists {
                    // ユーザのドキュメントデータを格納
                    let userData = document.data()
                    // ユーザIDに紐づく表示名をユーザIDの代わりに格納
                    if let userName = userData!["name"] as? String {
                        array[0] = userName + " : "

                        // 配列を文字列に結合
                        let value2 = array.joined()

                        // 文字列を配列に格納
                        convComments.append(value2)
   
                    }
                } else {
                    print("Document does not exist")
                }
               print("2")
               
            }
            print("1")
        }
        
        print("3")
        // ユーザの表示名とコメントの表示
        self.commentLabel.text = "\(convComments.joined(separator: "\n"))"
    }
}
