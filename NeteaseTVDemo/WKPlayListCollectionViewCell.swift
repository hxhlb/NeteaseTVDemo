
import UIKit
import TVUIKit
class WKPlayListCollectionViewCell: UICollectionViewCell {
    
    private var motionEffectV: UIInterpolatingMotionEffect!
    private var motionEffectH: UIInterpolatingMotionEffect!
    var playListCover: UIImageView = UIImageView()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    var titleLabel: UILabel = UILabel()
    var posterView: TVPosterView!
    var scaleFactor: CGFloat = 1.05
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setupViews() {
        self.clipsToBounds = true
        motionEffectV = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        motionEffectV.maximumRelativeValue = 8
        motionEffectV.minimumRelativeValue = -8
        motionEffectH = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        motionEffectH.maximumRelativeValue = 8
        motionEffectH.minimumRelativeValue = -8
        
        ({(imageView: UIImageView) in
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
            imageView.clipsToBounds = true
            addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        })(playListCover)
        
        ({(effectView: UIVisualEffectView) in
            effectView.layer.masksToBounds = true
            effectView.layer.cornerRadius = 10
            effectView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            contentView.addSubview(effectView)
            effectView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(100)
            }
        })(effectView)
        
        ({(label: UILabel) in
            label.textColor = .white
            label.numberOfLines = 2
            label.textAlignment = .center
            label.font = .boldSystemFont(ofSize: 30)
            addSubview(label)
            label.snp.makeConstraints { make in
                make.centerY.equalTo(effectView)
                make.leading.equalTo(10)
                make.trailing.equalTo(-10)
            }
        })(titleLabel)
        
        
//        self.posterView = TVPosterView()
//        self.posterView.imageView.contentMode = .scaleToFill
//        self.posterView.layer.cornerRadius = 10
//        self.posterView.clipsToBounds = true
//        self.posterView.imageView.layer.cornerRadius = 10
//        self.posterView.imageView.clipsToBounds = true
//
//        addSubview(self.posterView)
//        self.posterView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if isFocused {
            let scaleFactor = self.scaleFactor
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor)
                let scaleDiff = (self.bounds.size.height * scaleFactor - self.bounds.size.height) / 2
                self.transform = CGAffineTransformTranslate(self.transform, 0, -scaleDiff)
                self.layer.shadowOffset = CGSizeMake(0, 16)
                self.layer.shadowOpacity = 0.2
                self.layer.shadowRadius = 18.0
                self.layer.cornerRadius = 10
                self.addMotionEffect(self.motionEffectH)
                self.addMotionEffect(self.motionEffectV)
            }
        } else {
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformIdentity
                self.layer.shadowOpacity = 0
                self.layer.shadowOffset = CGSizeMake(0, 0)
                self.layer.cornerRadius = 10
                self.removeMotionEffect(self.motionEffectH)
                self.removeMotionEffect(self.motionEffectV)
            }
        }
    }
}
