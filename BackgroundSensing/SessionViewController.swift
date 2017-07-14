//
//  SessionViewController.swift
//  BackgroundSensing
//
//  Created by Emanuel Schmitt on 09.06.17.
//  Copyright © 2017 Emanuel Schmitt. All rights reserved.
//
import UIKit


class SessionViewController: UIPageViewController, QuestionViewControllerDelegate {
    
    // MARK: - Variables

    lazy var viewControllerList:[UIViewController] = {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        let instruction = sb.instantiateViewController(withIdentifier: "instructionViewController")
        let questionIntro = sb.instantiateViewController(withIdentifier: "questionIntroViewController")
        
        let grid = sb.instantiateViewController(withIdentifier: "gridViewController")
        let upload = sb.instantiateViewController(withIdentifier: "uploadViewController")
        
        let question1 = self.firstQuestionViewController()
        let question2 = self.secondQuestionViewController()
        let question3 = self.thirdQuestionViewController()
        let question4 = self.fourthQuestionViewController()
        
        let end = sb.instantiateViewController(withIdentifier: "endViewController")

        return [instruction, grid, questionIntro, question1, question2, question3, question4, upload, end]
    }()
    
    let sessionController = SessionControlller.shared
    
    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        if let firstViewController = viewControllerList.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // MARK: - QuestionView Helpers
    
    func questionViewController(_ questionViewController: QuestionViewController, didSelect item: Any) {
        
        switch questionViewController.type! {
        case .bodyPosture:
            sessionController.bodyPosture = item as? String
            break
        case .typingModality:
            sessionController.typingModality = item as? String
            break
        case .hand:
            sessionController.hand = item as? String
            break
        case .mood:
            sessionController.mood = item as? String

            // Since this is the last question.
            sessionController.persistSession()
            break
        }
        
        self.goToNextPage()
    }
    
    func questionViewController(title: String, keys: [String]) -> QuestionViewController {
        
        let questionViewController = storyboard!.instantiateViewController(withIdentifier: "questionView") as! QuestionViewController
        questionViewController.question     = title
        questionViewController.keys         = keys
        questionViewController.delegate     = self
        return questionViewController
    }
    
    func firstQuestionViewController() -> QuestionViewController {
        let vc = questionViewController(
            title: "Which Body Posture did you have while tapping?",
            keys: BodyPosture.allValues.map({ $0.rawValue })
        )
        vc.type = .bodyPosture
        return vc
    }
    
    func secondQuestionViewController() -> QuestionViewController {
        let vc = questionViewController(
            title: "Which Finger did you use while tapping?",
            keys: TypingModality.allValues.map({ $0.rawValue })
        )
        vc.type = .typingModality
        return vc
    }
    
    func thirdQuestionViewController() -> QuestionViewController {
        let vc = questionViewController(
            title: "In which hand are you holding the device?",
            keys: Hand.allValues.map({ $0.rawValue })
        )
        vc.type = .hand
        return vc
    }
    
    func fourthQuestionViewController() -> QuestionViewController {
        let vc = questionViewController(
            title: "What is your current mood?",
            keys: Mood.allValues.map({ $0.rawValue })
        )
        vc.type = .mood
        return vc
    }
    
    // MARK: - Navigation Helpers

    func goToNextPage(){
        
        guard let currentViewController = self.viewControllers?.first else { return }
        
        guard let nextViewController = self.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
        
        setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)

    }
    
    
    func goToPreviousPage(){
        guard let currentViewController = self.viewControllers?.first else { return }
        
        guard let previousViewController = self.pageViewController( self, viewControllerBefore: currentViewController ) else { return }
        
        setViewControllers([previousViewController], direction: .reverse, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.index(of: viewController) else {return nil}
        
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0 else {return nil}
        
        guard viewControllerList.count > previousIndex else {return nil}
        
        return viewControllerList[previousIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.index(of: viewController) else {return nil}
        
        let nextIndex = vcIndex + 1
        
        guard viewControllerList.count != nextIndex else { return nil}
        
        guard  viewControllerList.count > nextIndex else { return nil }
        
        return viewControllerList[nextIndex]
        
    }
}
