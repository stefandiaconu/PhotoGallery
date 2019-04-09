//
//  ViewController.swift
//  PhotoAlbum
//
//  Created by Stefan Diaconu on 11/03/2019.
//  Copyright © 2019 Stefan Diaconu. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Photos
import CoreData

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var arrayImages:[UIImage] = [] // array of images
    var itemCount:Int = 0
    var result:String = ""
    var id:Int = 0
    var dataSaved:Bool = false
    
    @IBOutlet weak var displayImage: UIImageView!
    @IBOutlet weak var myCollectionView: UICollectionView! // set a collection view to display iamges picked from library
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    var fileName:String!
    
    // return the number of cells for the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    // set the cells of the collection view with images from array
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! myCell
        if (arrayImages.count != 0){
            cell.myImage.image = arrayImages[indexPath.row]
        }
        
        return cell
    }
    
    // display in image view the selected photo from collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! myCell
        if (cell.isSelected){
            id = indexPath.item
            displayImage.image = arrayImages[indexPath.item]
            display(image: displayImage.image!)
        }
    }
    
    // request to classify a photo using the trained mosel HorseClassifier
    func display(image: UIImage){
        
        let modelFile = HorseClassifier()
        let model = try! VNCoreMLModel(for: modelFile.model)
        
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [ : ])
        let request = VNCoreMLRequest(model: model, completionHandler: findResults)
        
        try! handler.perform([request])
    }
    
    // use trained model to recognise horses from selected photos
    // find the result for photo using image classifier
    func findResults(request: VNRequest, error: Error?){
        
        guard let results = request.results as? [VNClassificationObservation] else {
            fatalError("Unable to et results")
        }
        
        var bestGuess = ""
        var bestConfidence: VNConfidence = 0
        
        for classification in results{
            if (classification.confidence > bestConfidence){
                bestConfidence = classification.confidence
                bestGuess = classification.identifier
            }
        }
        result = "\(bestGuess) horse with confidence \(Int(bestConfidence * 100))% "
        secondLabel.text = result
    }
    
    @IBAction func addPhotoButton(_ sender: Any) {
        getPhoto()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if (itemCount == 0){
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
            
            let titFont = [NSAttributedString.Key.font: UIFont(name: "ArialHebrew-Bold", size: 25.0)!]
            let msgFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 20.0)!]
            
            let titAttrString = NSMutableAttributedString(string: "Error", attributes: titFont)
            let msgAttrString = NSMutableAttributedString(string: "Add photos to galerry!", attributes: msgFont)
            
            alertController.setValue(titAttrString, forKey: "attributedTitle")
            alertController.setValue(msgAttrString, forKey: "attributedMessage")
            
            let confirmAction = UIAlertAction(title:"Ok", style:UIAlertAction.Style.default)
            
            alertController.addAction(confirmAction)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            savingData()
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
            
            let titFont = [NSAttributedString.Key.font: UIFont(name: "ArialHebrew-Bold", size: 25.0)!]
            let msgFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 20.0)!]
            
            let titAttrString = NSMutableAttributedString(string: "OK", attributes: titFont)
            let msgAttrString = NSMutableAttributedString(string: "Photo Saved", attributes: msgFont)
            
            alertController.setValue(titAttrString, forKey: "attributedTitle")
            alertController.setValue(msgAttrString, forKey: "attributedMessage")
            
            let confirmAction = UIAlertAction(title:"Ok", style:UIAlertAction.Style.default)
            
            alertController.addAction(confirmAction)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func getPhoto(){
        // use image picker to get photos from library
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        picker.dismiss(animated: true, completion: nil)
        guard let gotImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("No picture chosen")
        }
        
        // insert to collection view the
        myCollectionView?.performBatchUpdates({
            let indexPath = IndexPath(row: arrayImages.count, section: 0)
            // append to array of images the selected photo
            arrayImages.append(gotImage) //add object to data source first
            // insert into collection view a new cell
            self.myCollectionView?.insertItems(at: [indexPath])
            itemCount += 1
        }, completion: nil)
    }
    
    func savingData(){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: "Data", in: managedContext)!
        
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        user.setValue(id, forKeyPath: "id")
        user.setValue(result, forKeyPath: "result")
        
        //The next step is to save them inside the Core Data
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set the layout for collection view
        // 3 images per width of screen
        let itemSize = UIScreen.main.bounds.width/3 - 3
        
        // create new layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.scrollDirection = .horizontal
        
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        
        // set the new layout to collection view
        myCollectionView.collectionViewLayout = layout
    }
    
}

