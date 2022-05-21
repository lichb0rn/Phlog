import UIKit
import MapKit

class PhlogAnnotationView: MKAnnotationView {

    static let identifier = "PhlogAnnotation"

    public var cornerRadius: CGFloat = 8
    public var color: UIColor = UIColor.darkGray
    private var imageView: UIImageView!

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)

        configureView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func configureView() {
        canShowCallout = true
        isOpaque = false

        backgroundColor = color
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2

        imageView = UIImageView(frame: self.frame)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = cornerRadius
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }

    func setImage(_ image: UIImage) {
        imageView.image = image
    }
}
