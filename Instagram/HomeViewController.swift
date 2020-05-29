import Firebase
import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!

    // 投稿データを格納する配列
    var postArray: [PostData] = []

    // ユーザ情報を格納する配列と辞書
    var userArray: [String] = []
    var userDic: [String: String] = [:]

    // Firestoreのリスナー
    var listener: ListenerRegistration!
    var listener2: ListenerRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")

        if Auth.auth().currentUser != nil {
            // ログイン済み
            if listener == nil {
                // listener未登録なら、登録してスナップショットを受信する
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
                listener = postsRef.addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    }
                    // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                    self.postArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: postdocument取得 \(document.documentID)")
                        let postData = PostData(document: document)
                        return postData
                    }
                    // ユーザ情報を取得済みの場合は、更新する。
                    // 初回の場合は、ユーザ情報取得側で、更新する。
                    if self.listener2 != nil {
                        // TableViewの表示を更新する
                        self.tableView.reloadData()
                    }
                }
                // ユーザ情報のリスナー
                let userRef = Firestore.firestore().collection(Const.UserPath)
                listener2 = userRef.addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    }
                    // 取得したdocumentをもとにuserDicの辞書にする。
                    self.userArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: userdocument取得 \(document.documentID)")
                        // ユーザのドキュメントデータを格納
                        let userData = document.data()
                        let user = userData["name"] as? String
                        // ユーザの表示名とIDを辞書に格納
                        self.userDic.updateValue(user!, forKey: document.documentID)

                        return user!
                    }
                    // TableViewの表示を更新する
                    self.tableView.reloadData()
                }
            }
        } else {
            // ログイン未(またはログアウト済み)
            if listener != nil {
                // listener登録済みなら削除してpostArrayをクリアする
                // 合わせて、ユーザ関連もクリアする
                listener.remove()
                listener2.remove()
                listener = nil
                listener2 = nil
                postArray = []
                userArray = []
                userDic = [:]
                tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.userDic = userDic
        cell.setPostData(postArray[indexPath.row])

        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action: #selector(handleButton(_:forEvent:)), for: .touchUpInside)

        // コメントボタン
        cell.commentButton.addTarget(self, action: #selector(commentButton(_:forEvent:)), for: .touchUpInside)

        return cell
    }

    // セル内のライクボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]

        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }

    // セル内のコメントボタンがタップされた時に呼ばれるメソッド
    @objc func commentButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: commentボタンがタップされました。")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]

        // comment画面にモーダル画面遷移する
        let commentViewController = storyboard!.instantiateViewController(withIdentifier: "Comment") as! CommentViewController

        // 対象のドキュメントIDを設定する
        commentViewController.documentId = postData.id

        present(commentViewController, animated: true)
    }
}
