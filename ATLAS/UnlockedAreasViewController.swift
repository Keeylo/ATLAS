//
//  UnlockedAreasViewController.swift
//  ATLAS
//
//  Created by Eric Rodriguez on 10/21/24.
//

import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

// MARK: - Area Model
struct Area {
    let name: String
    let image: String
    let coordinate: Coordinate
    var isUnlocked: Bool = false
}

// MARK: - Custom Layout
class WheelLayout: UICollectionViewFlowLayout {
    private let minimumScale: CGFloat = 0.6
    
    override init() {
        super.init()
        scrollDirection = .vertical
        minimumLineSpacing = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        let mainItemHeight: CGFloat = 120
        let visibleHeight = collectionView.bounds.height
        
        itemSize = CGSize(width: collectionView.bounds.width - 40, height: mainItemHeight)
        
        // Calculate insets to center the items
        let verticalInsets = (visibleHeight - mainItemHeight) / 2
        sectionInset = UIEdgeInsets(top: verticalInsets, left: 20, bottom: verticalInsets, right: 20)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect),
              let collectionView = collectionView else { return nil }
        
        let centerY = collectionView.contentOffset.y + collectionView.bounds.height / 2
        let itemHeight = self.itemSize.height
        
        attributes.forEach { attribute in
            let distanceFromCenter = abs(attribute.center.y - centerY)
            
            // More granular scaling based on distance
            if distanceFromCenter < itemHeight * 0.5 {
                // Center item (largest)
                attribute.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                attribute.alpha = 1.0
            } else if distanceFromCenter < itemHeight * 1.5 {
                // First items away from center
                let scale: CGFloat = 0.85
                attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
                attribute.alpha = 0.9
            } else if distanceFromCenter < itemHeight * 2.5 {
                // Second items away from center
                let scale: CGFloat = 0.7
                attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
                attribute.alpha = 0.8
            } else if distanceFromCenter < itemHeight * 3.5 {
                // Third items away from center
                let scale: CGFloat = 0.55
                attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
                attribute.alpha = 0.7
            } else {
                // Items further away
                let scale: CGFloat = 0.4
                attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
                attribute.alpha = 0.6
            }
        }
        
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}


// MARK: - Collection View Cell
class AreaCell: UICollectionViewCell {
    static let identifier = "AreaCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(nameLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.7),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        nameLabel.textAlignment = .left
        
//        imageView.addSubview(overlayView)
//        overlayView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(blurEffectView)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            overlayView.topAnchor.constraint(equalTo: imageView.topAnchor),
//            overlayView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
//            overlayView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
//            overlayView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            blurEffectView.topAnchor.constraint(equalTo: imageView.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])
    }
    
    func configure(with area: Area) {
        imageView.image = UIImage(named: area.image)
        nameLabel.text = area.name
        overlayView.isHidden = area.isUnlocked
        blurEffectView.isHidden = area.isUnlocked
    }
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }()
}

class UnlockedAreasViewController: UIViewController {

    @IBOutlet weak var sunnySideUp: UIImageView!
    
    private var areas: [Area] = []
    private var currentIndex = 0
    
    private lazy var collectionView: UICollectionView = {
        let layout = WheelLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.decelerationRate = .fast
        return cv
    }()
    
