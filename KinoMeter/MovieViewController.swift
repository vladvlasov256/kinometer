//
//  ViewController.swift
//  MovieMeter
//
//  Created by Vladimir Vlasov on 23.09.17.
//  Copyright © 2017 Sofa Technologies. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {
    
    @IBOutlet weak var badge: UILabel?
    @IBOutlet weak var poster: UIImageView?
    @IBOutlet weak var info: UIView?
    @IBOutlet weak var name: UILabel?
    @IBOutlet weak var alternative: UILabel?
    @IBOutlet weak var year: UILabel?
    @IBOutlet weak var country: UILabel?
    @IBOutlet weak var director: UILabel?
    
    @IBOutlet weak var leftSwipe: UISwipeGestureRecognizer?
    @IBOutlet weak var rightSwipe: UISwipeGestureRecognizer?
    
    private let postersDirectory = "Posters"
    private let postersExtension = ".jpg"
    
    private let moviesFilename = "movies.json"
    
    private let defaultAnimationTime = TimeInterval(0.25)
    
    private var startTime: Date?
    
    private lazy var movieViews: [UIView?] = {
        return [poster, info]
    }()
    
    typealias MovieInfo = (name: String, alternative: String, year: Int, country: String, director: String)
    private var movies: [MovieInfo]?
    
    private let nameField = "name"
    private let alternativeField = "alternative"
    private let yearField = "year"
    private let countryField = "country"
    private let directorField = "director"
    
    private let mainStoryboardName = "Main"
    private let manualViewControllerId = "ManualViewController"
    
    private let reportViewControllerId = "ReportViewController"
    
    private var currenMovieIndex = -1
    
    private var watchedMovies = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hide(views: self.movieViews) {}
        self.loadMovies() {
            self.presentMovie(withIndex: 0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let manualViewController = self.instantiateModalViewController(id: manualViewControllerId)
        self.present(manualViewController, animated: false, completion: nil)
    }
    
    private func instantiateModalViewController(id: String) -> UIViewController {
        let storyboard = UIStoryboard(name: mainStoryboardName, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: id)
        viewController.modalPresentationStyle = .overCurrentContext
        return viewController
    }
    
    // TODO: Implement a model class
    private func loadMovies(completion: @escaping () -> Swift.Void) {
        let jsonPath = "\(Bundle.main.bundlePath)/\(moviesFilename)"
        let data = try! Data(contentsOf: URL(fileURLWithPath: jsonPath))
        
        var json: [[String: Any]]?
        do {
            json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        } catch {
            print(error)
        }
        
        self.movies = json?.map { item in
            let name = item[nameField] as! String
            let alternative = item[alternativeField] as! String
            let year = item[yearField] as! Int
            let country = item[countryField] as! String
            let director = item[directorField] as! String
            return (name: name, alternative: alternative, year: year, country: country, director: director)
        }
        
        // TODO: Implement alphabetical sorting
        
        completion()
    }
    
    private func presentMovie(withIndex index: Int) {
        self.disableSwipes()
        self.hide(views: self.movieViews, animated: index > 0) {
            self.currenMovieIndex = index
            
            // TODO: Implement async loading
            self.poster?.image = self.posterImage(index)
            
            self.presentMovieInfo(withIndex: index)
            
            self.present(views: self.movieViews, animated: true) {
                self.enableSwipes()
            }
        }
    }
    
    private func disableSwipes() {
        self.leftSwipe?.isEnabled = false
        self.rightSwipe?.isEnabled = false
    }
    
    private func enableSwipes() {
        self.leftSwipe?.isEnabled = true
        self.rightSwipe?.isEnabled = true
    }
    
    private func presentMovieInfo(withIndex index: Int) {
        let movie = self.movies?[index]
        self.name?.text = movie?.name
        self.alternative?.text = movie?.alternative
        self.year?.text = "\(movie?.year ?? 0)"
        self.country?.text = movie?.country
        self.director?.text = movie?.director
    }
    
    private func posterImage(_ index: Int) -> UIImage {
        let imagePath = "\(Bundle.main.bundlePath)/\(postersDirectory)/\(index)\(postersExtension)"
        return UIImage(contentsOfFile: imagePath)!
    }

    private func hide(views: [UIView?], animated: Bool = false, completion: @escaping () -> Swift.Void) {
        if animated {
            UIView.animate(withDuration: defaultAnimationTime, animations: {
                views.forEach { $0?.alpha = 0 }
            }, completion: { _ in
                views.forEach { view in
                    view?.isHidden = true
                    view?.alpha = 1
                }
                completion()
            })
        } else {
            views.forEach { $0?.isHidden = true }
            completion()
        }
    }
    
    private func present(views: [UIView?], animated: Bool = false, completion: @escaping () -> Swift.Void) {
        if animated {
            views.forEach { view in
                view?.alpha = 0
                view?.isHidden = false
            }
            UIView.animate(withDuration: defaultAnimationTime, animations: {
                views.forEach { $0?.alpha = 1 }
            }, completion: { _ in
                completion()
            })
        } else {
            views.forEach { $0?.isHidden = false }
            completion()
        }
    }
    
    @IBAction func swipeRight(recognizer: UISwipeGestureRecognizer) {
        self.watchedMovies += 1
        self.didSwiped()
    }
    
    @IBAction func swipeLeft(recognizer: UISwipeGestureRecognizer) {
        self.didSwiped()
    }
    
    private func didSwiped() {
        if self.startTime == nil {
            self.startTime = Date()
        }
        
        let moviesCount = self.movies?.count ?? 0
        self.badge?.text = "🎦 \(self.watchedMovies)\n\(self.currenMovieIndex + 1)/\(moviesCount)"
        
        let nextMovieIndex = self.currenMovieIndex + 1
        if nextMovieIndex >= moviesCount {
            let reportViewController = self.instantiateModalViewController(id: reportViewControllerId) as! ReportViewController
            reportViewController.report = self.report()
            self.present(reportViewController, animated: false, completion: nil)
        } else {
            self.presentMovie(withIndex: nextMovieIndex)
        }
    }
    
    private func report() -> String {
        let time = Date()
        let elapsedTime = time.timeIntervalSince(self.startTime ?? time)
        let minutes = Int(elapsedTime / 60)
        return "🎦 Просмотрено фильмов: \(watchedMovies)\n⏰ На тест ушло: \(minutes) мин"
    }
}

