
import UIKit
import NeteaseRequest
class WKPlayListDetailViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var collectButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descView: WKDescView!
    private var playListId: Int!
    var allModels: [CustomAudioModel] = [CustomAudioModel]()
    static func creat(playListId: Int) -> WKPlayListDetailViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKPlayListDetailViewController
        vc.playListId = playListId
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(WKPlayListTableViewCell.self, forCellReuseIdentifier: "WKPlayListTableViewCell")
        Task {
            await loadData()
        }
        
    }
    
    func loadData() async {
        let playListDetail: NRPlayListDetailModel = try! await fetchPlayListDetail(id: self.playListId, cookie: cookie)
        self.bgView.kf.setImage(with: URL(string: playListDetail.coverImgUrl),options: [.transition(.flipFromBottom(0.6))])
        self.nameLabel.text = playListDetail.name
        self.descView.descLabel.text = playListDetail.description
        self.descView.onPrimaryAction = { [weak self] model in
            let vc = WKDescViewController.creat(desc: playListDetail.description ?? "")
            self!.present(vc, animated: true)
        }
        
        let songModels:[NRSongModel] = try! await fetchPlayListTrackAll(id: self.playListId,limit: 100)
        self.allModels.removeAll()
        for songModel in songModels {
            let model = CustomAudioModel()
            model.audioId = songModel.id
            model.isFree = 1
            model.freeTime = 0
            model.audioTitle = songModel.name
            model.audioPicUrl = songModel.al?.picUrl
            
            let min = (songModel.dt ?? 0) / 1000 / 60
            let sec = (songModel.dt ?? 0) / 1000 % 60
            model.audioTime = String(format: "%d:%02d", min, sec)
            if let singerModel = songModel.ar {
                model.singer = singerModel.map { $0.name! }.joined(separator: "/")
            }
            self.allModels.append(model)
        }
        tableView .reloadData()
        self.playButton.isHidden = false
    }

    @IBAction func playAll(_ sender: Any) {
        if self.allModels.count > 0 {
            wk_player.allOriginalModels = self.allModels
            try? wk_player.play(index: 0)
            let playingVC = WKPlayingViewController.creat()
            playingVC.modalPresentationStyle = .blurOverFullScreen
            self.present(playingVC, animated: true)
        }
        
    }
}


extension WKPlayListDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WKPlayListTableViewCell", for: indexPath) as! WKPlayListTableViewCell
        cell.setModel(self.allModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if wk_player.isPlaying && wk_player.currentModel?.audioId == self.allModels[indexPath.row].audioId {
            let playingVC = WKPlayingViewController.creat()
            self.present(playingVC, animated: true)
            return
        }
        let model: [CustomAudioModel] = [self.allModels[indexPath.row]]
        wk_player.allOriginalModels = model
        try? wk_player.play(index: 0)
        let playingVC = WKPlayingViewController.creat()
        self.present(playingVC, animated: true)
    }
}