    private let upArrow: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.up"))
        iv.tintColor = .white
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let downArrow: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.down"))
        iv.tintColor = .white
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rotationAngle = CGFloat(-15) * CGFloat(Double.pi) / 180
        sunnySideUp.transform = CGAffineTransform(rotationAngle: rotationAngle)
        setupViews()
        setupGestures()
        loadAreas()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(areaUnlockedNotification(_:)),
            name: NSNotification.Name("AreaUnlocked"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("AreaUnlocked"), object: nil)
    }

    
    @objc func areaUnlockedNotification(_ notification: Notification) {
        if let areaName = notification.userInfo?["areaName"] as? String {
            if let index = areas.firstIndex(where: { $0.name == areaName }) {
                areas[index].isUnlocked = true
                collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
    }
    
    func unlockArea(at index: Int) {
        guard index >= 0 && index < areas.count else { return }
        areas[index].isUnlocked = true
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func fetchUnlockedAreasFromFirebase() {
        guard let user = Auth.auth().currentUser else {
            print("User not authenticated")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error)")
            } else if let document = document, document.exists {
                if let locationsList = document.get("locations") as? [String] {
                    self.updateUnlockedAreas(locationsList)
                } else {
                    print("No locations array found in the document.")
                    self.updateUnlockedAreas([])
                }
            } else {
                print("Document does not exist.")
                self.updateUnlockedAreas([])
            }
        }
    }
    
    func updateUnlockedAreas(_ unlockedLocations: [String]) {
        for index in areas.indices {
            areas[index].isUnlocked = unlockedLocations.contains(areas[index].name)
        }
        collectionView.reloadData()
    }

    
    @IBAction func backToMap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUnlockedAreasFromFirebase()
    }
    
    private func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(upArrow)
        view.addSubview(downArrow)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        upArrow.translatesAutoresizingMaskIntoConstraints = false
        downArrow.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(AreaCell.self, forCellWithReuseIdentifier: AreaCell.identifier)
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // Collection view should start below "Unlocked Areas" title and end above "Go Back" button
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 60),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -70),
            
            // Center the arrows within the collection view bounds
            upArrow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            upArrow.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: -76),
            
            downArrow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downArrow.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: 40)
        ])
    }
    
    private func setupGestures() {
        let upTap = UITapGestureRecognizer(target: self, action: #selector(handleUpArrowTap))
        let downTap = UITapGestureRecognizer(target: self, action: #selector(handleDownArrowTap))
        upArrow.addGestureRecognizer(upTap)
        downArrow.addGestureRecognizer(downTap)
    }
    
    private func loadAreas() {
        areas = [
            Area(name: "Gregory Gymnasium", image: "gregGood", coordinate: Coordinate(latitude: 30.28447, longitude: -97.73676)),
            Area(name: "Norman Hackerman Building", image: "normanGood", coordinate: Coordinate(latitude: 30.28765, longitude: -97.73801), isUnlocked: false),
            Area(name: "UT Tower, Main Building", image: "uttowerGooder", coordinate: Coordinate(latitude: 30.28593, longitude: -97.73941)),
            Area(name: "The Littlefield Fountain", image: "fountainGooder", coordinate: Coordinate(latitude: 30.28396, longitude: -97.73957)),
            Area(name: "The UT Student Union", image: "unionGood", coordinate: Coordinate(latitude: 30.28674373328207,longitude: -97.74099681516714)),
            Area(name: "EER", image: "eerGood", coordinate: Coordinate(latitude: 30.28817, longitude: -97.73553)),
            Area(name: "Blanton Museum of Art", image: "blantonGood", coordinate: Coordinate(latitude: 30.28096, longitude: -97.73774)),
            Area(name: "Clock Knot", image: "clockknotGood", coordinate: Coordinate(latitude: 30.28974, longitude: -97.73606)),
            Area(name: "The West", image: "the_west_image1", coordinate:
                    Coordinate(latitude: 30.28561, longitude: 97.73824)),
            Area(name: "Monochrome For Austin", image: "monochrome_for_austin_image2",
                 coordinate: Coordinate(latitude: 30.28769, longitude: -97.73707)),
            Area(name: "Circle With Towers", image: "circle_with_towers_image1", coordinate: Coordinate(latitude: 30.28626, longitude: -97.73694))
        ]
        
        let middleIndex = areas.count / 2
        currentIndex = middleIndex
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.scrollToItem(
                at: IndexPath(item: middleIndex, section: 0),
                at: .centeredVertically,
                animated: false
            )
        }
    }
    
    @objc private func handleUpArrowTap() {
        scrollToNextItem(direction: -1)
    }
    
    @objc private func handleDownArrowTap() {
        scrollToNextItem(direction: 1)
    }
    
    private func scrollToNextItem(direction: Int) {
        let nextIndex = currentIndex + direction
        guard nextIndex >= 0 && nextIndex < areas.count else {
            return
        }
        
        currentIndex = nextIndex
        collectionView.scrollToItem(
            at: IndexPath(item: currentIndex, section: 0),
            at: .centeredVertically,
            animated: true
        )
    }
}

// MARK: - Collection View Data Source & Delegate
extension UnlockedAreasViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return areas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AreaCell.identifier, for: indexPath) as! AreaCell
        cell.configure(with: areas[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let area = areas[indexPath.item]
        if area.isUnlocked {
            // Instantiate the LocationInfoViewController
            let storyboard = UIStoryboard(name: "LocationInfoStoryboard", bundle: nil) // Replace "Main" with your storyboard name
            if let locationInfoVC = storyboard.instantiateViewController(withIdentifier: "LocationInfoViewController") as? LocationInfoViewController {
                // Set the locationName
                locationInfoVC.locationTitle = area.name
                // Present the view controller
                self.present(locationInfoVC, animated: true, completion: nil)
            }
        } else {
            // Area is locked, show an alert or handle accordingly
            let alert = UIAlertController(title: "Locked", message: "This area is locked.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = collectionView.collectionViewLayout as! WheelLayout
        let cellHeight = layout.itemSize.height + layout.minimumLineSpacing
        
        let offset = targetContentOffset.pointee.y
        let index = round(offset / cellHeight)
        targetContentOffset.pointee = CGPoint(x: 0, y: index * cellHeight)
        
        currentIndex = Int(index) % areas.count
    }
}

struct Coordinate: Hashable {
    let latitude: Double
    let longitude: Double
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var clCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
    
    static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
